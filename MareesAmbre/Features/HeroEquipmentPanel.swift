import SwiftUI

struct HeroEquipmentPanel: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(String(localized: "hero.equipment.stock", defaultValue: "Matériel maritime : \(String(session.state.hero?.missions?.materials ?? 0))"), systemImage: "shippingbox.fill")
                .font(.headline).foregroundStyle(Palette.amber)
            Text(String(localized: "hero.equipment.rules", defaultValue: "Chaque équipement améliore vos missions personnelles. Trois niveaux, débloqués aux niveaux 2, 4 et 6 du héros. Les bonus ne s’appliquent pas aux armées."))
                .font(.footnote).foregroundStyle(Palette.muted)
            ForEach(HeroEquipmentKind.allCases) { kind in HeroEquipmentCard(kind: kind) }
        }
    }
}
