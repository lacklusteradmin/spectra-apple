import UniformTypeIdentifiers

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// How long a copied secret stays on the pasteboard if nothing pastes it.
let secretPasteboardLifetime: Duration = .seconds(60)

#if os(macOS)
    /// Put a secret — a seed phrase — on the pasteboard for this Mac only and
    /// for a minute. `.currentHostOnly` keeps it off Universal Clipboard, so
    /// it never reaches the user's other devices. A Mac pasteboard has no
    /// expiration of its own, so the secret is cleared here once the minute
    /// passes, unless something else was copied since; an app quit within
    /// that minute leaves it for the next copy to replace.
    @MainActor
    func copySecretToPasteboard(_ secret: String, pasteboard: NSPasteboard = .general) {
        pasteboard.prepareForNewContents(with: .currentHostOnly)
        pasteboard.setString(secret, forType: .string)
        let written = pasteboard.changeCount
        Task { @MainActor in
            try? await Task.sleep(for: secretPasteboardLifetime)
            if pasteboard.changeCount == written { pasteboard.clearContents() }
        }
    }
#else
    /// Put a secret — a seed phrase — on the pasteboard for this device only
    /// and for a minute. `.localOnly` keeps it off Universal Clipboard, so it
    /// never reaches the user's other devices, and the expiration takes it off
    /// the pasteboard rather than leaving it for whatever reads the pasteboard
    /// next.
    @MainActor
    func copySecretToPasteboard(_ secret: String, pasteboard: UIPasteboard = .general) {
        pasteboard.setItems(
            [[UTType.utf8PlainText.identifier: secret]],
            options: [
                .localOnly: true,
                .expirationDate: Date.now.addingTimeInterval(TimeInterval(secretPasteboardLifetime.components.seconds)),
            ])
    }
#endif
