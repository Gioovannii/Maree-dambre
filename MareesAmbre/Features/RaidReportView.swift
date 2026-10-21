import SwiftUI

struct RaidReportView: View {
    let report: RaidReport
    private let success = Color(red: 0.4, green: 0.86, blue: 0.66)
    private let loss = Color(red: 1, green: 0.55, blue: 0.47)
    private let defense = Color(red: 0.48, green: 0.76, blue: 1)
    @Environment(\.dynamicTypeSize) private var typeSize
    private var compactColumns: [GridItem] {
        typeSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: 95), spacing: 10)]
    }
    private var columns: [GridItem] {
        typeSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: 135), spacing: 10)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: report.won ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                    .font(.largeTitle).foregroundStyle(report.won ? success : loss)
                    .padding(14).background((report.won ? success : loss).opacity(0.12), in: .rect(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.won ? String(localized: "screen.raid_report.victory", defaultValue: "Victoire")
                         : String(localized: "screen.raid_report.defeat", defaultValue: "Défaite"))
                        .font(.largeTitle.bold()).fontDesign(.serif).foregroundStyle(report.won ? success : loss)
                    Text(report.targetName).font(.title3.bold()).foregroundStyle(Palette.paper)
                    Text(String(localized: "battle.report.subtitle", defaultValue: "Bilan de l’expédition"))
                        .font(.caption).foregroundStyle(Palette.muted)
                }
            }
            section(String(localized: "battle.report.forces", defaultValue: "Forces en présence"), symbol: "flag.fill")
            if report.includesHero == true {
                Label(String(localized: "hero.raid.participated", defaultValue: "Le héros a accompagné cette expédition."), systemImage: "person.crop.circle.badge.checkmark")
                    .font(.footnote).foregroundStyle(Palette.amber)
            }
            LazyVGrid(columns: columns, spacing: 10) {
                BattleMetricView(title: String(localized: "unit.stats.attack", defaultValue: "Attaque"), value: report.attackPower,
                                 symbol: "burst.fill", color: Palette.amber)
                BattleMetricView(title: String(localized: "battle.report.enemy_defense", defaultValue: "Défense adverse"), value: report.defensePower,
                                 symbol: "shield.fill", color: defense)
            }
            if let enemies = report.enemyUnits {
                section(String(localized: "recon.enemy_troops", defaultValue: "Garnison adverse au départ"), symbol: "shield")
                ForEach(ArmyUnit.allCases.filter { enemies[$0, default: 0] > 0 }) { unit in
                    LabeledContent(unit.name, value: enemies[unit, default: 0].formatted())
                }
                if let fortifications = report.enemyFortifications {
                    Text(String(localized: "recon.fortifications", defaultValue: "Fortifications : \(String(fortifications)) points de défense"))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
            }
            section(String(localized: "battle.report.troops", defaultValue: "Tes troupes"), symbol: "person.3.fill")
            LazyVGrid(columns: compactColumns, spacing: 10) {
                BattleMetricView(title: String(localized: "battle.report.sent", defaultValue: "Envoyées"), value: report.unitsSent.values.reduce(0, +),
                                 symbol: "sailboat.fill", color: defense)
                BattleMetricView(title: String(localized: "battle.report.returned", defaultValue: "Revenues"), value: report.returnedCount,
                                 symbol: "arrow.uturn.backward", color: success)
                BattleMetricView(title: String(localized: "battle.report.losses", defaultValue: "Pertes"), value: report.lossCount,
                                 symbol: "heart.slash.fill", color: loss)
            }
            section(String(localized: "battle.report.loot", defaultValue: "Butin rapporté"), symbol: "shippingbox.fill")
            LazyVGrid(columns: compactColumns, spacing: 10) {
                ForEach(ResourceKind.allCases) { kind in
                    BattleMetricView(title: kind.name, value: report.stolen[kind], symbol: kind.symbol,
                                     color: kind == .wood ? success : kind == .amber ? Palette.amber : defense)
                }
            }
            Text(String(localized: "battle.report.stored_note", defaultValue: "Ces ressources ont été ajoutées à ton entrepôt. Le butin tient compte du transport des survivants et de la place disponible au retour."))
                .font(.footnote).foregroundStyle(Palette.muted)
            ForEach(ArmyUnit.allCases.filter { report.unitsSent[$0, default: 0] > 0 }) { unit in
                HStack(alignment: .top, spacing: 12) {
                    Image(unit.imageAssetName).resizable().scaledToFill().frame(width: 52, height: 64)
                        .clipShape(.rect(cornerRadius: 10)).accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 6) {
                        Label(unit.name, systemImage: unit.emblem).font(.headline)
                        Text(String(localized: "battle.report.unit_returned", defaultValue: "Retour : \(String(report.unitsSent[unit, default: 0] - report.losses[unit, default: 0])) / \(String(report.unitsSent[unit, default: 0]))"))
                            .font(.subheadline).foregroundStyle(success)
                        Label(String(localized: "battle.report.unit_losses", defaultValue: "\(String(report.losses[unit, default: 0])) perte(s)"), systemImage: "heart.slash")
                            .font(.caption).foregroundStyle(report.losses[unit, default: 0] > 0 ? loss : Palette.muted)
                    }
                    Spacer(minLength: 0)
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.panel, in: .rect(cornerRadius: 16))
                .accessibilityElement(children: .combine)
            }
        }
        .foregroundStyle(Palette.paper)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func section(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol).font(.headline).foregroundStyle(Palette.amber)
    }
}
