import Foundation
let app = CommandLine.arguments[1]
for (language, warehouse, recruit, refund, construction) in [
    ("en", "Warehouse", "Recruit: 3", "Refund: 50% of the construction cost.", "Construction complete"),
    ("fr", "Entrepôt", "Recruter : 3", "Remboursement : 50 % du coût de construction.", "Chantier terminé")
] {
    let bundle = Bundle(path: app + "/" + language + ".lproj")!
    precondition(String(localized: "domain.building_kind.warehouse", defaultValue: "Entrepôt", bundle: bundle) == warehouse)
    precondition(String(localized: "screen.army.recruit", defaultValue: "Recruter : \(String(3))", bundle: bundle) == recruit)
    precondition(String(localized: "screen.construction.refund_50_of_the_construction_cost", defaultValue: "Remboursement : 50 % du coût de construction.", bundle: bundle) == refund)
    let widget = Bundle(path: app + "/PlugIns/MareesAmbreWidget.appex/" + language + ".lproj")!
    precondition(String(localized: "widget.construction_live_activity.construction_complete", defaultValue: "Chantier terminé", bundle: widget) == construction)
    print("PASS: \(language) native catalog lookups, interpolation, percent and widget")
}

// Compare every catalog translation with the resource Xcode actually packaged.
let repository = URL(fileURLWithPath: CommandLine.arguments[2])
for (source, bundlePath) in [("MareesAmbre", app), ("MareesAmbreWidget", app + "/PlugIns/MareesAmbreWidget.appex")] {
    for table in ["Localizable", "InfoPlist"] {
        let data = try Data(contentsOf: repository.appendingPathComponent(source + "/" + table + ".xcstrings"))
        let catalog = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let strings = catalog["strings"] as! [String: [String: Any]]
        for language in ["fr", "en"] {
            let bundle = Bundle(path: bundlePath + "/" + language + ".lproj")!
            for (key, entry) in strings {
                let translations = entry["localizations"] as! [String: [String: Any]]
                let unit = translations[language]!["stringUnit"] as! [String: String]
                precondition(bundle.localizedString(forKey: key, value: "MISSING", table: table) == unit["value"], "Missing or incorrect \(language) translation: \(key)")
            }
        }
        print("PASS: all \(strings.count) \(source)/\(table) catalog keys packaged in French and English")
    }
}
