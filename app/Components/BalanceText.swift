import SwiftUI

/// A balance — an amount held, or what it is worth — or a mask while Hide
/// Balances is on. The mask reads "Hidden" to VoiceOver, not six bullets.
/// A price is public and never goes through this.
struct BalanceText: View {
    let text: String
    let isHidden: Bool
    /// The sentence the balance sits in, made from the balance or from the
    /// mask; the balance alone when `nil`.
    var sentence: ((String) -> String)? = nil

    var body: some View {
        if isHidden {
            Text(verbatim: phrase("••••••")).accessibilityLabel(phrase(AppLocalization.string("Hidden")))
        } else {
            Text(verbatim: phrase(text))
        }
    }

    private func phrase(_ value: String) -> String { sentence?(value) ?? value }
}

extension LabeledContent where Label == Text, Content == BalanceText {
    /// A row of a system list whose value is a balance.
    @MainActor
    init(_ title: String, balance: String, isHidden: Bool) {
        self.init { BalanceText(text: balance, isHidden: isHidden) } label: { Text(title) }
    }
}
