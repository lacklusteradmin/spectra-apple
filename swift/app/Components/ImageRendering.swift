import Foundation
import SwiftUI

// MARK: ─ Icon helpers

/// Chain/token badge. Renders the bundled chain artwork when one exists;
/// otherwise falls back to a solid circle with the first letter of
/// `fallbackText`. No custom photos, no multi-letter disambiguation.
struct CoinBadge: View {
    /// The bundled artwork to draw, empty when the coin ships none. Not
    /// private: `CoinBadgeArtworkTests` asserts every coin the app can hold
    /// resolves to one that `PlatformImage(named:)` can load, and the resolution is
    /// the whole of what broke.
    let artworkName: String
    private let fallbackText: String
    private let color: Color
    private let size: CGFloat

    /// From artwork core already named — the wiki's rows carry one per coin.
    init(artworkName: String?, fallbackText: String, color: Color, size: CGFloat = 40) {
        self.artworkName = artworkName ?? ""
        self.fallbackText = fallbackText
        self.color = color
        self.size = size
    }

    var body: some View {
        let displayImage: PlatformImage? = artworkName.isEmpty ? nil : PlatformImage(named: artworkName)
        return Group {
            if let displayImage {
                Image(platformImage: displayImage).resizable().interpolation(.high).scaledToFit().frame(width: size, height: size)
            } else {
                letterFallback
            }
        }.shadow(color: color.opacity(0.18), radius: 6, y: 3)
    }
    private var letterFallback: some View {
        let letter = fallbackText.first.map { String($0).uppercased() } ?? "?"
        return Circle().fill(
            LinearGradient(colors: [color, color.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
        ).frame(width: size, height: size).overlay {
            Text(letter).font(.system(size: size * 0.5, weight: .semibold, design: .rounded)).foregroundStyle(.white)
        }
    }
}
/// The app icon's five bars in a square of side `size`. Widths and gaps both
/// shrink by the golden ratio; the geometry and the palette are those of
/// `icons/appicon/`, and change with it.
struct SpectraMark: View {
    var size: CGFloat
    /// One colour for every bar. `nil` draws the icon's own palette.
    var tint: Color? = nil

    /// Each bar's leading edge and width, in 600ths of the side.
    private static let bars: [(x: CGFloat, width: CGFloat)] = [(0, 185), (256, 115), (415, 71), (512, 44), (573, 27)]
    private static let palette: [Color] = [
        Color(red: 1, green: 0.5, blue: 0), Color(red: 1, green: 0, blue: 0.4), Color(red: 0.5, green: 0, blue: 1),
        Color(red: 0, green: 0.4, blue: 1), Color(red: 0, green: 0.88, blue: 1),
    ]

    var body: some View {
        Canvas { context, canvas in
            let unit = canvas.width / 600
            for (bar, color) in zip(Self.bars, Self.palette) {
                let rect = CGRect(x: bar.x * unit, y: 0, width: bar.width * unit, height: canvas.height)
                context.fill(Path(rect), with: .color(tint ?? color))
            }
        }.frame(width: size, height: size)
    }
}

/// The app icon as a view: its bars on the icon's black tile.
struct SpectraLogo: View {
    var size: CGFloat = 78
    var body: some View {
        let tile = RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
        // The bars fill the same share of the tile as they do of the icon.
        SpectraMark(size: size * 600 / 1024).frame(width: size, height: size).background(Color.black, in: tile)
            .overlay(tile.strokeBorder(Color.white.opacity(0.16), lineWidth: 1)).shadow(color: .black.opacity(0.18), radius: 16, y: 8)
    }
}
