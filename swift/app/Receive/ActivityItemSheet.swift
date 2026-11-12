import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

extension View {
    /// Offer `items` — text, images — to the system's share destinations
    /// while `isPresented`: the share sheet on iOS, the sharing menu on a Mac,
    /// opening from this view.
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        #if os(macOS)
            background(SharingPickerAnchor(isPresented: isPresented, items: items))
        #else
            sheet(isPresented: isPresented) { ActivityItemSheet(activityItems: items) }
        #endif
    }
}

#if os(iOS)
    private struct ActivityItemSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
#else
    /// Where the sharing menu opens from. The menu is modal: `show` returns
    /// once a destination is chosen or the menu is dismissed.
    private struct SharingPickerAnchor: NSViewRepresentable {
        @Binding var isPresented: Bool
        let items: [Any]

        func makeNSView(context: Context) -> NSView { NSView() }
        func makeCoordinator() -> Coordinator { Coordinator() }

        func updateNSView(_ view: NSView, context: Context) {
            let coordinator = context.coordinator
            guard isPresented, !coordinator.isOpening, !items.isEmpty, view.window != nil else { return }
            coordinator.isOpening = true
            let items = items
            // Not during the update pass: the menu runs its own event loop.
            Task { @MainActor in
                NSSharingServicePicker(items: items).show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
                coordinator.isOpening = false
                isPresented = false
            }
        }

        /// One menu per request: updates keep arriving while it is asked for.
        @MainActor
        final class Coordinator {
            var isOpening = false
        }
    }
#endif
