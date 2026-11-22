import SwiftUI

#if os(macOS)
    import AppKit

    /// The platform's bitmap image: what a QR code is rendered into and an
    /// asset catalog entry is loaded as.
    typealias PlatformImage = NSImage

    extension NSImage {
        convenience init(cgImage: CGImage) {
            self.init(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        }
    }

    extension Image {
        init(platformImage: PlatformImage) { self.init(nsImage: platformImage) }
    }
#else
    import UIKit

    /// The platform's bitmap image: what a QR code is rendered into and an
    /// asset catalog entry is loaded as.
    typealias PlatformImage = UIImage

    extension Image {
        init(platformImage: PlatformImage) { self.init(uiImage: platformImage) }
    }
#endif
