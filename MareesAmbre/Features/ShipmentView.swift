import SwiftUI

struct ShipmentView: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var destination: TileCoordinate?
    @State private var wood = 0
    @State private var amber = 0
    @State private var provisions = 0
    @State private var selections = ArmyUnit.allCases.map { RaidTroopSelection(unit: $0) }
    @State private var failed = false
    @State private var confirmsDeparture = false

    init(destination: TileCoordinate? = nil) {
        _destination = State(initialValue: destination)
    }
    private var cargo: Resources { Resources(wood: max(0, min(999999, wood)), amber: max(0, min(999999, amber)), provisions: max(0, min(999999, provisions))) }
    private var escort: [ArmyUnit: Int] {
        Dictionary(uniqueKeysWithValues: selections.filter { $0.count > 0 }.map { ($0.unit, $0.count) })
    }
    private var destinationVillage: VillageState? {
        session.state.otherVillages?.first { $0.location == destination }
    }
    private var remainingUnits: [ArmyUnit: Int] {
        session.state.availableArmy.reduce(into: [:]) { result, pair in
            result[pair.key] = max(0, pair.value - escort[pair.key, default: 0])
        }
    }
    private var canSend: Bool {
        guard let destination, [wood, amber, provisions].allSatisfy({ (0...999999).contains($0) }) else { return false }
        return session.state.canSendShipment(to: destination, cargo: cargo, units: escort)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                Form {
                    Section(String(localized: "shipment.route", defaultValue: "Trajet entre vos implantations")) {
                        LabeledContent(String(localized: "shipment.origin", defaultValue: "Départ"), value: session.state.settlementName)
                        Picker(String(localized: "shipment.destination", defaultValue: "Destination"), selection: $destination) {
                            ForEach(session.state.otherVillages ?? [], id: \.location) { village in
                                Text(village.settlementName + " · \(village.location.x), \(village.location.y)")
                                    .tag(Optional(village.location))
                            }
                        }
                        if let destination {
                            LabeledContent(String(localized: "shipment.outbound", defaultValue: "Aller"),
                                           value: GameProgression.durationText(session.state.shipmentDuration(to: destination)))
                            LabeledContent(String(localized: "shipment.round_trip", defaultValue: "Retour de l’escorte"),
                                           value: GameProgression.durationText(session.state.shipmentDuration(to: destination) * 2))
                        }
                        Text(String(localized: "shipment.safe", defaultValue: "Ravitaillement entre vos villages : aucun combat sur ce trajet. Les soldats reviennent au village de départ."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                    }
                    .listRowBackground(Palette.panel)
                    Section(String(localized: "shipment.cargo", defaultValue: "Cargaison")) {
                        ShipmentResourceRow(kind: .wood, amount: $wood, stock: session.state.resources.wood, isEditing: $editing)
                        ShipmentResourceRow(kind: .amber, amount: $amber, stock: session.state.resources.amber, isEditing: $editing)
                        ShipmentResourceRow(kind: .provisions, amount: $provisions, stock: session.state.resources.provisions, isEditing: $editing)
                        if let target = destinationVillage {
                            Text(String(localized: "shipment.space", defaultValue: "Place disponible à destination"))
                                .font(.headline)
                            ShipmentCargoSummary(resources: Resources(wood: max(0, target.storageCapacity - target.resources.wood),
                                                              amber: max(0, target.storageCapacity - target.resources.amber),
                                                              provisions: max(0, target.storageCapacity - target.resources.provisions)))
                        }
                        Text(String(localized: "shipment.storage_help", defaultValue: "Si l’entrepôt se remplit pendant le trajet, le surplus reste en attente. Il sera déchargé dès qu’une place se libère, même après le retour des soldats."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                    }
                    .listRowBackground(Palette.panel)
                    Section(String(localized: "shipment.escort", defaultValue: "Choisir les transporteurs")) {
                        Button(String(localized: "screen.raid.select_all", defaultValue: "Tout sélectionner"), systemImage: "checkmark.circle") {
                            for index in selections.indices {
                                selections[index].count = session.state.availableArmy[selections[index].unit, default: 0]
                            }
                            failed = false
                        }
                        .buttonStyle(.bordered).foregroundStyle(Palette.amber)
                        .accessibilityIdentifier("shipment.selectAll")
                        Button(String(localized: "screen.raid.keep_half", defaultValue: "Garder la moitié au village")) {
                            for index in selections.indices {
                                selections[index].count = session.state.availableArmy[selections[index].unit, default: 0] / 2
                            }
                        }
                        .buttonStyle(.bordered).foregroundStyle(Palette.amber)
                        ForEach($selections) { $selection in
                            let available = session.state.availableArmy[selection.unit, default: 0]
                            if available > 0 {
                                RaidTroopSelectionRow(selection: $selection, available: available, accessibilityPrefix: "shipment")
                            }
                        }
                        if session.state.availableArmy.values.reduce(0, +) == 0 {
                            Text(String(localized: "shipment.no_troops", defaultValue: "Recrutez des soldats pour transporter vos ressources."))
                        }
                    }
                    .listRowBackground(Palette.panel)
                    Section(String(localized: "shipment.summary", defaultValue: "Avant le départ")) {
                        LabeledContent(String(localized: "shipment.load", defaultValue: "Ressources chargées"), value: (cargo.wood + cargo.amber + cargo.provisions).formatted())
                        LabeledContent(String(localized: "shipment.capacity", defaultValue: "Capacité de transport"), value: session.state.convoyCapacity(for: escort).formatted())
                        LabeledContent(String(localized: "shipment.defense", defaultValue: "Défense restante au village"), value: session.state.defensePower(for: remainingUnits).formatted())
                        if cargo.wood + cargo.amber + cargo.provisions > session.state.convoyCapacity(for: escort) {
                            Text(String(localized: "shipment.capacity_help", defaultValue: "Réduisez la cargaison ou ajoutez des transporteurs."))
                        }
                        if !session.state.hasBuilding(.expeditionQuay) {
                            Text(String(localized: "shipment.quay_required", defaultValue: "Construisez un Quai d’expédition dans le village de départ."))
                        }
                        if let shipment = session.state.shipment, !shipment.isComplete {
                            Text(String(localized: "shipment.busy", defaultValue: "Un ravitaillement est déjà engagé depuis ce village. Attendez le déchargement complet et le retour de l’escorte."))
                        }
                        if failed {
                            Text(String(localized: "shipment.failed", defaultValue: "Départ impossible. Vérifiez la cargaison et les troupes encore disponibles."))
                        }
                        Button(String(localized: "shipment.send", defaultValue: "Envoyer le ravitaillement"), systemImage: "shippingbox.fill") { confirmsDeparture = true }
                            .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                            .disabled(!canSend).accessibilityIdentifier("shipment.send")
                            .id("shipment.summary")
                            .confirmationDialog(String(localized: "shipment.confirm", defaultValue: "Envoyer cette cargaison et mobiliser l’escorte jusqu’à son retour ?"), isPresented: $confirmsDeparture, titleVisibility: .visible) {
                                Button(String(localized: "shipment.send", defaultValue: "Envoyer le ravitaillement"), action: send)
                            }
                    }
                    .listRowBackground(Palette.panel)
                }
                .task {
                    if ProcessInfo.processInfo.arguments.contains("--snapshot-shipment-departure") {
                        try? await Task.sleep(for: .milliseconds(200))
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) { proxy.scrollTo("shipment.summary", anchor: .bottom) }
                    }
                }
                .scrollContentBackground(.hidden).background(Palette.ocean).foregroundStyle(Palette.paper)
                .navigationTitle(String(localized: "shipment.title", defaultValue: "Ravitaillement"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "expansion.close", defaultValue: "Fermer")) { dismiss() }
                    }
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(String(localized: "shipment.keyboard_done", defaultValue: "Terminé")) { editing = false }
                    }
                }
            }
        }
        .tint(Palette.amber).preferredColorScheme(.dark)
        .onAppear {
            if destinationVillage == nil { destination = session.state.otherVillages?.first?.location }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-shipment") {
                wood = 60; amber = 20; provisions = 20
                if let index = selections.firstIndex(where: { session.state.availableArmy[$0.unit, default: 0] >= 5 }) {
                    selections[index].count = 5
                }
            }
        }
        .onChange(of: session.state.availableArmy) { _, _ in
            for index in selections.indices {
                selections[index].count = min(selections[index].count, session.state.availableArmy[selections[index].unit, default: 0])
            }
        }
    }
    @FocusState private var editing: Bool
    private func send() {
        guard let destination else { return }
        if session.sendShipment(to: destination, cargo: cargo, units: escort) { dismiss() }
        else { failed = true }
    }
}
