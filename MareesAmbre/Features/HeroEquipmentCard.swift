import SwiftUI

struct HeroEquipmentCard: View {
    let kind: HeroEquipmentKind
    @Environment(VillageSession.self) private var session
    private var missions: HeroMissions { session.state.hero?.missions ?? HeroMissions() }
    private var level: Int { (missions.equipment ?? HeroEquipment())[kind] }
    private var next: Int { level + 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: kind.symbol).font(.title2).foregroundStyle(Palette.amber)
                    .frame(width: 44, height: 44).background(Palette.ocean, in: .rect(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text(kind.title).font(.headline)
                    Text(level == 0
                         ? String(localized: "hero.equipment.unmade", defaultValue: "À fabriquer")
                         : String(localized: "hero.equipment.tier", defaultValue: "Niveau \(String(level)) sur 3"))
                        .font(.caption).foregroundStyle(Palette.muted)
                }
            }
            if level > 0 {
                Label(kind.effect(at: level), systemImage: "checkmark.circle.fill")
                    .font(.subheadline).foregroundStyle(Palette.amber)
            }
            if level < HeroEquipmentKind.maximumLevel {
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "hero.equipment.next", defaultValue: "Prochain niveau : \(String(next))")).font(.subheadline.bold())
                    Text(kind.effect(at: next)).font(.subheadline)
                    Label(String(localized: "hero.equipment.cost", defaultValue: "Coût : \(String(kind.materialCost(for: next))) unités de matériel maritime"), systemImage: "shippingbox.fill")
                        .font(.subheadline).foregroundStyle(Palette.amber)
                    Text(String(localized: "hero.equipment.required_level", defaultValue: "Niveau du héros requis : \(String(HeroEquipmentKind.requiredHeroLevel(for: next)))"))
                        .font(.caption).foregroundStyle(Palette.muted)
                }
                Button {
                    _ = session.upgradeHeroEquipment(kind)
                } label: {
                    Label(level == 0 ? String(localized: "hero.equipment.craft", defaultValue: "Fabriquer")
                          : String(localized: "hero.equipment.upgrade", defaultValue: "Améliorer"), systemImage: "hammer.fill")
                        .frame(maxWidth: .infinity).padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                .disabled(!session.state.canUpgradeHeroEquipment(kind))
                .accessibilityIdentifier("hero.equipment.upgrade.\(kind.rawValue)")
                if !missions.hasBoat {
                    Text(String(localized: "hero.equipment.boat_required", defaultValue: "Réparez d’abord votre barque."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                } else if missions.voyage != nil {
                    Text(String(localized: "hero.equipment.busy", defaultValue: "Disponible au retour de votre mission."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                } else if !session.state.canUpgradeHeroEquipment(kind) {
                    Text(String(localized: "hero.equipment.requirements", defaultValue: "Rassemblez le matériel et atteignez le niveau requis."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
            } else {
                Label(String(localized: "hero.equipment.maximum", defaultValue: "Équipement au niveau maximum"), systemImage: "checkmark.seal.fill")
                    .font(.subheadline.bold()).foregroundStyle(Palette.amber)
            }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 20))
    }
}
