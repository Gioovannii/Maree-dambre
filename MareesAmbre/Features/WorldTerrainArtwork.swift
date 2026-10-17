import UIKit

/// The atlas supplies decoration only; world tiles still determine land and resources.
enum WorldTerrainArtwork {
    @MainActor static func ground() -> CGImage? {
        guard let image = UIImage(named: "ArchipelPrairie")?.cgImage,
              let context = CGContext(data: nil, width: 512, height: 512, bitsPerComponent: 8, bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: 512, height: 512))
        return context.makeImage()
    }

    @MainActor static func sprites() -> [CGImage] {
        guard let atlas = UIImage(named: "ArchipelVegetation")?.cgImage else { return [] }
        let width = atlas.width / 3, height = atlas.height / 2
        return (0..<6).compactMap { index in
            guard let sprite = atlas.cropping(to: CGRect(x: (index % 3) * width, y: (index / 3) * height,
                                                       width: width, height: height)),
                  let context = CGContext(data: nil, width: 96, height: 144, bitsPerComponent: 8, bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
            // Decode at map resolution once, rather than resampling the large atlas thousands of times.
            context.interpolationQuality = .high
            context.draw(sprite, in: CGRect(x: 0, y: 0, width: 96, height: 144))
            return context.makeImage()
        }
    }

    nonisolated static func variation(x: Int, y: Int, seed: Int) -> Double {
        var value = UInt64(truncatingIfNeeded: seed) ^ (UInt64(truncatingIfNeeded: x) &* 374_761_393)
            ^ (UInt64(truncatingIfNeeded: y) &* 668_265_263)
        value = (value ^ (value >> 13)) &* 1_274_126_177
        return Double((value ^ (value >> 16)) % 10_000) / 10_000
    }

    nonisolated static func draw(_ image: CGImage, in rect: CGRect, context: CGContext) {
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.maxY)
        context.scaleBy(x: 1, y: -1)
        context.draw(image, in: CGRect(origin: .zero, size: rect.size))
        context.restoreGState()
    }

    nonisolated static func meadow(in ctx: CGContext, side: CGFloat, seed: Int, ground: CGImage?) {
        let colors = [UIColor(red: 0.67, green: 0.72, blue: 0.43, alpha: 1).cgColor,
                      UIColor(red: 0.48, green: 0.61, blue: 0.36, alpha: 1).cgColor,
                      UIColor(red: 0.72, green: 0.73, blue: 0.48, alpha: 1).cgColor]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray,
                                     locations: [0, 0.55, 1]) {
            ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: side, y: side), options: [])
        }
        if let ground {
            ctx.saveGState()
            ctx.setAlpha(0.5)
            for y in stride(from: CGFloat.zero, to: side, by: 320) {
                for x in stride(from: CGFloat.zero, to: side, by: 320) {
                    draw(ground, in: CGRect(x: x, y: y, width: 320, height: 320), context: ctx)
                }
            }
            ctx.restoreGState()
        }
        // Broad translucent washes break the flat fill without an obvious tile grid.
        for y in 0..<40 {
            for x in 0..<40 {
                let value = variation(x: x, y: y, seed: seed)
                let center = CGPoint(x: CGFloat(x) * side / 40, y: CGFloat(y) * side / 40)
                let radius = side / 32 * (0.6 + value)
                let tint = value > 0.48
                    ? UIColor(red: 0.93, green: 0.85, blue: 0.52, alpha: 0.16)
                    : UIColor(red: 0.16, green: 0.36, blue: 0.25, alpha: 0.16)
                if let wash = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                         colors: [tint.cgColor, tint.withAlphaComponent(0).cgColor] as CFArray,
                                         locations: [0, 1]) {
                    ctx.drawRadialGradient(wash, startCenter: center, startRadius: 0,
                                           endCenter: center, endRadius: radius, options: [])
                }
            }
        }
    }
}
