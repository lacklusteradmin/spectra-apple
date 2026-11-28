import Foundation
import SpectraCore
import SwiftUI
struct TokenRegistrySettingsView: View {
    let tokens: TokenPreferencesState
    /// The chain filter; nil includes every chain. Every network's own coin
    /// is a known token, so every network is an option.
    private static let chainFilterOptions: [Chain?] = [nil] + Chain.all.map { Optional($0) }
    private enum TokenRegistrySourceFilter: CaseIterable, Identifiable {
        case all
        case builtIn
        case custom
        var id: Self { self }
        var title: String {
            switch self {
            case .all: return AppLocalization.string("All")
            case .builtIn: return AppLocalization.string("Built-In")
            case .custom: return AppLocalization.string("Custom")
            }
        }
    }
    @State private var searchText: String = ""
    @State private var chainFilter: Chain? = nil
    @State private var sourceFilter: TokenRegistrySourceFilter = .all
    @State private var tagFilter: TokenTag? = nil
    private var isFiltered: Bool { chainFilter != nil || sourceFilter != .all || tagFilter != nil }
    var body: some View {
        let groups = filteredTokens
        ZStack {
            SpectraBackdrop().ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: SpectraLayout.sectionSpacing) {
                    if let error = tokens.error {
                        TokenPreferenceErrorNotice(message: error) { tokens.error = nil }
                    }
                    if !groups.isEmpty {
                        SpectraRowGroup(data: groups) { token in
                            NavigationLink {
                                TokenRegistryDetailView(tokens: tokens, tokenId: token.tokenId)
                            } label: {
                                KnownTokenRowView(token: token)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .spectraScreenPadding()
            }
            .overlay { emptyState(isFilteredEmpty: groups.isEmpty) }
        }
        .navigationTitle(AppLocalization.string("Known Tokens"))
        .inlineNavigationTitle()
        .searchable(text: $searchText, prompt: AppLocalization.string("Search name, symbol, chain, or address"))
        .textInputAutocapitalization(.never).autocorrectionDisabled()
        .clearNavigationBar()
        .toolbar {
            ToolbarItem(placement: .barTrailing) {
                filterMenu
            }
            ToolbarItem(placement: .barTrailing) {
                NavigationLink {
                    AddCustomTokenView(tokens: tokens)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(AppLocalization.string("New Token"))
            }
        }
    }
    @ViewBuilder
    private func emptyState(isFilteredEmpty: Bool) -> some View {
        if tokens.tokens.isEmpty {
            ProgressView()
        } else if isFilteredEmpty {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ContentUnavailableView(
                    AppLocalization.string("No matching tokens."),
                    systemImage: "line.3.horizontal.decrease.circle",
                    description: Text(AppLocalization.string("No known tokens match the selected filters.")))
            } else {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }
    private var filterMenu: some View {
        Menu {
            Picker(AppLocalization.string("Network"), selection: $chainFilter) {
                ForEach(Self.chainFilterOptions, id: \.self) { chain in
                    Text(chain?.displayName ?? AppLocalization.string("All")).tag(chain)
                }
            }
            Picker(AppLocalization.string("Source"), selection: $sourceFilter) {
                ForEach(TokenRegistrySourceFilter.allCases) { filter in Text(filter.title).tag(filter) }
            }
            Picker(AppLocalization.string("Tag"), selection: $tagFilter) {
                Text(AppLocalization.string("All")).tag(TokenTag?.none)
                ForEach(TokenTag.filterOrder, id: \.self) { tag in Text(tag.title).tag(TokenTag?.some(tag)) }
            }
            if isFiltered {
                Button(AppLocalization.string("Clear Filters")) {
                    chainFilter = nil
                    sourceFilter = .all
                    tagFilter = nil
                }
            }
        } label: {
            Image(systemName: isFiltered
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel(AppLocalization.string("Filters"))
    }
    /// Core's list, in core's order, narrowed by the filters and the search.
    private var filteredTokens: [KnownToken] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return tokens.tokens.filter { token in
            if let selectedChain = chainFilter, !token.deployments.contains(where: { $0.chainId == selectedChain }) {
                return false
            }
            switch sourceFilter {
            case .all: break
            case .builtIn: guard token.isBuiltIn else { return false }
            case .custom: guard !token.isBuiltIn else { return false }
            }
            if let tagFilter, !token.tags.contains(tagFilter) { return false }
            guard !query.isEmpty else { return true }
            let haystack =
                ([token.symbol, token.name, token.coingeckoId, token.coinpaprikaId]
                + token.deployments.flatMap { entry in
                    [entry.chainId.displayName, entry.tokenStandard?.name ?? "", entry.contract]
                })
                .joined(separator: " ").lowercased()
            return haystack.contains(query)
        }
    }
}
