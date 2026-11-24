import SwiftUI

/// The question a flow's page asks, over what answers it: Send's steps and
/// Receive's wallet list.
@MainActor
struct FlowPageHeading: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
            Text(title).font(.title.weight(.bold))
            if let subtitle {
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, SpectraLayout.Space.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
