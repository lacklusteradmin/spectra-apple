import Testing

@testable import Spectra

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

@MainActor
struct SecretPasteboardTests {
    /// A copied phrase is on the pasteboard as plain text, so the setup
    /// page's paste button reads it back whole.
    @Test func aCopiedSecretReadsBackAsText() throws {
        #if os(macOS)
            let pasteboard = NSPasteboard(name: NSPasteboard.Name("spectra.tests.\(UUID())"))
            defer { pasteboard.releaseGlobally() }
            copySecretToPasteboard("legal winner thank year", pasteboard: pasteboard)
            #expect(pasteboard.string(forType: .string) == "legal winner thank year")
        #else
            let pasteboard = try #require(UIPasteboard(name: UIPasteboard.Name("spectra.tests.\(UUID())"), create: true))
            defer { UIPasteboard.remove(withName: pasteboard.name) }
            copySecretToPasteboard("legal winner thank year", pasteboard: pasteboard)
            #expect(pasteboard.string == "legal winner thank year")
        #endif
    }
}
