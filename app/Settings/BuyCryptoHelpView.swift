import Foundation
import SwiftUI

struct BuyCryptoHelpView: View {

    /// Resolve once per process to keep row identities stable during balance
    /// and price updates; replacing a row mid-tap can prevent its link firing.
    private static let directory = BuyProviders.current

    private func section(_ title: String, _ note: String, _ providers: [BuyProviderSeed]) -> some View {
        Section {
            Text(note).font(.caption).foregroundStyle(.secondary)
            ForEach(providers) { provider in
                if let url = URL(string: provider.url) {
                    Link(destination: url) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: SpectraLayout.Space.xxs) {
                                Text(provider.name).font(.body)
                                Text(provider.label)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: SpectraLayout.Space.m)
                            Image(systemName: "arrow.up.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            Text(title)
        }
    }

    var body: some View {
        Form {
            Section {
                Text(AppLocalization.string("settings.buyProvidersIntro")).font(.caption).foregroundStyle(.secondary)
            }
            section(
                AppLocalization.string("On-ramps"), AppLocalization.string("settings.buyOnrampNote"), Self.directory.onramps)
            section(
                AppLocalization.string("Exchanges"), AppLocalization.string("settings.buyExchangeNote"), Self.directory.exchanges)
            Section(AppLocalization.string("Reminder")) {
                Text(AppLocalization.string("settings.buyWarning")).font(.caption).foregroundStyle(.secondary)
                Text(AppLocalization.string("settings.buyListingNote")).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle(AppLocalization.string("Where can I buy crypto?"))
    }
}
