import Foundation

/// Initial balancing values, shared by previews and committed jobs.
enum GameProgression {
    static let maximumBuildingLevel = 10
    static let maximumWeaponLevel = 10

    static func scaled(_ base: Resources, level: Int, growth: Double) -> Resources {
        let factor = pow(growth, Double(min(10, max(1, level)) - 1))
        return Resources(wood: Int(ceil(Double(base.wood) * factor)),
                         amber: Int(ceil(Double(base.amber) * factor)),
                         provisions: Int(ceil(Double(base.provisions) * factor)))
    }

    static func duration(level: Int, growth: Double) -> TimeInterval {
        ceil(60 * pow(growth, Double(min(10, max(1, level)) - 1)))
    }

    static func durationText(_ seconds: TimeInterval) -> String {
        Duration.seconds(Int(ceil(seconds))).formatted(.units(allowed: [.hours, .minutes, .seconds], width: .abbreviated))
    }
}
