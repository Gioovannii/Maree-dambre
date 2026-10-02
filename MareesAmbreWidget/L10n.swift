import Foundation

enum L10n {
    static func text(_ french: @autoclosure () -> String, _ english: @autoclosure () -> String) -> String {
        Bundle.main.preferredLocalizations.first?.hasPrefix("fr") == true ? french() : english()
    }
}
