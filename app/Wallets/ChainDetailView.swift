import SpectraCore
import SwiftUI

/// What a chain is, for a reader, opened from the network's page in Add
/// Wallet. A testnet shows its mainnet's description, as core gives it.
struct ChainDetailView: View {
    let chain: Chain
    var body: some View {
        if let entry = chain.entry {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: SpectraLayout.Space.m) {
                    heroCard(entry)
                    identityCard(entry)
                }
                .spectraScreenPadding()
            }
            .background(SpectraBackdrop().ignoresSafeArea())
            .navigationTitle(entry.name).inlineNavigationTitle()
            .clearNavigationBar()
        }
    }

    private func heroCard(_ entry: ChainEntry) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            HStack(spacing: SpectraLayout.Space.m) {
                CoinBadge(artworkName: entry.artworkName, fallbackText: entry.coinSymbol, color: entry.color.color, size: 52)
                Text(entry.name).font(.title3.weight(.semibold))
                Spacer(minLength: 0)
            }
            Text(entry.description).font(.subheadline).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpectraLayout.Space.xs) {
                    ForEach(entry.tags, id: \.self) { tag in
                        Text(tag.title).font(.caption.weight(.semibold)).foregroundStyle(entry.color.color)
                            .padding(.horizontal, SpectraLayout.Space.s).padding(.vertical, SpectraLayout.Space.xs)
                            .background(entry.color.color.opacity(0.14), in: Capsule())
                    }
                }
            }
        }
        .padding(SpectraLayout.Space.l).frame(maxWidth: .infinity, alignment: .leading)
        .spectraElevatedFill()
    }

    private func identityCard(_ entry: ChainEntry) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            SpectraValueRow(systemImage: "link.circle.fill", label: AppLocalization.string("Family"), value: entry.family)
            Divider().opacity(SpectraLayout.dividerOpacity)
            SpectraValueRow(systemImage: "checkmark.shield.fill", label: AppLocalization.string("Consensus"), value: entry.consensus)
            Divider().opacity(SpectraLayout.dividerOpacity)
            SpectraValueRow(systemImage: "cylinder.split.1x2.fill", label: AppLocalization.string("State Model"), value: entry.stateModel)
        }
        .padding(SpectraLayout.Space.l).frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }
}
