import SpectraCore
import SwiftUI

// The parts of a staged transaction's page that a send, a staking action and
// a wallet tool share: where it stands, the nodes it goes to and what they
// answered. Each page lays out its own review around them.

/// Where a staged transaction stands, as core says it: a word, a symbol and a
/// colour, never the colour alone.
extension SendStatus {
    var title: String {
        switch self {
        case .awaitingSignature: AppLocalization.string("Built, awaiting signing")
        case .signed: AppLocalization.string("Signed, not submitted")
        case .rejected: AppLocalization.string("Submission rejected")
        case .uncertain: AppLocalization.string("Submission uncertain")
        case .awaitingConfirmation: AppLocalization.string("Awaiting confirmation")
        case .confirmed: AppLocalization.string("Confirmed on-chain")
        case .failed: AppLocalization.string("Transaction failed")
        }
    }

    var systemImage: String {
        switch self {
        case .awaitingSignature: "doc.text"
        case .signed: "signature"
        case .awaitingConfirmation: "clock"
        case .confirmed: "checkmark"
        case .rejected, .uncertain, .failed: "exclamationmark.triangle"
        }
    }

    var color: Color {
        switch self {
        case .confirmed: .green
        case .rejected, .failed: .red
        case .awaitingSignature, .signed, .uncertain, .awaitingConfirmation: .spectraWarning
        }
    }

    /// The chain has answered: nothing the stages do changes it.
    var isSettled: Bool { self == .confirmed || self == .failed }
}

/// What a node said to a submission, as every send and staking page shows
/// it: a word, a symbol and a colour, never the colour alone.
extension SubmissionOutcome {
    var title: String {
        switch self {
        case .accepted: AppLocalization.string("Node accepted")
        case .rejected: AppLocalization.string("Node rejected")
        case .uncertain: AppLocalization.string("Submission uncertain")
        }
    }

    var systemImage: String {
        switch self {
        case .accepted: "checkmark.circle"
        case .rejected: "xmark.circle"
        case .uncertain: "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .accepted: .green
        case .rejected: .red
        case .uncertain: .spectraWarning
        }
    }
}

/// A staged transaction's status on one line.
struct SendStatusLabel: View {
    let status: SendStatus

    var body: some View {
        Label(status.title, systemImage: status.systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(status.color)
            .accessibilityIdentifier("send.status")
    }
}

/// The nodes a signed transaction is submitted to, chosen before each
/// submission. Only the chosen ones receive it from Spectra.
struct BroadcastNodePicker: View {
    let session: SendSession

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            Text(AppLocalization.string("Select submission nodes")).font(.headline)
            Text(AppLocalization.string("Signed and saved. Choose which nodes receive this transaction."))
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(spacing: 0) {
                ForEach(Array(session.endpoints.enumerated()), id: \.element) { index, endpoint in
                    if index > 0 { Divider().opacity(0.4) }
                    Toggle(isOn: Binding(
                        get: { session.selectedEndpoints.contains(endpoint) },
                        set: { selected in
                            if selected { session.selectedEndpoints.insert(endpoint) }
                            else { session.selectedEndpoints.remove(endpoint) }
                        }
                    )) {
                        Text(verbatim: endpoint)
                            .font(.caption.monospaced())
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, SpectraLayout.Space.s)
                    .disabled(session.isBusy)
                }
            }
            if session.selectedEndpoints.isEmpty {
                Label(AppLocalization.string("Select at least one node to submit this transaction."), systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.spectraWarning)
            }
            Text(AppLocalization.string("Only selected nodes receive this submission from Spectra. Those nodes may propagate the transaction to other nodes."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// What each node answered, with its details, and the hash the transaction
/// lands under until the chain has settled it.
struct SubmissionResults: View {
    let progress: SendProgress

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            Text(AppLocalization.string("Submission results")).font(.headline)
            ForEach(Array(progress.artifact.attempts.enumerated()), id: \.offset) { index, attempt in
                if index > 0 { Divider().opacity(0.4) }
                VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
                    Text(verbatim: attempt.endpoint)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                    Label(attempt.outcome.title, systemImage: attempt.outcome.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(attempt.outcome.color)
                    DisclosureGroup(AppLocalization.string("Submission details")) {
                        Text(verbatim: attempt.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let hash = attempt.transactionHash {
                            TransactionHashRow(hash: hash)
                        }
                    }
                    .font(.caption)
                    .disclosureGroupStyle(.spectra)
                }
            }
            if !progress.status.isSettled,
               let hash = progress.transaction?.transactionHash ?? progress.artifact.transactionHash {
                Divider().opacity(0.4)
                TransactionHashRow(hash: hash)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A transaction hash, grouped for reading and copied whole from its button.
struct TransactionHashRow: View {
    let hash: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
            Text(AppLocalization.string("Transaction Hash"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: SpectraLayout.Space.s) {
                Text(groupedAddress(hash))
                    .font(.caption.monospaced())
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel(Text(verbatim: hash))
                CopyButton(value: hash)
            }
        }
    }
}
