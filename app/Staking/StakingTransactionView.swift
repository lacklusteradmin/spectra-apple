import SpectraCore
import SwiftUI

/// Signing and submission are explicit steps over one immutable core review;
/// which of them, and whether a check or a repair is offered, is core's
/// `SendProgress`.
struct StakingTransactionView: View {
    @Bindable var store: AppState
    @Bindable var staking: StakingState
    let progress: SendProgress
    @Binding var confirmsSigning: Bool
    @Binding var confirmsBroadcast: Bool

    private var artifact: SendArtifact { progress.artifact }
    private var canBroadcast: Bool {
        progress.next == .broadcast || (progress.next == .rebroadcast && progress.canRebroadcast)
    }
    private var needsReadPassword: Bool {
        staking.rules.positionsRequireAuthorization
            && (store.wallet(for: artifact.walletId)?.signing.requiresPassword ?? true)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            reviewCard
            statusCard
            if canBroadcast { destinations }
            if artifact.review.staking != nil, progress.next == .sign {
                Text(AppLocalization.string("staking.review_before_signing")).font(.caption)
                    .foregroundStyle(.secondary)
                Button(AppLocalization.string("Sign Transaction")) { confirmsSigning = true }
                    .buttonStyle(.glassProminent).disabled(staking.isBusy || artifact.review.networkFee == nil)
                    .accessibilityIdentifier("staking.sign")
            } else if canBroadcast {
                Button(AppLocalization.string(progress.next.title)) { confirmsBroadcast = true }
                    .buttonStyle(.glassProminent).disabled(staking.isBusy || staking.session.selectedEndpoints.isEmpty)
                    .accessibilityIdentifier("staking.broadcast")
            }
            if progress.canRecheck {
                Button(AppLocalization.string("staking.check_status")) { staking.begin(.recheck) }
                    .buttonStyle(.glass).disabled(staking.isBusy || (needsReadPassword && staking.password.isEmpty))
            }
            if progress.canRepair {
                Text(AppLocalization.string("staking.repair_explanation")).font(.caption).foregroundStyle(.secondary)
                Button(AppLocalization.string("staking.repair")) { staking.begin(.repair) }
                    .buttonStyle(.glass).disabled(staking.isBusy || (needsReadPassword && staking.password.isEmpty))
                    .accessibilityIdentifier("staking.repair")
            }
            if let link = progress.transaction?.explorerLink {
                Link(AppLocalization.string("View in block explorer"), destination: link.url).buttonStyle(
                    .glass)
            }
            if staking.isBusy { ProgressView() }
            if let error = staking.stepError {
                StakingErrorText(message: error)
            }
            Button(AppLocalization.string("staking.close_review")) { staking.startStake() }
                .buttonStyle(.glass).disabled(staking.isBusy)
        }
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            Text(AppLocalization.string("staking.review")).font(.headline)
            if let intent = artifact.staking {
                SpectraValueRow(label: "staking.action", value: intent.action.localizedTitle)
                SpectraValueRow(
                    label: "Amount",
                    value: AmountPresentation.exactAmount(artifact.amount, symbol: artifact.symbol))
                if intent.amount == nil {
                    Text(AppLocalization.string("staking.full_position_action")).font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let validator = intent.validatorId {
                    if let name = staking.validatorName(validator) {
                        SpectraValueRow(label: "staking.validator", value: name)
                        Text(verbatim: validator).font(.caption.monospaced()).foregroundStyle(.secondary)
                    } else {
                        SpectraValueRow(label: "staking.validator_identifier", value: validator)
                    }
                }
                if let position = intent.positionId {
                    SpectraValueRow(label: "staking.position", value: position)
                }
                if let delay = artifact.review.staking?.lockupSeconds {
                    SpectraValueRow(
                        label: "staking.dissolve_delay",
                        value: AppLocalization.format("staking.seconds", delay))
                }
            }
            SpectraValueRow(
                label: "Wallet",
                value: store.wallet(for: artifact.walletId)?.name ?? artifact.walletId)
            VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
                Text(AppLocalization.string("From")).font(.caption).foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: SpectraLayout.Space.s) {
                    Text(readableAddress(artifact.sender, chain: artifact.chainId)).font(.subheadline.monospaced())
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel(Text(verbatim: artifact.sender))
                    CopyButton(value: displayAddress(chain: artifact.chainId, address: artifact.sender))
                }
            }
            if let entry = CoreReferenceTables.stakingEntry(for: artifact.chainId) {
                SpectraValueRow(label: "Unbonding", value: AppLocalization.string(entry.unbondingPeriod))
            }
            if let review = artifact.review.staking {
                if review.fundingAlreadyCompleted {
                    Text(AppLocalization.string("staking.funding_completed")).font(.caption).foregroundStyle(.secondary)
                }
                // With its display-currency value and its bound, as a send's
                // fee is shown.
                if let fee = artifact.review.networkFee {
                    SpectraValueRow(
                        label: "Network Fee",
                        value: store.amounts.reviewedNetworkFee(fee, chain: artifact.chainId))
                }
                if review.feeIsDeductedFromAmount {
                    Text(AppLocalization.string("staking.fee_deducted")).font(.caption).foregroundStyle(.secondary)
                }
                if let deposit = review.refundableDeposit {
                    SpectraValueRow(
                        label: "staking.refundable_deposit",
                        value:
                            AmountPresentation.exactAmount(deposit, symbol: artifact.chainId.gasTokenSymbol))
                }
                if review.rewardPayoutIsDelayed {
                    Text(AppLocalization.string("staking.delayed_reward_payout")).font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(AppLocalization.string("staking.review_unavailable")).font(.caption).foregroundStyle(
                    .red)
            }
            ReviewWarnings(artifact: artifact)
            Text(AppLocalization.string("staking.saved_review")).font(.caption).foregroundStyle(
                .secondary)
        }.textSelection(.enabled).padding(SpectraLayout.cardPadding).spectraElevatedFill()
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            SendStatusLabel(status: progress.status)
            if let failure = progress.transaction?.localizedFailureReason {
                Text(verbatim: failure).font(.subheadline).foregroundStyle(.red)
            }
            if progress.status == .awaitingConfirmation {
                Text(AppLocalization.string("staking.submission_pending")).font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if !artifact.attempts.isEmpty {
                Divider().opacity(SpectraLayout.dividerOpacity)
                SubmissionResults(progress: progress)
            }
            // The results name the hash until the chain settles it; a staking
            // page has no receipt to name it after.
            if progress.status.isSettled,
               let hash = progress.transaction?.transactionHash ?? artifact.transactionHash {
                Divider().opacity(SpectraLayout.dividerOpacity)
                TransactionHashRow(hash: hash)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpectraLayout.cardPadding).spectraCardFill()
    }

    private var destinations: some View {
        BroadcastNodePicker(session: staking.session)
            .padding(SpectraLayout.cardPadding).spectraCardFill().disabled(staking.isBusy)
    }
}
