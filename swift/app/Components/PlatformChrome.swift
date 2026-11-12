import SwiftUI

// The bars around a page, said once for both platforms: iOS has a navigation
// bar and a tab bar, a Mac a window toolbar and a sidebar.

extension View {
    /// The title in the bar rather than large above the content. A Mac's
    /// title is always in its toolbar.
    func inlineNavigationTitle() -> some View {
        #if os(macOS)
            self
        #else
            navigationBarTitleDisplayMode(.inline)
        #endif
    }

    /// No background behind the bar, so content scrolls beneath it.
    func clearNavigationBar() -> some View {
        #if os(macOS)
            toolbarBackground(.hidden, for: .windowToolbar)
        #else
            toolbarBackground(.hidden, for: .navigationBar)
        #endif
    }

    /// A flow takes the tab bar away for as long as it is on screen. A Mac's
    /// tabs are its sidebar, which stays.
    func hidesTabBar() -> some View {
        #if os(macOS)
            self
        #else
            toolbar(.hidden, for: .tabBar)
        #endif
    }
}

extension View {
    /// A page the user can ask to read again: pulled down on iOS. A Mac has
    /// no pull, so the page's toolbar carries a Refresh button, also ⌘R.
    func pageRefreshable(action: @escaping @Sendable () async -> Void) -> some View {
        #if os(macOS)
            modifier(ToolbarRefresh(action: action))
        #else
            refreshable(action: action)
        #endif
    }

    /// A sheet holding a page. A Mac sheet is as large as its content asks
    /// to be, and a scrolling page asks for nothing, so there the content is
    /// given a page's size; iOS sizes its sheets itself.
    func pageSheet<Content: View>(
        isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        sheet(isPresented: isPresented, onDismiss: onDismiss) { content().sheetPageFrame() }
    }

    /// A sheet holding a page about `item`; see `pageSheet(isPresented:)`.
    func pageSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        sheet(item: item, onDismiss: onDismiss) { content($0).sheetPageFrame() }
    }

    private func sheetPageFrame() -> some View {
        #if os(macOS)
            frame(width: 520).frame(minHeight: 420, idealHeight: 620, maxHeight: 760)
        #else
            self
        #endif
    }
}

#if os(macOS)
    private struct ToolbarRefresh: ViewModifier {
        let action: @Sendable () async -> Void
        @State private var isRefreshing = false

        func body(content: Content) -> some View {
            content.toolbar {
                ToolbarItem {
                    Button(AppLocalization.string("Refresh"), systemImage: "arrow.clockwise") {
                        Task {
                            isRefreshing = true
                            await action()
                            isRefreshing = false
                        }
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    .disabled(isRefreshing)
                }
            }
        }
    }
#endif

extension View {
    /// A button that is a whole row of a `Form`: its label is the row. A Mac
    /// draws a default button as a bezel, which would run the width of the
    /// row; iOS draws none.
    func formRowButtonStyle() -> some View {
        #if os(macOS)
            buttonStyle(.plain)
        #else
            self
        #endif
    }
}

extension SearchFieldPlacement {
    /// A search field that is always on screen: the drawer under the bar on
    /// iOS, where a field would otherwise hide until pulled; a Mac's toolbar
    /// shows its field at all times.
    static var alwaysVisible: SearchFieldPlacement {
        #if os(macOS)
            .toolbar
        #else
            .navigationBarDrawer(displayMode: .always)
        #endif
    }
}

extension ToolbarItemPlacement {
    /// The leading end of the bar: beside Back on iOS, and on a Mac where
    /// the toolbar keeps navigation.
    static var barLeading: ToolbarItemPlacement {
        #if os(macOS)
            .navigation
        #else
            .topBarLeading
        #endif
    }

    /// The trailing end of the bar, where a page's own actions go.
    static var barTrailing: ToolbarItemPlacement {
        #if os(macOS)
            .primaryAction
        #else
            .topBarTrailing
        #endif
    }
}
