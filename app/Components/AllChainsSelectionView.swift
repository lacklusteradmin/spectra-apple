import SpectraCore
import SwiftUI

/// Every chain in one list, ordered by popularity or name and narrowed by a
/// tag filter and a search. Test networks join the list from the toolbar
/// menu, beside the sort: an option for the few who want them, not a card
/// every user reads past.
///
/// Self-contained — takes its dependencies as bindings/closures and doesn't
/// reach into AppState. Callers pass the descriptors in popular order, the
/// chosen chain, if any, what picking one does, and optionally a footer under
/// the list.
struct AllChainsSelectionView<Footer: View>: View {
    @Binding var chainSearchText: String
    let title: String
    let descriptors: [ChainSelectionDescriptor]
    let selectedChains: Set<Chain>
    /// A navigation list marks rows with a chevron; a choice marks the
    /// chosen row.
    var accessory: ChainSelectionRow.Accessory = .checkmark
    let toggleSelection: (Chain) -> Void
    @ViewBuilder var footer: () -> Footer
    @State private var order: ChainPickerOrder = .popular
    @State private var filter: ChainPickerFilter = .all
    @State private var showsTestNetworks = false
    private var trimmedQuery: String { chainSearchText.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var rows: [ChainSelectionDescriptor] {
        descriptors.picked(filter: filter, query: trimmedQuery, order: order, showsTestNetworks: showsTestNetworks)
    }
    /// "All", then every tag some row carries. Test networks are the switch's,
    /// not a filter's.
    private var filters: [ChainPickerFilter] {
        let tags = ChainTag.pickerOrder.filter { tag in
            tag != .testnet && descriptors.contains { $0.tags.contains(tag) }
        }
        return [.all] + tags.map { .tag($0) }
    }
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer(spacing: SpectraLayout.Space.s) {
                HStack(spacing: SpectraLayout.Space.s) {
                    ForEach(filters, id: \.self) { item in filterChip(item) }
                }
                .padding(.horizontal, SpectraLayout.screenHorizontal)
                .padding(.vertical, SpectraLayout.Space.xs)
            }
        }
        .scrollClipDisabled()
    }
    @ViewBuilder
    private func filterChip(_ item: ChainPickerFilter) -> some View {
        let label = Text(item.title).font(.subheadline.weight(.semibold))
        if filter == item {
            Button { filter = item } label: { label }.buttonStyle(.glassProminent)
        } else {
            Button { filter = item } label: { label }.buttonStyle(.glass)
        }
    }
    @ViewBuilder
    private var list: some View {
        if !rows.isEmpty {
            SpectraRowGroup(data: rows) { descriptor in
                ChainSelectionRow(
                    descriptor: descriptor, isSelected: selectedChains.contains(descriptor.id), accessory: accessory
                ) { toggleSelection(descriptor.id) }
            }
        } else if !trimmedQuery.isEmpty {
            ContentUnavailableView.search(text: trimmedQuery)
        } else {
            ContentUnavailableView(
                AppLocalization.string("import_flow.no_chains_selected"), systemImage: "checkmark.circle")
        }
    }
    private var toolbarMenu: some View {
        Menu {
            Picker(AppLocalization.string("Sort"), selection: $order) {
                Label(AppLocalization.string("Popular"), systemImage: "flame").tag(ChainPickerOrder.popular)
                Label(AppLocalization.string("Name"), systemImage: "textformat").tag(ChainPickerOrder.name)
            }
            Toggle(isOn: $showsTestNetworks) {
                Label(AppLocalization.string("Show test networks"), systemImage: "testtube.2")
            }
            // The app-wide switch style has no menu form; `.automatic` is the
            // checkmark item.
            .toggleStyle(.automatic)
        } label: {
            Image(systemName: showsTestNetworks ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel(AppLocalization.string("Sort and Filter"))
    }
    var body: some View {
        ZStack {
            SpectraBackdrop().ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
                    filterBar.padding(.horizontal, -SpectraLayout.screenHorizontal)
                    list
                    footer()
                }
                .spectraScreenPadding()
            }
        }
        .navigationTitle(title)
        .inlineNavigationTitle()
        .clearNavigationBar()
        .searchable(
            text: $chainSearchText, placement: .alwaysVisible,
            prompt: AppLocalization.string("import_flow.search_chains")
        )
        .textInputAutocapitalization(.never).autocorrectionDisabled()
        .sensoryFeedback(.selection, trigger: filter)
        .sensoryFeedback(.selection, trigger: order)
        .sensoryFeedback(.selection, trigger: showsTestNetworks)
        .toolbar {
            ToolbarItem(placement: .barTrailing) { toolbarMenu }
        }
    }
}

extension AllChainsSelectionView where Footer == EmptyView {
    init(
        chainSearchText: Binding<String>, title: String, descriptors: [ChainSelectionDescriptor],
        selectedChains: Set<Chain>, toggleSelection: @escaping (Chain) -> Void
    ) {
        self.init(
            chainSearchText: chainSearchText, title: title, descriptors: descriptors, selectedChains: selectedChains,
            toggleSelection: toggleSelection, footer: { EmptyView() })
    }
}
