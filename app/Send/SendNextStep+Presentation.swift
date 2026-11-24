import Foundation
import SpectraCore

/// The labels of core's next step for a staged transaction. Core decides the
/// step; an acceptance receipt is never evidence that a transaction confirmed.
extension SendNextStep {
    var title: String {
        switch self {
        case .sign: "Sign Transaction"
        case .broadcast: "Broadcast Transaction"
        case .rebroadcast: "Retry Same Transaction"
        case .done: "Done"
        }
    }

    var systemImage: String {
        switch self {
        case .sign: "signature"
        case .broadcast: "antenna.radiowaves.left.and.right"
        case .rebroadcast: "arrow.clockwise"
        case .done: "checkmark"
        }
    }
}

/// What a signing confirmation states, for a send and a staking action
/// alike: the amount, the reviewed fee with its bound, the recipient and every
/// review warning. `action` heads a staking action's: what it does, and to
/// which validator.
@MainActor
func sendSigningConfirmationMessage(
    artifact: SendArtifact, amounts: AmountPresentation, action: String? = nil
) -> String {
    var lines = action.map { [$0] } ?? []
    lines.append(
        "\(AmountPresentation.exactAmount(artifact.amount, symbol: artifact.symbol)) · \(artifact.chainId.displayName)")
    if let fee = artifact.review.networkFee {
        lines.append(AppLocalization.format("Network Fee: %@", amounts.reviewedNetworkFee(fee, chain: artifact.chainId)))
    }
    lines += [
        AppLocalization.string("Recipient"),
        artifact.recipient,
        "",
        AppLocalization.string("Signing authorizes this transaction. You will choose nodes and broadcast it separately.")
    ]
    let warnings = artifact.reviewWarningMessages
    if !warnings.isEmpty { lines.append("\n• " + warnings.joined(separator: "\n• ")) }
    return lines.joined(separator: "\n")
}
