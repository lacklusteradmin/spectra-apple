import SwiftUI

/// A label and its value: an optional accent symbol, a secondary label and a
/// primary value. Every detail card, review and summary lists its facts in
/// these rows.
///
/// Side by side when both fit on one line, otherwise the value goes under
/// the label — neither is squeezed, so a value such as
/// `core.submission_json`, which has no space to wrap at, is never
/// hyphenated, and every digit of a fee stays on screen. Always stacked at
/// accessibility sizes. An identifier — a hash or an address — is the
/// exception: it keeps the line beside its label and is cut in the middle so
/// both ends show; the row holding it copies it in full.
struct SpectraValueRow: View {
    enum Style {
        /// Words or a figure, its digits of equal width so a column of
        /// amounts lines up.
        case text
        /// A hash, an address or another id: monospaced, on one line, in
        /// groups of four with the first and last primary.
        case identifier
    }

    var systemImage: String? = nil
    let label: String
    let value: String
    var style: Style = .text
    /// A balance the person has hidden: the value is masked as `BalanceText`
    /// masks one.
    var isHidden = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        content.accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var content: some View {
        switch style {
        case .identifier:
            HStack(alignment: .firstTextBaseline, spacing: SpectraLayout.Space.m) {
                labelView.layoutPriority(1)
                Spacer(minLength: SpectraLayout.Space.m)
                Text(groupedAddress(value)).font(.subheadline.monospaced())
                    .lineLimit(1).truncationMode(.middle)
            }
        case .text where dynamicTypeSize.isAccessibilitySize:
            stacked
        case .text:
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: SpectraLayout.Space.m) {
                    labelView.fixedSize()
                    Spacer(minLength: SpectraLayout.Space.m)
                    valueText.fixedSize()
                }
                stacked
            }
        }
    }

    private var labelView: some View {
        HStack(spacing: SpectraLayout.Space.s) {
            if let systemImage {
                Image(systemName: systemImage).font(.subheadline.weight(.semibold)).foregroundStyle(.tint)
                    .frame(width: Self.symbolWidth)
            }
            Text(label).font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var valueText: some View {
        BalanceText(text: value, isHidden: isHidden)
            .font(.subheadline.weight(.semibold)).monospacedDigit().foregroundStyle(.primary)
    }

    /// The value under the label, lined up with the label's text rather than
    /// its symbol.
    private var stacked: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.xxs) {
            labelView
            valueText.fixedSize(horizontal: false, vertical: true)
                .padding(.leading, systemImage == nil ? 0 : Self.symbolWidth + SpectraLayout.Space.s)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private static let symbolWidth: CGFloat = 22
}
