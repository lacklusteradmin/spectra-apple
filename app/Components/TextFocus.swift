#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// Take the keyboard from whatever field has it, wherever that field is: a
/// page about to be replaced cannot reach the field through its own focus
/// state.
@MainActor
func endTextEditing() {
    #if os(macOS)
        NSApp.keyWindow?.makeFirstResponder(nil)
    #else
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #endif
}
