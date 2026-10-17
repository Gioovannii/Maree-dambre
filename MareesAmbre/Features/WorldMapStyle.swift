import UIKit

enum WorldMapStyle {
    static let amber = UIColor(red: 1, green: 0.76, blue: 0.38, alpha: 1)
    static let paper = UIColor(red: 0.96, green: 0.94, blue: 0.85, alpha: 1)
    static let ocean = UIColor(red: 0.035, green: 0.14, blue: 0.19, alpha: 1)

    static func factionColor(_ id: Int) -> UIColor {
        switch id {
        case 0: UIColor(red: 0.92, green: 0.66, blue: 0.36, alpha: 1)
        case 1: UIColor(red: 0.57, green: 0.85, blue: 0.80, alpha: 1)
        default: UIColor(red: 0.76, green: 0.69, blue: 0.86, alpha: 1)
        }
    }
}
