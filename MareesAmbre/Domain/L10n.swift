import Foundation

/// Uses the application's preferred supported language, including iOS per-app settings.
enum L10n {
    static var isFrench: Bool {
        Bundle.main.preferredLocalizations.first?.hasPrefix("fr") == true
    }

    static func text(_ french: @autoclosure () -> String, _ english: @autoclosure () -> String) -> String {
        isFrench ? french() : english()
    }
}
