import SpectraCore
import SwiftUI

/// A projection of core's durable artifact, its history record and the step
/// core allows next. Node acceptance describes submission only; the history
/// record alone supplies confirmation.
struct SendStagesView: View {
    @Bindable var store: AppState
    let progress: SendProgress

    private var artifact: SendArtifact { progress.artifact }

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            if !hasFinalHistoryStatus { stageProgress }
            amountSummary
            if let terms = artifact.review.transferTerms { transferTerms(terms) }

            if showsImmediateNodeChoice { broadcastDestinations }

            VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
                SendTransferPartiesView(
                    store: store, walletId: artifact.walletId, chain: artifact.chainId,
                    sender: artifact.sender, recipient: artifact.recipient, memo: artifact.memo,
                    // Offered once the send is on record, named for what it sent;
                    // the sheet asks before anything is saved.
                    suggestedContactName: displayedTransaction.map { _ in
                        AppLocalization.format("%@ Recipient", artifact.symbol)
                    })
                // What the quote the send was built from estimated, as the
                // review put it. A receipt states the fee paid instead.
                if !hasFinalHistoryStatus, let fee = artifact.review.networkFee {
                    Divider().opacity(SpectraLayout.dividerOpacity)
                    SendCostRows(
                        fee: store.amounts.reviewedNetworkFee(fee, chain: artifact.chainId),
                        total: artifact.review.total.map {
                            "≈ " + store.amounts.formattedAssetAmount(
                                $0, symbol: artifact.symbol, deploymentId: artifact.chainId.entry?.nativeDeploymentId)
                        })
                }
            }
            .padding(SpectraLayout.cardPadding)
            .spectraCardFill()

            if artifact.attempts.isEmpty { ReviewWarnings(artifact: artifact) }

            if hasFinalHistoryStatus {
                transactionReceipt
                if !artifact.attempts.isEmpty {
                    DisclosureGroup(AppLocalization.string("View submission results")) {
                        submissionResults
                    }
                    .font(.subheadline.weight(.semibold))
                    .disclosureGroupStyle(.spectra)
                }
            } else if !artifact.attempts.isEmpty {
                submissionResults
            }

            technicalDetails
            stageNotice

            if showsRetryNodeChoice {
                DisclosureGroup(AppLocalization.string("Retry submission")) {
                    broadcastDestinations
                }
                .font(.subheadline.weight(.semibold))
                .disclosureGroupStyle(.spectra)
            }
        }
    }

    private var displayedTransaction: TransactionRecord? { progress.transaction }

    private var hasFinalHistoryStatus: Bool { progress.status.isSettled }

    private var broadcastDestinations: some View {
        BroadcastNodePicker(session: store.sendFlow.session)
            .padding(SpectraLayout.cardPadding)
            .spectraCardFill()
    }

    private var submissionResults: some View {
        SubmissionResults(progress: progress)
            .padding(SpectraLayout.cardPadding)
            .spectraCardFill()
    }

    /// Nodes are chosen up front when submitting is the next step.
    private var showsImmediateNodeChoice: Bool {
        progress.next == .broadcast || (progress.next == .rebroadcast && progress.canRebroadcast)
    }

    /// Otherwise a rebroadcast core allows waits behind a disclosure.
    private var showsRetryNodeChoice: Bool {
        progress.canRebroadcast && !showsImmediateNodeChoice
    }

    private var warnings: [String] { artifact.reviewWarningMessages }

    /// Where a stage stands. Each has its own symbol, as the composer's step
    /// bar does, so the current stage is not told from a waiting one by colour.
    private enum StageState { case done, current, waiting }

    private var stageProgress: some View {
        let signed = artifact.stage != .prepared
        let submitted = !artifact.attempts.isEmpty
        return HStack(alignment: .top, spacing: SpectraLayout.Space.s) {
            progressLabel("Built", state: .done)
            progressLabel(signed ? "Signed" : "Awaiting signing", state: signed ? .done : .current)
            progressLabel(
                submitted ? "Submitted" : "Awaiting submission",
                state: submitted ? .done : (signed ? .current : .waiting))
        }
        .padding(.vertical, SpectraLayout.Space.s)
        .accessibilityIdentifier("send.review.stages")
    }

    private func progressLabel(_ title: String, state: StageState) -> some View {
        VStack(spacing: SpectraLayout.Space.xs) {
            Image(systemName: state == .done ? "checkmark.circle.fill" : (state == .current ? "circle.inset.filled" : "circle"))
                .font(.subheadline.weight(.semibold))
                .accessibilityHidden(true)
            Text(AppLocalization.string(title))
                .font(.caption.weight(state == .current ? .semibold : .regular))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        // As the composer's step bar: what is done and what is current in
        // the accent, what is still to come in grey.
        .foregroundStyle(state == .waiting ? Color.secondary : Color.accentColor)
        .accessibilityElement(children: .combine)
        .accessibilityValue(state == .current ? AppLocalization.string("Current") : "")
    }

    private var amountSummary: some View {
        SendAmountSummaryView(
            artworkName: AssetHolding.nativeChainBadge(for: artifact.chainId)?.artworkName,
            symbol: artifact.symbol, chain: artifact.chainId, amount: artifact.amount,
            status: progress.status, isReceipt: progress.status == .confirmed)
    }

    /// What the token's own rules do between the sender and the recipient.
    private func transferTerms(_ terms: AssetTransferTerms) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            if terms.fee != "0" {
                LabeledContent(AppLocalization.string("Token Fee"),
                               value: AmountPresentation.exactAmount(terms.fee, symbol: artifact.symbol))
                Divider().opacity(SpectraLayout.dividerOpacity)
                LabeledContent(AppLocalization.string("Recipient Receives"),
                               value: AmountPresentation.exactAmount(terms.received, symbol: artifact.symbol))
            }
            if let carried = terms.carriedNative {
                if terms.fee != "0" { Divider().opacity(SpectraLayout.dividerOpacity) }
                LabeledContent(AppLocalization.string("Sent With It"),
                               value: AmountPresentation.exactAmount(carried, symbol: artifact.chainId.gasTokenSymbol))
            }
            if let registration = terms.recipientRegistration {
                if terms.fee != "0" || terms.carriedNative != nil { Divider().opacity(SpectraLayout.dividerOpacity) }
                LabeledContent(AppLocalization.string("Recipient Registration"),
                               value: AmountPresentation.exactAmount(registration, symbol: artifact.chainId.gasTokenSymbol))
            }
            if let program = terms.hookProgram {
                if terms.fee != "0" || terms.carriedNative != nil || terms.recipientRegistration != nil {
                    Divider().opacity(SpectraLayout.dividerOpacity)
                }
                VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
                    Label(AppLocalization.string("This token runs a program on every transfer, which can refuse it."),
                          systemImage: "gearshape.2")
                        .foregroundStyle(.spectraWarning)
                    Text(verbatim: program)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                }
            }
        }
        .font(.subheadline)
        .padding(SpectraLayout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }

    @ViewBuilder
    private var transactionReceipt: some View {
        if let record = displayedTransaction {
            VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
                LabeledContent(
                    AppLocalization.string(record.status == .confirmed ? "On-chain status" : "Status"),
                    value: record.status.localizedTitle)
                    .font(.subheadline)
                if let reason = record.localizedFailureReason {
                    Text(reason).font(.subheadline).foregroundStyle(.red)
                }
                if let fee = store.amounts.receiptNetworkFeeText(for: record)
                    ?? store.amounts.confirmedNetworkFeeText(for: record) {
                    Divider().opacity(SpectraLayout.dividerOpacity)
                    LabeledContent(AppLocalization.string("Network Fee"), value: fee)
                        .font(.subheadline)
                }
                if let hash = record.transactionHash ?? artifact.transactionHash {
                    Divider().opacity(SpectraLayout.dividerOpacity)
                    TransactionHashRow(hash: hash)
                }
                if let explorer = record.explorerLink {
                    Link(destination: explorer.url) {
                        Label(explorer.label, systemImage: "safari")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpectraLayout.Space.s)
                    }
                    .buttonStyle(.glass)
                }
            }
            .padding(SpectraLayout.cardPadding)
            .spectraCardFill()
        }
    }

    private var technicalDetails: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            DisclosureGroup(AppLocalization.string("Transaction details")) {
                VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
                    preparedFieldRows
                    technicalValue("Review digest", value: artifact.reviewDigest)
                    if !artifact.signingPayloadHex.isEmpty {
                        technicalValue("Signing payload", value: artifact.signingPayloadHex)
                    }
                    if !artifact.attempts.isEmpty, !warnings.isEmpty {
                        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
                            Text(AppLocalization.string("Review warnings"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            ReviewWarnings(artifact: artifact)
                        }
                    }
                }
            }
            if let payload = artifact.signedPayload {
                DisclosureGroup(AppLocalization.string("Signed payload")) {
                    technicalText(payload)
                }
            }
        }
        .font(.subheadline.weight(.semibold))
        .disclosureGroupStyle(.spectra)
    }

    /// The prepared transaction field by field, exactly as it will be
    /// signed: core's names and base units, never re-rounded here.
    private var preparedFieldRows: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
            Text(AppLocalization.string("Prepared transaction")).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            VStack(spacing: 0) {
                let fields = preparedFields(preparedDetails: artifact.preparedDetails)
                ForEach(Array(fields.enumerated()), id: \.offset) { index, field in
                    if index > 0 { Divider().opacity(SpectraLayout.dividerOpacity) }
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .firstTextBaseline, spacing: SpectraLayout.Space.m) {
                            fieldName(field.name)
                            Spacer(minLength: SpectraLayout.Space.s)
                            fieldValue(field.value).fixedSize()
                        }
                        VStack(alignment: .leading, spacing: SpectraLayout.Space.xxs) {
                            fieldName(field.name)
                            fieldValue(field.value).fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, SpectraLayout.Space.s)
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(.horizontal, SpectraLayout.Space.m)
            .spectraInsetFill()
        }
    }

    @ViewBuilder
    private func fieldName(_ name: String) -> some View {
        if !name.isEmpty {
            Text(verbatim: name).font(.caption.monospaced()).foregroundStyle(.secondary)
        }
    }

    private func fieldValue(_ value: String) -> some View {
        Text(verbatim: breakableAnywhere(value)).font(.caption.monospaced().weight(.regular))
            .accessibilityLabel(Text(verbatim: value))
    }

    private func technicalValue(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
            Text(AppLocalization.string(title)).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            technicalText(value)
        }
    }

    /// A digest or payload: wrapped anywhere, so no hyphen appears in it, and
    /// copied whole from its button, since the wrapped text is not the value.
    private func technicalText(_ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: SpectraLayout.Space.s) {
            Text(verbatim: breakableAnywhere(value))
                .font(.caption.monospaced().weight(.regular))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(Text(verbatim: value))
            CopyButton(value: value)
        }
    }

    @ViewBuilder
    private var stageNotice: some View {
        if artifact.stage == .prepared {
            Label(AppLocalization.string("Review the complete addresses. Signing and broadcasting remain separate actions."), systemImage: "checkmark.shield")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else if !hasFinalHistoryStatus, !artifact.attempts.isEmpty {
            VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
                if progress.status == .awaitingConfirmation {
                    Label(AppLocalization.string("Node acceptance is not on-chain confirmation."), systemImage: "clock")
                        .foregroundStyle(.spectraWarning)
                }
                Label(AppLocalization.string("Transaction saved. You can close this screen and check its status in transaction history."), systemImage: "info.circle")
                    .foregroundStyle(.secondary)
                if let pendingText = store.pendingTransactionRefreshStatusText {
                    Text(pendingText).foregroundStyle(.secondary)
                }
            }
            .font(.caption)
        }
    }

}
