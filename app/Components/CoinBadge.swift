import SwiftUI

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
