import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

#if os(iOS)
    /// What a recovery phrase or a private key sits behind on screen.
    ///
    /// While the screen is recorded, mirrored or shared the secret is blurred
    /// and its `.privacySensitive()` text redacted, so it reaches no other
    /// screen. A screenshot cannot be stopped, but it lands in Photos, where
    /// backups and other apps can read it, so taking one is answered with a
    /// warning.
    private struct SecretShield: ViewModifier {
        @Environment(\.isSceneCaptured) private var isCaptured
        @State private var tookScreenshot = false

        func body(content: Content) -> some View {
            content
                .redacted(reason: isCaptured ? .privacy : [])
                .blur(radius: isCaptured ? 14 : 0)
                .overlay {
                    if isCaptured {
                        Label(AppLocalization.string("secret.hiddenWhileCaptured"), systemImage: "eye.slash.fill")
                            .font(.subheadline.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .padding(SpectraLayout.cardPadding)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
                    tookScreenshot = true
                }
                .alert(AppLocalization.string("secret.screenshot.title"), isPresented: $tookScreenshot) {
                    Button(AppLocalization.string("OK"), role: .cancel) {}
                } message: {
                    Text(AppLocalization.string("secret.screenshot.message"))
                }
        }
    }
#else
    /// What a recovery phrase or a private key sits behind on screen.
    ///
    /// A Mac does not tell an app that its screen is being captured or that a
    /// screenshot was taken. What it offers instead is a window that asks to
    /// be left out: while a secret is on screen its window is marked
    /// unshareable, which screenshots, recordings and screen sharing that
    /// honour the mark draw without it.
    private struct SecretShield: ViewModifier {
        func body(content: Content) -> some View {
            content.background(UnsharedWindowMarker())
        }
    }

    /// Marks the window it sits in unshareable for as long as it is there.
    private struct UnsharedWindowMarker: NSViewRepresentable {
        func makeNSView(context: Context) -> MarkerView { MarkerView() }
        func updateNSView(_ view: MarkerView, context: Context) {}

        final class MarkerView: NSView {
            /// What the window allowed before this view arrived, restored
            /// when it leaves.
            private var previous: (window: NSWindow, sharingType: NSWindow.SharingType)?

            override func viewWillMove(toWindow newWindow: NSWindow?) {
                super.viewWillMove(toWindow: newWindow)
                if let previous { previous.window.sharingType = previous.sharingType }
                previous = newWindow.map { ($0, $0.sharingType) }
                newWindow?.sharingType = .none
            }
        }
    }
#endif

extension View {
    /// Shield a secret on screen; see `SecretShield`. Mark the secret's own
    /// text `.privacySensitive()` so the redaction reaches it.
    func secretShield() -> some View { modifier(SecretShield()) }
}
