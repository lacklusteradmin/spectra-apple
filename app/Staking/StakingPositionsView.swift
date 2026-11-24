import SpectraCore
import SwiftUI

struct StakingPositionsView: View {
    @Bindable var staking: StakingState
    let canSign: Bool
    let requiresPassword: Bool
    /// Hide Balances is on: the position's amounts are masked.
    let hidesBalances: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            HStack {
                Text(AppLocalization.string("staking.positions")).font(.headline)
                Spacer()
                if staking.isBusy { ProgressView() }
            }
            TextField(AppLocalization.string("staking.additional_pool"), text: $staking.extraTarget)
                .textInputAutocapitalization(.never).autocorrectionDisabled().padding(SpectraLayout.Space.m).spectraInputFieldStyle()
            Button(AppLocalization.string("staking.refresh_positions")) { staking.begin(.positions) }
                .buttonStyle(.glass)
                .disabled(
                    staking.isBusy
                        || (staking.rules.positionsRequireAuthorization
                            && (!canSign || (requiresPassword && staking.password.isEmpty)))
                )
                .accessibilityIdentifier("staking.refresh_positions")
            if let error = staking.positionsError {
                StakingErrorText(message: error)
            }
            if staking.positions.isEmpty {
                Text(
                    AppLocalization.string(
                        staking.hasLoadedPositions ? "staking.no_positions" : "staking.positions_not_loaded")
                )
                .font(.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(staking.positions) { position in
                    Divider().opacity(SpectraLayout.dividerOpacity)
                    positionRow(position)
                }
            }
        }.padding(SpectraLayout.cardPadding).spectraCardFill().disabled(staking.isBusy)
    }

    private func positionRow(_ position: StakingPosition) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
            Text(position.status.localizedTitle).font(.subheadline.weight(.semibold))
            Text(verbatim: position.id).font(.caption.monospaced()).foregroundStyle(.secondary)
                .textSelection(.enabled)
            SpectraValueRow(label: AppLocalization.string("staking.staked_balance"), value: amount(position.stakedAmountSmallestUnit), isHidden: hidesBalances)
            SpectraValueRow(label: AppLocalization.string("staking.unbonding_balance"), value: amount(position.unbondingAmountSmallestUnit), isHidden: hidesBalances)
            SpectraValueRow(label: AppLocalization.string("staking.withdrawable_balance"), value: amount(position.withdrawableAmountSmallestUnit), isHidden: hidesBalances)
            if let rewards = position.claimableRewardsSmallestUnit {
                SpectraValueRow(label: AppLocalization.string("staking.rewards"), value: amount(rewards), isHidden: hidesBalances)
            }
            if let pending = position.pendingRewardsSmallestUnit {
                SpectraValueRow(label: AppLocalization.string("staking.pending_rewards"), value: amount(pending), isHidden: hidesBalances)
            }
            if let payoutTime = position.rewardsUnlockTimeUnix {
                SpectraValueRow(label: AppLocalization.string("staking.rewards_unlock_time"), value: time(payoutTime))
            }
            if let unlock = position.unlockTimeUnix {
                SpectraValueRow(label: AppLocalization.string("staking.unlock_time"), value: time(unlock))
            }
            if let epoch = position.unlockEpoch {
                Text(AppLocalization.format("staking.unlock_epoch", epoch)).font(.caption).foregroundStyle(
                    .secondary)
            }
            if !position.availableActions.isEmpty {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: SpectraLayout.Space.s) { actions(position) }
                    VStack(alignment: .leading, spacing: SpectraLayout.Space.s) { actions(position) }
                }
            }
        }
    }

    private func amount(_ units: String) -> String {
        "\(formatNativeAmount(chain: staking.chain, smallestUnit: units).map(AmountPresentation.localizedDecimal) ?? "—") \(staking.chain.coinSymbol)"
    }

    private func time(_ unix: UInt64) -> String {
        Date(timeIntervalSince1970: Double(unix))
            .formatted(.dateTime.year().month().day().hour().minute().locale(AppLocalization.locale))
    }

    @ViewBuilder private func actions(_ position: StakingPosition) -> some View {
        ForEach(position.availableActions, id: \.self) { action in
            Button(action.localizedTitle) { staking.selectPosition(position, action: action) }
                .buttonStyle(.glass).disabled(!canSign)
        }
    }
}

/// A staking failure, where the step that raised it is.
struct StakingErrorText: View {
    let message: String
    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline).foregroundStyle(.red)
            .accessibilityIdentifier("staking.error")
    }
}

struct StakingValidatorPicker: View {
    let validators: [StakingValidator]
    let isLoading: Bool
    @Binding var selected: String
    @State private var search = ""
    @Environment(\.dismiss) private var dismiss

    private var filtered: [StakingValidator] {
        guard !search.isEmpty else { return validators }
        return validators.filter {
            $0.displayName.localizedCaseInsensitiveContains(search)
                || $0.identifier.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
                    // Loading is not empty: "No validators" waits for the answer.
                    if isLoading && validators.isEmpty {
                        ProgressView().frame(maxWidth: .infinity)
                    } else if filtered.isEmpty {
                        Text(AppLocalization.string("staking.no_validators")).foregroundStyle(.secondary)
                    } else {
                        SpectraRowGroup(data: filtered) { validator in
                            Button {
                                selected = validator.identifier
                                dismiss()
                            } label: {
                                HStack(spacing: SpectraLayout.Space.m) {
                                    VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
                                        Text(validator.displayName).font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        Text(verbatim: validator.identifier).font(.caption.monospaced())
                                            .foregroundStyle(.secondary)
                                        if let commission = validator.commission {
                                            Text(AppLocalization.format(
                                                "staking.commission_format",
                                                commission.formatted(
                                                    .percent.precision(.fractionLength(0...2)).locale(AppLocalization.locale))
                                            )).font(
                                                .caption
                                            ).foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer(minLength: SpectraLayout.Space.s)
                                    if selected == validator.identifier {
                                        Image(systemName: "checkmark").foregroundStyle(.tint)
                                    }
                                }.spectraRowPadding()
                            }.buttonStyle(.plain)
                        }
                    }
                }.spectraScreenPadding()
            }
            .background(SpectraBackdrop().ignoresSafeArea())
            .navigationTitle(AppLocalization.string("Validators"))
            .inlineNavigationTitle().clearNavigationBar()
            .searchable(text: $search)
            .toolbar {
                ToolbarItem(placement: .barTrailing) {
                    Button(AppLocalization.string("Done")) { dismiss() }
                }
            }
        }
    }
}

extension StakingPosition: @retroactive Identifiable {}
extension StakingValidator: @retroactive Identifiable { public var id: String { identifier } }
extension SendArtifact: @retroactive Identifiable {}
