import SwiftUI

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
