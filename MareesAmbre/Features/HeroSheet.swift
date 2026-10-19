import SwiftUI

struct HeroSheet: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var portrait: HeroPortrait = .captainWoman
    @State private var name = ""
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let hero = session.state.hero, !isEditing {
                        HStack(spacing: 16) {
                            Image(hero.portrait.assetName).resizable().scaledToFill()
                                .frame(width: 100, height: 120)
                                .clipShape(.rect(cornerRadius: 20)).accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(hero.name).font(.largeTitle.bold())
                                Label(String(localized: "hero.role", defaultValue: "Capitaine des marées"), systemImage: "safari.fill")
                                    .font(.subheadline).foregroundStyle(Palette.amber)
                            }
                        }
                        HeroExperienceView(hero: hero)
                        HeroMissionsPanel()
                        Text(String(localized: "hero.shared", defaultValue: "Un même personnage vous accompagne dans tous vos villages."))
                        Text(String(localized: "hero.command_experience", defaultValue: "Votre capitaine gagne de l’expérience de commandement grâce aux actions de vos villages. Les niveaux ne donnent pas encore de bonus de combat."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                        Text(String(localized: "hero.xp_rules", defaultValue: "Combat gagné : 20 XP · Défaite : 5 XP · Colonie fondée : 75 XP. Un seul raid récompensé par voisin et par jour, et une défense par village et par jour (jours UTC). Les anciens rapports ne donnent pas d’XP."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                        Button(String(localized: "hero.edit", defaultValue: "Personnaliser"), systemImage: "pencil") {
                            portrait = hero.portrait
                            name = hero.name
                            isEditing = true
                        }.buttonStyle(.bordered)
                    } else {
                        Text(String(localized: "hero.choose", defaultValue: "Qui mènera vos expéditions ?"))
                            .font(.title2.bold())
                        Text(String(localized: "hero.cosmetic", defaultValue: "Choisissez votre personnage. Les deux portraits offrent les mêmes possibilités. Vous pourrez modifier ce choix gratuitement."))
                            .font(.subheadline).foregroundStyle(Palette.muted)
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(HeroPortrait.allCases) { option in
                                Button {
                                    if name.isEmpty || name == portrait.defaultName { name = option.defaultName }
                                    portrait = option
                                } label: {
                                    VStack(spacing: 8) {
                                        Image(option.assetName).resizable().scaledToFit()
                                            .clipShape(.rect(cornerRadius: 16))
                                        Label(option == .captainWoman
                                              ? String(localized: "hero.woman", defaultValue: "Héroïne")
                                              : String(localized: "hero.man", defaultValue: "Héros"),
                                              systemImage: portrait == option ? "checkmark.circle.fill" : "circle")
                                            .font(.subheadline.bold())
                                    }
                                    .padding(8).frame(maxWidth: .infinity)
                                    .background(Palette.panel, in: .rect(cornerRadius: 20))
                                    .overlay { RoundedRectangle(cornerRadius: 20).strokeBorder(portrait == option ? Palette.amber : Color.clear, lineWidth: 2) }
                                }
                                .buttonStyle(.plain).accessibilityAddTraits(portrait == option ? .isSelected : [])
                                .accessibilityIdentifier("hero.portrait.\(option.rawValue)")
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "hero.name_label", defaultValue: "Nom du personnage")).font(.headline)
                            TextField(String(localized: "hero.name_placeholder", defaultValue: "De 1 à 24 caractères"), text: $name)
                                .textInputAutocapitalization(.words).autocorrectionDisabled()
                                .padding(14).background(Palette.panel, in: .rect(cornerRadius: 12))
                                .accessibilityIdentifier("hero.name")
                            Text(String(localized: "hero.name_rule", defaultValue: "De 1 à 24 caractères, sans retour à la ligne."))
                                .font(.caption).foregroundStyle(Palette.muted)
                        }
                        Button {
                            if session.customizeHero(portrait: portrait, name: name) { isEditing = false }
                        } label: {
                            Label(String(localized: "hero.save", defaultValue: "Enregistrer mon personnage"), systemImage: "checkmark")
                                .frame(maxWidth: .infinity).padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                        .disabled(PlayerHero.normalizedName(name) == nil)
                        .accessibilityIdentifier("hero.save")
                        if session.state.hero != nil {
                            Button(String(localized: "hero.cancel", defaultValue: "Annuler")) { isEditing = false }
                        }
                    }
                }
                .padding(20).frame(maxWidth: 560).frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Palette.ocean).foregroundStyle(Palette.paper)
            .navigationTitle(String(localized: "hero.title", defaultValue: "Votre capitaine"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "screen.raid.close", defaultValue: "Fermer"), action: dismiss.callAsFunction)
                }
            }
            .onAppear {
                if let hero = session.state.hero { portrait = hero.portrait; name = hero.name }
                else { name = portrait.defaultName }
            }
        }.tint(Palette.amber)
    }
}
