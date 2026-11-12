import SwiftUI

#if os(macOS)
    import AVFoundation
    import AppKit
#else
    import UIKit
    import Vision
    import VisionKit
#endif

struct SendQRScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onScan: (String) -> Void
    var body: some View {
        NavigationStack {
            QRCodeScannerView { payload in
                onScan(payload)
                dismiss()
            }
            .ignoresSafeArea(edges: .bottom).navigationTitle(AppLocalization.string("Scan QR Code")).inlineNavigationTitle().toolbar {
                ToolbarItem(placement: .barLeading) {
                    Button(AppLocalization.string("Cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
#if os(iOS)
    struct QRCodeScannerView: UIViewControllerRepresentable {
        /// Whether this device can scan at all; a device that cannot shows no
        /// scan button.
        static var isSupported: Bool { DataScannerViewController.isSupported }
        /// Whether it can scan now: the camera is allowed and unrestricted.
        static var isAvailable: Bool { DataScannerViewController.isAvailable }

        let onScan: (String) -> Void
        func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }
        func makeUIViewController(context: Context) -> DataScannerViewController {
            let controller = DataScannerViewController(
                recognizedDataTypes: [.barcode(symbologies: [.qr])], qualityLevel: .balanced, recognizesMultipleItems: false,
                isHighFrameRateTrackingEnabled: false, isPinchToZoomEnabled: true, isGuidanceEnabled: true, isHighlightingEnabled: true
            )
            controller.delegate = context.coordinator
            try? controller.startScanning()
            return controller
        }
        func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
        static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
            uiViewController.stopScanning()
        }
        final class Coordinator: NSObject, DataScannerViewControllerDelegate {
            private let onScan: (String) -> Void
            private var hasResolvedPayload = false
            init(onScan: @escaping (String) -> Void) {
                self.onScan = onScan
            }
            func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) { resolve(item, from: dataScanner) }
            func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
                guard let firstItem = addedItems.first else { return }
                resolve(firstItem, from: dataScanner)
            }
            private func resolve(_ item: RecognizedItem, from dataScanner: DataScannerViewController) {
                guard !hasResolvedPayload else { return }
                guard case .barcode(let barcode) = item,
                    let payload = barcode.payloadStringValue?.trimmingCharacters(in: .whitespacesAndNewlines), !payload.isEmpty
                else { return }
                hasResolvedPayload = true
                dataScanner.stopScanning()
                spectraNotificationHaptic(.success)
                onScan(payload)
            }
        }
    }
#else
    /// The Mac's camera, reading QR codes through AVFoundation: VisionKit's
    /// data scanner is not on macOS.
    struct QRCodeScannerView: NSViewRepresentable {
        /// Whether this Mac can scan at all; one with no camera shows no scan
        /// button.
        static var isSupported: Bool { AVCaptureDevice.default(for: .video) != nil }
        /// Whether it can scan now: the camera is not denied or restricted.
        /// Access not yet asked for is asked when the scanner opens.
        static var isAvailable: Bool {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized, .notDetermined: isSupported
            default: false
            }
        }

        let onScan: (String) -> Void
        func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }

        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            view.wantsLayer = true
            let preview = AVCaptureVideoPreviewLayer(session: context.coordinator.session)
            preview.videoGravity = .resizeAspectFill
            view.layer = preview
            context.coordinator.start()
            return view
        }
        func updateNSView(_ view: NSView, context: Context) {}
        static func dismantleNSView(_ view: NSView, coordinator: Coordinator) { coordinator.stop() }

        @MainActor
        final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
            let session = AVCaptureSession()
            private let onScan: (String) -> Void
            private var hasResolvedPayload = false
            init(onScan: @escaping (String) -> Void) {
                self.onScan = onScan
            }

            /// Ask for the camera if it was never asked, then read codes
            /// from it until one resolves.
            func start() {
                Task { [weak self] in
                    guard await AVCaptureDevice.requestAccess(for: .video), let self,
                        let camera = AVCaptureDevice.default(for: .video),
                        let input = try? AVCaptureDeviceInput(device: camera), session.canAddInput(input)
                    else { return }
                    let output = AVCaptureMetadataOutput()
                    guard session.canAddOutput(output) else { return }
                    session.beginConfiguration()
                    session.addInput(input)
                    session.addOutput(output)
                    // Codes are delivered on the main queue, where this
                    // coordinator lives.
                    output.setMetadataObjectsDelegate(self, queue: .main)
                    if output.availableMetadataObjectTypes.contains(.qr) { output.metadataObjectTypes = [.qr] }
                    session.commitConfiguration()
                    session.startRunning()
                }
            }

            func stop() {
                if session.isRunning { session.stopRunning() }
            }

            nonisolated func metadataOutput(
                _ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection
            ) {
                let payload = metadataObjects.lazy
                    .compactMap { ($0 as? AVMetadataMachineReadableCodeObject)?.stringValue }
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .first { !$0.isEmpty }
                guard let payload else { return }
                // Sound: the delegate queue set in `start` is the main queue.
                MainActor.assumeIsolated { resolve(payload) }
            }

            private func resolve(_ payload: String) {
                guard !hasResolvedPayload else { return }
                hasResolvedPayload = true
                stop()
                onScan(payload)
            }
        }
    }
#endif
