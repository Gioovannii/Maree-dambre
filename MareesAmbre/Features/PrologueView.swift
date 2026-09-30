import SwiftUI

struct PrologueView: View {
    let onChoose: (People) -> Void
    @State private var selected: People = .sauniers

    var body: some View {
        GeometryReader { viewport in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("LES MARÉES D’AMBRE")
                            .font(.caption.bold()).tracking(2.5).foregroundStyle(Palette.amber)
                        Text("La mémoire\ndes îles")
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                            .foregroundStyle(Palette.paper)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("PROLOGUE · PORT D’AMBRE")
                            .font(.caption.bold()).tracking(1.8).foregroundStyle(Palette.muted)
                    }
                    .padding(.top, 18)
                    story
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TROIS PEUPLES, TROIS DESTINS")
                            .font(.caption.bold()).tracking(1.5).foregroundStyle(Palette.amber)
                        Text("Qui veillera sur votre village ?")
                            .font(.title2.bold()).fontDesign(.serif).foregroundStyle(Palette.paper)
                        ForEach(People.allCases) { people in peopleCard(people) }
                    }
                    Button { onChoose(selected) } label: {
                        HStack {
                            Spacer()
                            Text("Fonder mon village")
                            Image(systemName: "arrow.right")
                            Spacer()
                        }
                        .font(.headline)
                        .foregroundStyle(Palette.ocean)
                        .padding(.vertical, 16)
                        .background(Palette.amber, in: .capsule)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Commencer avec \(selected.name)")
                    Text("Première version jouable : développez les champs, construisez votre village, entraînez vos unités et partez en expédition contre les factions voisines.")
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
            Label("LA MÉMOIRE DES MARÉES", systemImage: "sparkles")
                .font(.caption.bold()).tracking(1.3).foregroundStyle(Palette.amber)
            Text("Bien avant les royaumes, l’archipel n’était qu’une étendue de brume et d’écueils. Puis la mer se retira, révélant dans ses profondeurs une matière inconnue : l’ambre des marées, une pierre chaude et dorée qui semblait retenir la lumière du jour.\n\nLes premiers habitants bâtirent leurs maisons sur les hauteurs et leurs ports au creux des anses. Ils apprirent à lire les courants, à cultiver les terres salées et à tailler l’ambre pour guider les navires dans la nuit. Pendant des générations, les îles prospérèrent.\n\nMais l’archipel n’est jamais immobile. Les courants changent, de nouvelles terres émergent, et d’anciennes routes disparaissent sous les flots. Chaque marée apporte son lot de découvertes — et réveille des rivalités oubliées.\n\nTu arrives à Port d’Ambre au moment où les cartes cessent d’être fiables. Quelques bâtiments, des réserves modestes et un port à reconstruire : c’est peu, mais c’est un début. Autour de toi, les Humains défendent leurs ports, le Peuple des récifs veille sur les passes maritimes et les Elfes des marais étendent leurs villages le long des chenaux.\n\nAucun de ces peuples ne peut dominer seul les marées. Il faudra développer ton village, protéger ses habitants et envoyer des expéditions au-delà des récifs. Ici, une absence ne condamne pas une cité : les gardes tiennent leur poste, les ateliers poursuivent leur ouvrage, et les réserves grandissent au rythme du monde.\n\nCar l’archipel garde la mémoire de chaque marée. Et peut-être, dans ses îles les plus anciennes, l’ambre révèle-t-il pourquoi la mer se retire.")
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
                trait(title: "ATOUT", text: people.strength, symbol: "sparkle", tint: Color(red: 0.55, green: 0.87, blue: 0.67))
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
