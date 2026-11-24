import SpectraCore
import SwiftUI

/// One wallet's staking: its positions, and staking from it. A wallet's page
/// opens it where core offers staking for the wallet's network; there is no
/// other way in.
struct WalletStakingView: View {
    let chain: Chain
    let walletId: String
    @Bindable var store: AppState
    @State private var staking: StakingState
    @State private var showsValidators = false
    @State private var confirmsSigning = false
    @State private var confirmsBroadcast = false

    init(store: AppState, wallet: WalletState) {
        chain = wallet.chainId
        walletId = wallet.id
        self.store = store
        _staking = State(wrappedValue: StakingState(chain: wallet.chainId, bridge: store.bridge))
    }

    private var wallet: WalletState? { store.wallet(for: staking.walletId) }
    /// The wallet's balance of the network's coin, as its rows show it.
    private var availableToStake: String? {
        guard let coin = store.availableSendCoins(for: staking.walletId).first(where: \.isNativeCoin) else { return nil }
        return store.amounts.formattedAssetAmount(coin.amount, symbol: coin.symbol, deploymentId: coin.id)
    }
    private var requiresPassword: Bool { wallet?.signing.requiresPassword ?? true }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
                if let entry = CoreReferenceTables.stakingEntry(for: chain) { mechanics(entry) }
                if wallet?.signing.isWatchOnly == true {
                    Text(AppLocalization.string("staking.watch_only")).font(.caption).foregroundStyle(.secondary)
                } else if requiresPassword {
                    passwordCard
                }
                if !staking.walletId.isEmpty {
                    if let progress = staking.session.progress {
                        StakingTransactionView(
                            store: store, staking: staking, progress: progress,
                            confirmsSigning: $confirmsSigning, confirmsBroadcast: $confirmsBroadcast)
                    } else {
                        StakingPositionsView(
                            staking: staking, canSign: wallet?.signing.isWatchOnly == false,
                            requiresPassword: requiresPassword, hidesBalances: store.preferences.hideBalances)
                        preparation
                        savedTransactions
                    }
                }
            }.spectraScreenPadding()
        }
        .scrollDismissesKeyboard(.interactively)
        .background(SpectraBackdrop().ignoresSafeArea())
        .navigationTitle(AppLocalization.string("Staking")).inlineNavigationTitle()
        .clearNavigationBar()
        .task {
            staking.selectWallet(walletId)
            await staking.loadValidators()
        }
        .task(id: staking.walletId) { await staking.loadWalletData() }
        .task(id: "saved:\(staking.session.id):\(staking.session.artifact?.revision ?? 0)") {
            await staking.loadSavedArtifacts()
        }
        .task(id: staking.request?.id) {
            if let id = staking.request?.id { await staking.perform(id, store: store) }
        }
        .task(id: "\(staking.session.artifact?.id ?? ""):\(store.transactionRevision)") {
            await staking.session.refresh()
        }
        .onDisappear { staking.cancel() }
        .pageSheet(isPresented: $showsValidators) {
            StakingValidatorPicker(
                validators: staking.validators, isLoading: staking.isLoading,
                selected: $staking.validatorId)
        }
        .alert(AppLocalization.string("Sign this transaction?"), isPresented: $confirmsSigning) {
            // Asked here only for a review resumed before the password was
            // typed; otherwise the page's password signs.
            if requiresPassword && staking.password.isEmpty {
                SecureField(AppLocalization.string("Wallet Password"), text: $staking.password)
            }
            Button(AppLocalization.string("Cancel"), role: .cancel) {}
            Button(AppLocalization.string("Sign Transaction"), role: .destructive) { staking.begin(.sign) }
                .disabled(requiresPassword && staking.password.isEmpty)
        } message: {
            if let artifact = staking.session.artifact, let intent = artifact.staking {
                let action = [intent.action.localizedTitle, intent.validatorId.flatMap(staking.validatorName)]
                    .compactMap { $0 }.joined(separator: " · ")
                Text(verbatim: sendSigningConfirmationMessage(artifact: artifact, amounts: store.amounts, action: action))
            }
        }
        .confirmationDialog(
            AppLocalization.string("Broadcast Transaction"), isPresented: $confirmsBroadcast,
            titleVisibility: .visible
        ) {
            Button(AppLocalization.string("Broadcast Transaction"), role: .destructive) {
                staking.begin(.broadcast)
            }
        } message: {
            Text(AppLocalization.string("staking.broadcast_confirmation"))
        }
    }

    /// The one place the password is typed; every step reads it.
    private var passwordCard: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
            SecureField(AppLocalization.string("Wallet Password"), text: $staking.password)
                .textContentType(.password).padding(SpectraLayout.Space.m).spectraInputFieldStyle()
            Text(AppLocalization.string("staking.password_once")).font(.caption).foregroundStyle(.secondary)
        }.padding(SpectraLayout.cardPadding).spectraCardFill()
    }

    private func mechanics(_ entry: StakingChainEntry) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
            Text(AppLocalization.string(entry.shortMechanic)).font(.headline)
            HStack(alignment: .top, spacing: SpectraLayout.Space.m) {
                Text(AppLocalization.string("Minimum Stake")).foregroundStyle(.secondary)
                Spacer()
                Text(AppLocalization.string(entry.minimumStake)).multilineTextAlignment(.trailing)
            }.font(.subheadline)
            HStack(alignment: .top, spacing: SpectraLayout.Space.m) {
                Text(AppLocalization.string("Unbonding")).foregroundStyle(.secondary)
                Spacer()
                Text(AppLocalization.string(entry.unbondingPeriod)).multilineTextAlignment(.trailing)
            }.font(.subheadline)
            DisclosureGroup(AppLocalization.string("How it works")) {
                Text(AppLocalization.string(entry.explanation)).font(.subheadline).foregroundStyle(
                    .secondary
                )
            }
            .disclosureGroupStyle(.spectra)
        }.padding(SpectraLayout.cardPadding).spectraElevatedFill()
    }

    private var preparation: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            HStack {
                Text(staking.action.localizedTitle).font(.headline)
                Spacer()
                if staking.positionId != nil {
                    Button(AppLocalization.string("staking.new_stake")) { staking.startStake() }.buttonStyle(
                        .glass)
                }
            }
            if let position = staking.positionId {
                Text(verbatim: position).font(.caption.monospaced()).foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
            if staking.rules.validatorRequired {
                TextField(AppLocalization.string("staking.validator_identifier"), text: $staking.validatorId)
                    .textInputAutocapitalization(.never).autocorrectionDisabled().padding(SpectraLayout.Space.m).spectraInputFieldStyle()
                if let name = staking.validatorName(staking.validatorId) {
                    Label(name, systemImage: "checkmark.seal").font(.caption.weight(.semibold))
                }
                Button(AppLocalization.string("staking.choose_validator")) { showsValidators = true }
                    .buttonStyle(.glass)
            }
            if staking.rules.amountAllowed {
                TextField(
                    AppLocalization.string(staking.rules.amountRequired ? "Amount" : "staking.optional_amount"),
                    text: $staking.amount
                )
                .keyboardType(.decimalPad).padding(SpectraLayout.Space.m).spectraInputFieldStyle()
                    .overlay(alignment: .trailing) {
                        Text(verbatim: chain.coinSymbol).font(.subheadline).foregroundStyle(.secondary)
                            .padding(.trailing, SpectraLayout.Space.m)
                    }
                // What there is to stake. No Max: what a stake must leave for
                // its fee and the network's reserve differs by network, and
                // core does not yet answer it, so the figure is the user's.
                if staking.action == .stake, let available = availableToStake {
                    BalanceText(text: available, isHidden: store.preferences.hideBalances) {
                        AppLocalization.format("Available: %@", $0)
                    }
                    .font(.caption).foregroundStyle(.secondary)
                }
                if !staking.rules.amountRequired {
                    Text(AppLocalization.string("staking.full_withdrawal")).font(.caption).foregroundStyle(
                        .secondary)
                }
            }
            if staking.rules.lockupRequired {
                TextField(AppLocalization.string("staking.dissolve_delay"), text: $staking.lockupSeconds)
                    .keyboardType(.numberPad).padding(SpectraLayout.Space.m).spectraInputFieldStyle()
                Text(AppLocalization.string("staking.dissolve_delay_help")).font(.caption).foregroundStyle(
                    .secondary)
            }
            Text(AppLocalization.string("staking.build_explanation")).font(.caption).foregroundStyle(
                .secondary)
            Button {
                staking.begin(.build)
            } label: {
                Label(AppLocalization.string("Build Transaction"), systemImage: "hammer.fill")
            }.buttonStyle(.glassProminent)
                .disabled(wallet?.signing.isWatchOnly != false || (requiresPassword && staking.password.isEmpty))
                .accessibilityIdentifier("staking.build")
            if staking.isBusy { ProgressView() }
            if let error = staking.stepError {
                StakingErrorText(message: error)
            }
        }.padding(SpectraLayout.cardPadding).spectraCardFill().disabled(staking.isBusy)
    }

    @ViewBuilder private var savedTransactions: some View {
        if !staking.savedArtifacts.isEmpty {
            SpectraRowGroup(
                title: AppLocalization.string("staking.saved_transactions"), data: staking.savedArtifacts
            ) { saved in
                Button {
                    staking.begin(.resume(saved.id))
                } label: {
                    VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
                        Text(saved.staking?.action.localizedTitle ?? AppLocalization.string("Staking")).font(
                            .subheadline.weight(.semibold))
                        Text(verbatim: AmountPresentation.exactAmount(saved.amount, symbol: saved.symbol)).font(.caption).foregroundStyle(
                            .secondary)
                        Text(AppLocalization.string(saved.stage == .prepared ? "Awaiting signing" : "Signed"))
                            .font(.caption).foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity, alignment: .leading).spectraRowPadding()
                }.buttonStyle(.plain).disabled(staking.isBusy)
            }
        }
    }
}
