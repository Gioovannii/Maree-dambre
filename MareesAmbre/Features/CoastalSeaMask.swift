import SwiftUI

/// Artwork-space coastlines, kept separate from the interactive plot layout.
struct CoastalSeaMask: Shape {
    var mode: VillageMapMode = .resourceFields

    func path(in rect: CGRect) -> Path {
        if mode == .townCenter { return townSea(in: rect) }
        // Conservative open-water regions for the central-estate artwork.
        // Keep shore structures and both boats outside the resampling mask.
        var water = Path()
        water.addRect(CGRect(x: rect.minX + rect.width * 0.25,
                             y: rect.minY + rect.height * 0.06,
                             width: rect.width * 0.35, height: rect.height * 0.14))
        water.addRect(CGRect(x: rect.minX + rect.width * 0.25,
                             y: rect.minY + rect.height * 0.84,
                             width: rect.width * 0.55, height: rect.height * 0.10))
        return water
    }
    private func townSea(in rect: CGRect) -> Path {
        var water = Path()
        water.addRect(CGRect(x: rect.minX + rect.width * 0.4, y: rect.minY + rect.height * 0.09,
                             width: rect.width * 0.5, height: rect.height * 0.07))
        water.addRect(CGRect(x: rect.minX + rect.width * 0.48, y: rect.minY + rect.height * 0.79,
                             width: rect.width * 0.40, height: rect.height * 0.10))
        return water
    }
}
