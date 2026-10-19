import CoreGraphics

/// Constrain the entire visible camera rectangle, not just its center.
struct WorldCameraBounds {
    let viewport: CGSize
    let worldSize: CGSize

    func scale(_ proposed: CGFloat) -> CGFloat {
        let maximum = min(8, worldSize.width / max(1, viewport.width), worldSize.height / max(1, viewport.height))
        let minimum = min(0.8, maximum)
        return min(maximum, max(minimum, proposed.isFinite ? proposed : minimum))
    }

    func position(_ proposed: CGPoint, scale proposedScale: CGFloat) -> CGPoint {
        let zoom = scale(proposedScale)
        let halfWidth = min(worldSize.width / 2, max(1, viewport.width) * zoom / 2)
        let halfHeight = min(worldSize.height / 2, max(1, viewport.height) * zoom / 2)
        return CGPoint(x: min(worldSize.width - halfWidth, max(halfWidth, proposed.x)),
                       y: min(-halfHeight, max(-worldSize.height + halfHeight, proposed.y)))
    }
}
