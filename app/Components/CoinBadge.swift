import SwiftUI

/// Coin, token, chain or wallet badge. Renders the bundled artwork when one
/// exists; otherwise falls back to a solid shape with the first letter of
/// `fallbackText`. No custom photos, no multi-letter disambiguation.
struct CoinBadge: View {
    /// What the badge stands for, which sets its shape and the artwork it draws.
    enum Kind {
        /// A coin or token: a disc, from the `crypto` asset group.
        case coin
        /// A chain, or a wallet by its chain: a rounded square, from the
        /// `chain` asset group, so a chain is not drawn like its native coin.
        case chain
    }

    /// The bundled artwork to draw, empty when the coin ships none.
    private let artworkName: String
    private let fallbackText: String
    private let color: Color
    private let size: CGFloat
    private let kind: Kind

    /// From artwork core already named — a known token and a chain carry one each.
    init(artworkName: String?, fallbackText: String, color: Color, size: CGFloat = 40, kind: Kind = .coin) {
        self.artworkName = artworkName ?? ""
        self.fallbackText = fallbackText
        self.color = color
        self.size = size
        self.kind = kind
    }

    var body: some View {
        let assetName = kind == .chain ? "chain/\(artworkName)" : artworkName
        let displayImage: PlatformImage? = artworkName.isEmpty ? nil : PlatformImage(named: assetName)
        return Group {
            if let displayImage {
                Image(platformImage: displayImage).resizable().interpolation(.high).scaledToFit().frame(width: size, height: size)
            } else {
                letterFallback
            }
        }.shadow(color: color.opacity(0.18), radius: 6, y: 3)
    }
    /// The chain artwork's own tile: a continuous corner of 0.225 of the side.
    private var shape: AnyShape {
        switch kind {
        case .coin: AnyShape(Circle())
        case .chain: AnyShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
        }
    }
    private var letterFallback: some View {
        let letter = fallbackText.first.map { String($0).uppercased() } ?? "?"
        return shape.fill(
            LinearGradient(colors: [color, color.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
        ).frame(width: size, height: size).overlay {
            Text(letter).font(.system(size: size * 0.5, weight: .semibold, design: .rounded)).foregroundStyle(.white)
        }
    }
}
