#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// Put plain text on the general pasteboard: an address, a hash, a log.
/// A secret goes through `copySecretToPasteboard` instead.
@MainActor
func copyToPasteboard(_ string: String) {
    #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    #else
        UIPasteboard.general.string = string
    #endif
}
