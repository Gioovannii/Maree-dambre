import CoreGraphics
import Foundation

/// Join triangle intersections into continuous coastlines before rounding bends.
enum CoastlinePath {
    private struct Key: Hashable {
        let x: Int
        let y: Int
        init(_ point: CGPoint) {
            x = Int((point.x * 10000).rounded())
            y = Int((point.y * 10000).rounded())
        }
    }

    static func make(_ segments: [(CGPoint, CGPoint)]) -> CGPath {
        var neighbours: [Key: [Int]] = [:]
        for (index, segment) in segments.enumerated() {
            guard Key(segment.0) != Key(segment.1) else { continue }
            neighbours[Key(segment.0), default: []].append(index)
            neighbours[Key(segment.1), default: []].append(index)
        }
        var used = Set<Int>()
        let result = CGMutablePath()
        // Trace open paths from the world boundary before closed island contours.
        let ends = segments.indices.filter {
            neighbours[Key(segments[$0].0)]?.count == 1 || neighbours[Key(segments[$0].1)]?.count == 1
        }
        for first in ends + Array(segments.indices) where !used.contains(first) {
            let segment = segments[first]
            if Key(segment.0) == Key(segment.1) { continue }
            let start = neighbours[Key(segment.1)]?.count == 1 ? segment.1 : segment.0
            var points = [start]
            var current = start
            while let next = neighbours[Key(current)]?.first(where: { !used.contains($0) }) {
                used.insert(next)
                let edge = segments[next]
                current = Key(edge.0) == Key(current) ? edge.1 : edge.0
                points.append(current)
                if Key(current) == Key(start) { break }
            }
            guard points.count > 1 else { continue }
            let closed = Key(points.last!) == Key(start)
            if closed { points.removeLast() }
            func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
                CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
            }
            if closed {
                result.move(to: midpoint(points.last!, points[0]))
                for index in points.indices {
                    result.addQuadCurve(to: midpoint(points[index], points[(index + 1) % points.count]), control: points[index])
                }
                result.closeSubpath()
            } else {
                result.move(to: points[0])
                for index in 1..<(points.count - 1) {
                    result.addQuadCurve(to: midpoint(points[index], points[index + 1]), control: points[index])
                }
                result.addLine(to: points.last!)
            }
        }
        return result
    }
}
