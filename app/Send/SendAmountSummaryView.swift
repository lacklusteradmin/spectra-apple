import SpectraCore
import SwiftUI

/// Amounts supplied by the reviewed preview or immutable artifact, without a new quote.
struct SendAmountSummaryView: View {
    let symbol: String
    let chain: Chain
    let amount: String
    var fiatText: String? = nil
    /// Where a staged transaction stands; `nil` before one is built.
    var status: SendStatus? = nil
    var isReceipt = false

    var body: some View {
        VStack(spacing: SpectraLayout.Space.m) {
            if isReceipt, let status {
                Image(systemName: status.systemImage)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(status.color)
                    .frame(width: 64, height: 64)
                    .spectraInsetFill()
                    .accessibilityHidden(true)
                Text(status.title)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
            } else {
                networkLabel
            }

            // Every digit remains available during signing review, including amounts
            // too long for one line at the reader's chosen text size.
            Text("\(Text(verbatim: AmountPresentation.localizedDecimal(amount)).font(.largeTitle.weight(.semibold))) \(Text(verbatim: symbol).font(.title2.weight(.medium)).foregroundStyle(.secondary))")
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("send.review.amount")

            if let fiatText {
                Text(verbatim: fiatText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            if isReceipt {
                networkLabel
            } else if let status {
                Label(status.title, systemImage: status.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(status.color)
                    .padding(.horizontal, SpectraLayout.Space.s)
                    .padding(.vertical, SpectraLayout.Space.xs)
                    .spectraInsetFill(cornerRadius: SpectraLayout.Radius.inner)
                    .accessibilityIdentifier("send.review.status")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(SpectraLayout.Space.xl)
        .spectraElevatedFill()
    }

    private var networkLabel: some View {
        HStack(spacing: SpectraLayout.Space.s) {
            CoinBadge(
                artworkName: chain.entry?.artworkName, fallbackText: chain.displayName,
                color: chain.entry?.color.color ?? .gray, size: 24, kind: .chain)
                .accessibilityHidden(true)
            Text(verbatim: chain.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
