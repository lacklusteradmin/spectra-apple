import SpectraCore
import SwiftUI

/// A chain's own page, one level down from the coin that runs on it.
///
/// The wiki is indexed by coin — see `CryptoWikiViews.swift`. This is what has
/// no coin to belong to: ten chains share ETH, so "Base is an optimistic
/// rollup" cannot live on ETH's page. Reached from the wiki's Chains section
/// and a held asset's lives-on rows.
struct ChainWikiDetailView: View {
    let chain: ChainWikiEntry
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: SpectraLayout.Space.m) {
                wikiHeroCard
                wikiIdentityCard
            }
            .spectraScreenPadding()
        }
        .background(SpectraBackdrop().ignoresSafeArea())
        .navigationTitle(chain.name).inlineNavigationTitle()
        .clearNavigationBar()
    }

    private var wikiHeroCard: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {

            HStack(spacing: SpectraLayout.Space.m) {
                WikiCoinBadge(face: chain.face, size: 52)
                VStack(alignment: .leading, spacing: SpectraLayout.Space.xxs) {
                    Text(chain.name).font(.title3.weight(.semibold))
                }
                Spacer(minLength: 0)
            }
            Text(chain.comment).font(.subheadline).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if !chain.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SpectraLayout.Space.xs) {
                        ForEach(chain.tags, id: \.self) { tag in
                            Text(tag.title).font(.caption.weight(.semibold)).foregroundStyle(chain.face.color)
                                .padding(.horizontal, SpectraLayout.Space.s).padding(.vertical, SpectraLayout.Space.xs)
                                .background(chain.face.color.opacity(0.14), in: Capsule())
                        }
                    }
                }
            }
        }
        .padding(SpectraLayout.Space.l).frame(maxWidth: .infinity, alignment: .leading)
        .spectraElevatedFill()
    }

    private var wikiIdentityCard: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            SpectraValueRow(systemImage: "link.circle.fill", label: AppLocalization.string("Family"), value: chain.family)
            Divider().opacity(SpectraLayout.dividerOpacity)
            SpectraValueRow(systemImage: "checkmark.shield.fill", label: AppLocalization.string("Consensus"), value: chain.consensus)
            Divider().opacity(SpectraLayout.dividerOpacity)
            SpectraValueRow(systemImage: "cylinder.split.1x2.fill", label: AppLocalization.string("State Model"), value: chain.stateModel)
        }
        .padding(SpectraLayout.Space.l).frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }
}
