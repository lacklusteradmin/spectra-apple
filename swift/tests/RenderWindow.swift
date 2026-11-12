import SwiftUI
import Testing

@testable import Spectra

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// A real window for a test to render a view in, the size of a phone screen
/// on either platform. A view that draws is laid out by the platform's own
/// hosting controller, so a render catches what a view-model test cannot: a
/// page that crashes, or draws nothing, when it meets real state.
///
/// On a Mac the window sits off screen: it is laid out and drawn like any
/// other, and never shows on the desktop of whoever runs the tests.
@MainActor
final class RenderWindow {
    static let phoneSize = CGSize(width: 393, height: 852)

    #if os(macOS)
        private let window: NSWindow
    #else
        private let window: UIWindow
        private let takesKey: Bool
        private let previousKeyWindow: UIWindow?
        private var controller: UIViewController?
    #endif

    /// `takesKey` makes the window the key window while it shows, for a page
    /// whose fields need one, and hands the key back on `close`. A window
    /// that does not take it leaves a parallel suite's key window alone.
    init(size: CGSize = RenderWindow.phoneSize, takesKey: Bool = false) throws {
        #if os(macOS)
            window = NSWindow(
                contentRect: CGRect(origin: CGPoint(x: -20_000, y: -20_000), size: size), styleMask: .borderless,
                backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
        #else
            let scene = try #require(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
            self.takesKey = takesKey
            previousKeyWindow = takesKey ? scene.windows.first(where: \.isKeyWindow) : nil
            window = UIWindow(windowScene: scene)
            window.frame = CGRect(origin: .zero, size: size)
        #endif
    }

    /// Put `view` in the window, in `colorScheme` when one is given, and lay
    /// it out once.
    func show(_ view: some View, colorScheme: ColorScheme? = nil) {
        #if os(macOS)
            let controller = NSHostingController(rootView: AnyView(view))
            // The window keeps its size, whatever the view would ask for.
            controller.sizingOptions = []
            let size = window.frame.size
            window.contentViewController = controller
            window.setContentSize(size)
            if let colorScheme { window.appearance = NSAppearance(named: colorScheme == .dark ? .darkAqua : .aqua) }
            window.orderFrontRegardless()
        #else
            let controller = UIHostingController(rootView: AnyView(view))
            if let colorScheme { controller.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light }
            self.controller = controller
            window.rootViewController = controller
            if takesKey { window.makeKeyAndVisible() } else { window.isHidden = false }
        #endif
        layout()
    }

    /// Lay out the hosted hierarchy now, without waiting for the next pass.
    func layout() {
        #if os(macOS)
            window.contentView?.layoutSubtreeIfNeeded()
        #else
            controller?.view.layoutIfNeeded()
            window.layoutIfNeeded()
        #endif
    }

    /// Draw the window as it stands. A draw that fails is recorded against
    /// the test.
    @discardableResult
    func render() -> PlatformImage {
        #if os(macOS)
            guard let view = window.contentView, let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
                Issue.record("The window has nothing to draw")
                return NSImage()
            }
            view.cacheDisplay(in: view.bounds, to: bitmap)
            let image = NSImage(size: view.bounds.size)
            image.addRepresentation(bitmap)
            return image
        #else
            UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                #expect(window.drawHierarchy(in: window.bounds, afterScreenUpdates: true))
            }
        #endif
    }

    /// Draw the window, require the result to hold content rather than an
    /// empty canvas, and attach it to the test as `name`.
    func record(named name: String) throws {
        let image = render()
        #if os(macOS)
            let rendered = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #else
            let rendered = image.cgImage
        #endif
        let pixels = try #require(rendered?.dataProvider?.data) as Data
        #expect(Set(pixels).count > 16, "The render must contain content, not an empty canvas")
        Attachment.record(image, named: name)
    }

    func close() {
        #if os(macOS)
            window.orderOut(nil)
            window.contentViewController = nil
        #else
            window.isHidden = true
            window.rootViewController = nil
            controller = nil
            previousKeyWindow?.makeKey()
        #endif
    }

    #if os(iOS)
        /// Every scroll view in the hosted hierarchy, outermost first.
        var scrollViews: [UIScrollView] {
            func scrollViews(in view: UIView) -> [UIScrollView] {
                let own = (view as? UIScrollView).map { [$0] } ?? []
                return own + view.subviews.flatMap { scrollViews(in: $0) }
            }
            return controller.map { scrollViews(in: $0.view) } ?? []
        }
    #endif
}
