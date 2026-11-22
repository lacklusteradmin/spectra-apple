import SwiftUI

@main
struct SpectraApp: App {
    @State private var store = AppState()

    var body: some Scene {
        #if os(macOS)
            // One window, not a group: the app has one `AppState`, and its
            // tabs and flows are that state's. Closing the window quits.
            Window(AppLocalization.string("Spectra"), id: "main") {
                ContentView(store: store).toggleStyle(AccentSwitchToggleStyle())
                    // The settings pages are grouped rows, as on iOS, rather
                    // than a Mac form's columns; and a field draws no bezel
                    // of its own inside the card or row that holds it.
                    .formStyle(.grouped)
                    .textFieldStyle(.plain)
                    .frame(minWidth: 560, minHeight: 620)
            }
            .defaultSize(width: 1040, height: 780)
            .commands {
                // The settings are a tab of the window; ⌘, goes to it.
                CommandGroup(replacing: .appSettings) {
                    Button(AppLocalization.string("Settings…")) { store.selectedMainTab = .settings }
                        .keyboardShortcut(",", modifiers: .command)
                }
            }
        #else
            WindowGroup {
                ContentView(store: store).toggleStyle(AccentSwitchToggleStyle())
            }
        #endif
    }
}

/// The asset catalog's AccentColor (system orange) is the app's one theme
/// colour, and most controls read it on their own. A switch's on state does
/// not — it stays system green. A root `.tint` would fix that but also colours
/// the toolbar glyphs, which stay monochrome; a toggle style reaches only
/// toggles. `UISwitch.appearance()` did too, but SwiftUI re-applies its own
/// tint when a toggle re-renders, so a switch turned green after an update.
///
/// A Mac's switch sits beside its label wherever the label ends. A row here
/// ends in its switch, as on iOS, so there the style lays the row out itself.
private struct AccentSwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        #if os(macOS)
            HStack(spacing: SpectraLayout.Space.s) {
                configuration.label
                Spacer(minLength: SpectraLayout.Space.s)
                Toggle(configuration).labelsHidden().toggleStyle(.switch).tint(.accentColor)
            }
        #else
            Toggle(configuration).toggleStyle(.switch).tint(.accentColor)
        #endif
    }
}
