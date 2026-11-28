import Foundation
import SpectraCore
import SwiftUI

/// One known token: what it is, where its price comes from and every network
/// it is on. A token the user added can be edited and removed here.
struct TokenRegistryDetailView: View {
    let tokens: TokenPreferencesState
    let tokenId: String
    @State private var isShowingRemoveConfirmation = false
    @Environment(\.dismiss) private var dismiss
    private var token: KnownToken? {
        tokens.tokens.first { $0.tokenId == tokenId }
    }
    var body: some View {
        Group {
            if let token {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: SpectraLayout.sectionSpacing) {
                        heroCard(token)
                        if !token.supply.isEmpty {
                            circulationCard(token)
                        }
                        if let error = tokens.error {
                            TokenPreferenceErrorNotice(message: error) { tokens.error = nil }
                        }
                        spectraDetailCard(title: AppLocalization.string("Price Sources")) {
                            providerRow("CoinGecko", id: token.coingeckoId)
                            Divider().opacity(SpectraLayout.dividerOpacity)
                            providerRow("CoinPaprika", id: token.coinpaprikaId)
                        }
                        networksCard(token)
                        if !token.isBuiltIn {
                            Button(role: .destructive) {
                                isShowingRemoveConfirmation = true
                            } label: {
                                Label(AppLocalization.string("Remove Token"), systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.glass).tint(.red).controlSize(.large)
                        }
                    }
                    .spectraScreenPadding()
                }
                .background(SpectraBackdrop().ignoresSafeArea())
                .clearNavigationBar()
                .navigationTitle(token.symbol)
                .inlineNavigationTitle()
                .toolbar {
                    if !token.isBuiltIn {
                        ToolbarItem(placement: .barTrailing) {
                            NavigationLink(AppLocalization.string("Edit")) {
                                AddCustomTokenView(tokens: tokens, editing: token.deployments[0])
                            }
                        }
                    }
                }
                .confirmationDialog(AppLocalization.string("Remove Token"), isPresented: $isShowingRemoveConfirmation,
                    titleVisibility: .visible) {
                    Button(AppLocalization.string("Remove"), role: .destructive) { tokens.removeCustom(token.deployments[0]) }
                    Button(AppLocalization.string("Cancel"), role: .cancel) {}
                } message: {
                    Text(AppLocalization.string("This custom token will be removed and will no longer appear in your portfolio."))
                }
                .onAppear { tokens.error = nil }
            } else {
                ContentUnavailableView(AppLocalization.string("Token Not Found"), systemImage: "questionmark.circle")
            }
        }
        .onChange(of: token == nil) { _, missing in
            if missing { dismiss() }
        }
    }

    private func heroCard(_ token: KnownToken) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            HStack(spacing: SpectraLayout.Space.m) {
                CoinBadge(artworkName: token.artworkName, fallbackText: token.fallbackMark, color: token.badgeTint, size: 52)
                VStack(alignment: .leading, spacing: SpectraLayout.Space.xxs) {
                    Text(token.name).font(.title3.weight(.semibold))
                    Text(token.symbol).font(.subheadline.monospaced()).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                TokenSourceTag(isBuiltIn: token.isBuiltIn)
            }
            if !token.description.isEmpty {
                Text(token.description).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !token.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SpectraLayout.Space.xs) {
                        ForEach(token.tags, id: \.self) { tag in
                            Text(tag.title)
                                .font(.caption.weight(.semibold)).foregroundStyle(token.badgeTint)
                                .padding(.horizontal, SpectraLayout.Space.s).padding(.vertical, SpectraLayout.Space.xs)
                                .background(token.badgeTint.opacity(0.14), in: Capsule())
                        }
                    }
                }
            }
        }
        .padding(SpectraLayout.cardPadding).frame(maxWidth: .infinity, alignment: .leading)
        .spectraElevatedFill()
    }

    /// How the coin's supply is bounded, where the catalog states a model.
    private func circulationCard(_ token: KnownToken) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
            HStack(spacing: SpectraLayout.Space.s) {
                Image(systemName: "chart.bar.fill")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(.tint).frame(width: 22)
                Text(AppLocalization.string("Circulation Model"))
                    .font(.subheadline.weight(.semibold)).foregroundStyle(Color.primary)
            }
            Text(token.supply).font(.subheadline).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true).padding(.leading, SpectraLayout.Space.xl)
        }
        .padding(SpectraLayout.cardPadding).frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }

    private func networksCard(_ token: KnownToken) -> some View {
        spectraDetailCard(title: AppLocalization.string("Networks")) {
            ForEach(Array(token.deployments.enumerated()), id: \.element.deploymentId) { index, entry in
                TokenRegistryNetworkRow(entry: entry)
                if index < token.deployments.count - 1 { Divider().opacity(SpectraLayout.dividerOpacity) }
            }
        }
    }

    private func providerRow(_ name: String, id: String) -> some View {
        LabeledContent(name) {
            Text(id.isEmpty ? AppLocalization.string("Not Configured") : id)
                .foregroundStyle(id.isEmpty ? .secondary : .primary).textSelection(.enabled)
                .lineLimit(1).truncationMode(.middle)
        }
        .font(.subheadline)
    }
}
