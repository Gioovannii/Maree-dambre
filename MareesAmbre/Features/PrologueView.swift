import SwiftUI

struct PrologueView: View {
    let onChoose: (People) -> Void
    @State private var selected: People = .sauniers

    var body: some View {
        GeometryReader { viewport in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(L10n.text("LES MARÉES D’AMBRE", "AMBER TIDES"))
                            .font(.caption.bold()).tracking(2.5).foregroundStyle(Palette.amber)
                        Text(L10n.text("La mémoire\ndes îles", "The memory\nof the islands"))
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                            .foregroundStyle(Palette.paper)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(L10n.text("PROLOGUE · PORT D’AMBRE", "PROLOGUE · AMBER HARBOR"))
                            .font(.caption.bold()).tracking(1.8).foregroundStyle(Palette.muted)
                    }
                    .padding(.top, 18)
                    story
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.text("TROIS PEUPLES, TROIS DESTINS", "THREE PEOPLES, THREE DESTINIES"))
                            .font(.caption.bold()).tracking(1.5).foregroundStyle(Palette.amber)
                        Text(L10n.text("Qui veillera sur votre village ?", "Who will watch over your village?"))
                            .font(.title2.bold()).fontDesign(.serif).foregroundStyle(Palette.paper)
                        ForEach(People.allCases) { people in peopleCard(people) }
                    }
                    Button { onChoose(selected) } label: {
                        HStack {
                            Spacer()
                            Text(L10n.text("Fonder mon village", "Found my village"))
                            Image(systemName: "arrow.right")
                            Spacer()
                        }
                        .font(.headline)
                        .foregroundStyle(Palette.ocean)
                        .padding(.vertical, 16)
                        .background(Palette.amber, in: .capsule)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(L10n.text("Commencer avec \(selected.name)", "Start with \(selected.name)"))
                    Text(L10n.text("Première version jouable : développez les champs, construisez votre village, entraînez vos unités et partez en expédition contre les factions voisines.", "First playable version: develop resource sites, build your village, train units and send expeditions against neighboring factions."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 18)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.visible)
            .scrollBounceBehavior(.always)
            .frame(width: viewport.size.width, height: viewport.size.height)
            .background {
                ZStack {
                    LinearGradient(colors: [Palette.ocean, Color(red: 0.025, green: 0.09, blue: 0.13)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    Circle()
                        .fill(Palette.amber.opacity(0.08))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: 170, y: -300)
                        .accessibilityHidden(true)
                }
                .allowsHitTesting(false)
            }
        }
    }

    private var story: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L10n.text("LA MÉMOIRE DES MARÉES", "THE MEMORY OF THE TIDES"), systemImage: "sparkles")
                .font(.caption.bold()).tracking(1.3).foregroundStyle(Palette.amber)
            Text(L10n.text("Bien avant les royaumes, l’archipel n’était qu’une étendue de brume et d’écueils. Puis la mer se retira, révélant dans ses profondeurs une matière inconnue : l’ambre des marées, une pierre chaude et dorée qui semblait retenir la lumière du jour.\n\nLes premiers habitants bâtirent leurs maisons sur les hauteurs et leurs ports au creux des anses. Ils apprirent à lire les courants, à cultiver les terres salées et à tailler l’ambre pour guider les navires dans la nuit. Pendant des générations, les îles prospérèrent.\n\nMais l’archipel n’est jamais immobile. Les courants changent, de nouvelles terres émergent, et d’anciennes routes disparaissent sous les flots. Chaque marée apporte son lot de découvertes — et réveille des rivalités oubliées.\n\nTu arrives à Port d’Ambre au moment où les cartes cessent d’être fiables. Quelques bâtiments, des réserves modestes et un port à reconstruire : c’est peu, mais c’est un début. Autour de toi, les Humains défendent leurs ports, le Peuple des récifs veille sur les passes maritimes et les Elfes des marais étendent leurs villages le long des chenaux.\n\nAucun de ces peuples ne peut dominer seul les marées. Il faudra développer ton village, protéger ses habitants et envoyer des expéditions au-delà des récifs. Ici, une absence ne condamne pas une cité : les gardes tiennent leur poste, les ateliers poursuivent leur ouvrage, et les réserves grandissent au rythme du monde.\n\nCar l’archipel garde la mémoire de chaque marée. Et peut-être, dans ses îles les plus anciennes, l’ambre révèle-t-il pourquoi la mer se retire.", "Long before the kingdoms, the archipelago was nothing but mist and hidden rocks. Then the sea withdrew, revealing an unknown substance in its depths: tidal amber, a warm golden stone that seemed to hold the light of day.\n\nThe first settlers built their homes on high ground and their harbors in sheltered coves. They learned to read the currents, farm the salty land and carve amber to guide ships through the night. For generations, the islands prospered.\n\nBut the archipelago never stands still. Currents shift, new lands emerge and old routes vanish beneath the waves. Every tide brings discoveries and awakens forgotten rivalries.\n\nYou arrive at Amber Harbor just as the charts become unreliable. A few buildings, modest supplies and a harbor to rebuild: it is little, but it is a beginning. Around you, Humans defend their ports, the Reef Folk guard the sea passages and Marsh Elves expand their villages along the channels.\n\nNone of these peoples can master the tides alone. You must develop your village, protect its inhabitants and send expeditions beyond the reefs. Here, an absence does not doom a town: guards keep their posts, workshops keep working and stores grow with the rhythm of the world.\n\nFor the archipelago remembers every tide. Perhaps, on its oldest islands, the amber will reveal why the sea withdraws."))
                .font(.body).foregroundStyle(Palette.paper.opacity(0.9))
                .lineSpacing(4).fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(.white.opacity(0.045), in: .rect(cornerRadius: 24))
        .overlay { RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.1), lineWidth: 1) }
    }

    private func peopleCard(_ people: People) -> some View {
        let isSelected = selected == people
        return Button { selected = people } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: people.emblem)
                        .font(.headline)
                        .foregroundStyle(isSelected ? Palette.ocean : Palette.amber)
                        .frame(width: 38, height: 38)
                        .background(isSelected ? Palette.amber : Palette.amber.opacity(0.12), in: Circle())
                    Text(people.name).font(.headline).foregroundStyle(Palette.paper)
                    Spacer()
                    if isSelected { Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.amber) }
                }
                HStack(alignment: .top, spacing: 10) {
                    ForEach(ArmyUnit.allCases.filter { $0.people == people }) { unit in
                        VStack(spacing: 5) {
                            Image(unit.imageAssetName)
                                .resizable().scaledToFit()
                                .frame(maxHeight: 150)
                                .clipShape(.rect(cornerRadius: 12))
                                .accessibilityHidden(true)
                            Text(unit.name).font(.caption.bold()).foregroundStyle(Palette.paper)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Text(people.description).font(.subheadline).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
                trait(title: L10n.text("ATOUT", "STRENGTH"), text: people.strength, symbol: "sparkle", tint: Color(red: 0.55, green: 0.87, blue: 0.67))
            }
            .padding(15)
            .background(isSelected ? Palette.panel : .white.opacity(0.035), in: .rect(cornerRadius: 20))
            .overlay { RoundedRectangle(cornerRadius: 20).strokeBorder(isSelected ? Palette.amber : .white.opacity(0.1), lineWidth: isSelected ? 1.5 : 1) }
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func trait(title: String, text: String, symbol: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol).font(.caption2.bold()).foregroundStyle(tint)
            Text(text).font(.caption).foregroundStyle(Palette.paper).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
