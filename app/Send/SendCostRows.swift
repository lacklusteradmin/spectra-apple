import SwiftUI

/// The fee and what leaves the wallet, under a transfer's parties: one style
/// on the review and on the built transaction, so the same fee does not read
/// as two different things a page apart.
struct SendCostRows: View {
    let fee: String
    /// The amount and the fee together, when the fee is paid in the sent asset.
    var total: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
            SpectraValueRow(label: "Network Fee", value: fee)
            if let total {
                SpectraValueRow(label: "Total", value: total)
            }
        }
    }
}
