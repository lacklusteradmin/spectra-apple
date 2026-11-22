import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

extension View {
    /// Show `cover` for `item` in a window of its own, above everything this
    /// scene presents.
    ///
    /// An overlay inside the view tree sits under every sheet, alert and
    /// confirmation dialog, because the system presents those above the root
    /// view — on a Mac, in windows of their own. A cover that must hide the
    /// app — the lock screen, the app-switcher snapshot — needs a window above
    /// the app's instead. The app's own tree is left alone, so nothing in it
    /// is rebuilt when the cover comes and goes.
    func sceneCover<Item: Equatable, Cover: View>(
        item: Item?, @ViewBuilder cover: @escaping (Item) -> Cover
    ) -> some View {
        modifier(SceneCoverModifier(item: item, cover: cover))
    }
}

private struct SceneCoverModifier<Item: Equatable, Cover: View>: ViewModifier {
    let item: Item?
    let cover: (Item) -> Cover
    @State private var window = SceneCoverWindow()

    func body(content: Content) -> some View {
        content
            #if os(macOS)
                // The cover's window shows only while the app's own is on
                // screen. What the Dock draws of a minimized window, and the
                // window as it comes back, is the app's own content, so that
                // is hidden under a cover too.
                .opacity(item == nil ? 1 : 0)
            #endif
            .background(HostWindowReader { window.host = $0 })
            .onChange(of: item, initial: true) { _, item in
                window.show(item.map { AnyView(cover($0)) })
            }
    }
}

#if os(iOS)
    /// The cover's window. Created when a cover is shown and dropped when it is
    /// hidden, so an unlocked app carries no second window.
    @MainActor
    private final class SceneCoverWindow {
        weak var host: UIWindowScene? {
            didSet { if host !== oldValue { apply() } }
        }
        private var content: AnyView?
        private var window: UIWindow?

        func show(_ content: AnyView?) {
            self.content = content
            apply()
        }

        private func apply() {
            guard let content else { return hide() }
            if let host = window?.rootViewController as? UIHostingController<AnyView> {
                host.rootView = content
                return
            }
            guard let scene = host else { return }
            // A focused field keeps the keyboard up, and the keyboard's window
            // sits above this one.
            scene.windows.forEach { $0.endEditing(true) }
            let host = UIHostingController(rootView: content)
            host.view.backgroundColor = .clear
            host.view.accessibilityViewIsModal = true
            let window = UIWindow(windowScene: scene)
            window.windowLevel = .alert + 1
            window.rootViewController = host
            window.makeKeyAndVisible()
            self.window = window
        }

        private func hide() {
            guard let window else { return }
            window.isHidden = true
            self.window = nil
            host?.windows.first { $0.windowLevel == .normal }?.makeKey()
        }
    }

    /// Reports the window scene the view is placed in.
    private struct HostWindowReader: UIViewRepresentable {
        let onScene: (UIWindowScene?) -> Void

        func makeUIView(context: Context) -> ReaderView {
            let view = ReaderView()
            view.onScene = onScene
            return view
        }
        func updateUIView(_ view: ReaderView, context: Context) { view.onScene = onScene }

        final class ReaderView: UIView {
            var onScene: ((UIWindowScene?) -> Void)?
            override func didMoveToWindow() {
                super.didMoveToWindow()
                onScene?(window?.windowScene)
            }
        }
    }
#else
    /// The cover's window: a borderless child of the app's window, over the
    /// whole of it — title bar and any sheet attached to it included. Created
    /// when a cover is shown and dropped when it is hidden, so an unlocked
    /// app carries no second window.
    @MainActor
    private final class SceneCoverWindow {
        weak var host: NSWindow? {
            didSet { if host !== oldValue { observeHost(); apply() } }
        }
        private var content: AnyView?
        private var window: NSWindow?
        private var hostObservers: [NSObjectProtocol] = []

        func show(_ content: AnyView?) {
            self.content = content
            apply()
        }

        /// Follow the app's window: a child window moves with its parent but
        /// does not resize with it, and a cover asked for while the parent
        /// was in the Dock or hidden is shown when it comes back.
        private func observeHost() {
            hostObservers.forEach(NotificationCenter.default.removeObserver)
            hostObservers = []
            guard let host else { return }
            let follow: [(Notification.Name, Any?)] = [
                (NSWindow.didResizeNotification, host),
                (NSWindow.didDeminiaturizeNotification, host),
                (NSApplication.didUnhideNotification, nil),
            ]
            hostObservers = follow.map { name, object in
                NotificationCenter.default.addObserver(forName: name, object: object, queue: .main) { [weak self] _ in
                    // Sound: the observer's queue is the main queue.
                    MainActor.assumeIsolated { self?.apply() }
                }
            }
        }

        private func apply() {
            guard let content else { return hide() }
            if let window, let host {
                (window.contentViewController as? NSHostingController<AnyView>)?.rootView = content
                window.setFrame(host.frame, display: true)
                return
            }
            // A window ordered in while its parent is in the Dock, or the app
            // hidden, would stand on the desktop alone.
            guard let host, host.isVisible, !host.isMiniaturized else { return }
            // A field being typed in would keep taking keys under the cover.
            host.makeFirstResponder(nil)
            let controller = NSHostingController(rootView: content)
            // The window is sized to the app's, not to what the cover asks for.
            controller.sizingOptions = []
            let window = CoverWindow(contentRect: host.frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.contentViewController = controller
            window.setFrame(host.frame, display: false)
            host.addChildWindow(window, ordered: .above)
            window.makeKeyAndOrderFront(nil)
            self.window = window
        }

        private func hide() {
            guard let window else { return }
            host?.removeChildWindow(window)
            window.orderOut(nil)
            self.window = nil
            (host?.attachedSheet ?? host)?.makeKey()
        }
    }

    /// A borderless window refuses the keyboard unless it says otherwise, and
    /// the lock card's button is pressed with it.
    private final class CoverWindow: NSWindow {
        override var canBecomeKey: Bool { true }
    }

    /// Reports the window the view is placed in.
    private struct HostWindowReader: NSViewRepresentable {
        let onWindow: (NSWindow?) -> Void

        func makeNSView(context: Context) -> ReaderView {
            let view = ReaderView()
            view.onWindow = onWindow
            return view
        }
        func updateNSView(_ view: ReaderView, context: Context) { view.onWindow = onWindow }

        final class ReaderView: NSView {
            var onWindow: ((NSWindow?) -> Void)?
            override func viewDidMoveToWindow() {
                super.viewDidMoveToWindow()
                onWindow?(window)
            }
        }
    }
#endif
