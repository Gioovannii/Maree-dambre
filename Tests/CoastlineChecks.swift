import CoreGraphics
import Foundation

@main
struct CoastlineChecks {
    static func main() {
        let a = CGPoint(x: 0, y: 0), b = CGPoint(x: 10, y: 0)
        let c = CGPoint(x: 10, y: 10), d = CGPoint(x: 0, y: 10)
        let loop = CoastlinePath.make([(c, b), (a, d), (a, b), (d, c), (a, a)])
        var moves = 0, closes = 0, curves = 0
        loop.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint: moves += 1
            case .closeSubpath: closes += 1
            case .addQuadCurveToPoint: curves += 1
            default: break
            }
        }
        precondition(moves == 1 && closes == 1 && curves == 4,
                     "Reversed and shuffled coast segments must form one smooth closed island")
        let open = CoastlinePath.make([(b, c), (a, b)])
        precondition(open.currentPoint == c || open.currentPoint == a,
                     "World-boundary coastlines retain their endpoints")
        precondition(CoastlinePath.make([]).isEmpty)
        print("PASS: continuous closed coastline, reversed segments, open boundaries and empty input")
    }
}
