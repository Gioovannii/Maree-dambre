import SwiftUI

struct TradeContractsView: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRoute: TradeRoute?
    @State private var showsDefense = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(TradeRoute.partner).font(.headline)
                    Text(String(localized: "screen.commerce.cargo", defaultValue: "Chaque contrat : 20 bois livrés et 5 vivres consommés au départ."))
                    Text(String(localized: "screen.commerce.rules", defaultValue: "Une offre par route toutes les six marées. Un seul convoi commercial à la fois. Les escortes rentrent après les combats de leur marée ; elles ne défendent pas pendant le trajet."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                    if !session.state.hasBuilding(.market) {
                        Text(String(localized: "screen.commerce.needs_market", defaultValue: "Construisez le Marché pour accepter un contrat."))
                    }
                    if session.state.coastalCampaign == nil {
                        Text(String(localized: "screen.commerce.needs_campaign", defaultValue: "Ouvrez la campagne côtière depuis Défense du port pour faire progresser les voyages en marées."))
                    }
                }
                .listRowBackground(Palette.panel)
                if let convoy = session.state.army?.convoy {
                    Section(String(localized: "screen.commerce.in_transit", defaultValue: "Convoi en route")) {
                        Text(convoy.route.name).font(.headline)
                        Text(String(localized: "screen.commerce.active", defaultValue: "\(String(convoy.units.values.reduce(0, +))) unités en escorte · Retour à la marée \(String(convoy.returnsAtTide))"))
                            .accessibilityIdentifier("commerce.active")
                        Text(String(localized: "screen.commerce.cargo_reserved", defaultValue: "La cargaison est déjà réservée. Fermer l’app ne fait ni avancer ni échouer le contrat."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                    }
                    .listRowBackground(Palette.panel)
                }
                if let report = session.state.commerce?.report {
                    Section(String(localized: "screen.commerce.last_report", defaultValue: "Dernier rapport commercial")) {
                        Text(report.order.route.name).font(.headline)
                        ConvoyReportView(report: report).accessibilityIdentifier("commerce.report")
                        if report.pendingAmber > 0 {
                            Text(String(localized: "screen.commerce.pending", defaultValue: "Paiement à récupérer : \(String(report.pendingAmber)) ambre"))
                            Button { session.claimConvoyReward() } label: {
                                AdaptiveActionLabel(title: String(localized: "screen.commerce.collect", defaultValue: "Récupérer le paiement"), systemImage: "sparkles")
                            }
                            .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                            .buttonBorderShape(.roundedRectangle(radius: 14))
                            .disabled(!session.state.canClaimConvoyReward)
                            .accessibilityIdentifier("commerce.collect")
                            if !session.state.canClaimConvoyReward {
                                Text(String(localized: "screen.commerce.full_storage", defaultValue: "Libérez assez de place dans la réserve d’ambre. Le paiement reste conservé au comptoir et bloque le prochain contrat jusqu’à sa récupération."))
                                    .font(.footnote).foregroundStyle(Palette.muted)
                            }
                        } else if report.rewardClaimed {
                            Label(String(localized: "screen.commerce.payment_collected", defaultValue: "Paiement récupéré"), systemImage: "checkmark.circle")
                        }
                    }
                    .listRowBackground(Palette.panel)
                }
                ForEach(TradeRoute.allCases) { route in
                    Section(route.name) {
                        Text(String(localized: "screen.commerce.offer", defaultValue: "\(String(route.duration)) marée(s) · Paiement : \(String(route.amberReward)) ambre"))
                        Text(route == .sheltered
                             ? String(localized: "screen.commerce.safe_route", defaultValue: "Route protégée : aucune perte dans l’escorte.")
                             : String(localized: "screen.commerce.risky_route", defaultValue: "Pillards sur la route : force 24. Une escorte de force 24 ou plus livre la cargaison ; une escorte plus faible la perd."))
                            .font(.footnote)
                        if let next = session.state.commerce?.nextDepartureTide[route],
                           next > (session.state.coastalCampaign?.tide ?? 0) {
                            Text(String(localized: "screen.commerce.restock", defaultValue: "Prochaine offre à la marée \(String(next))"))
                                .font(.footnote).foregroundStyle(Palette.muted)
                        }
                        Button { selectedRoute = route } label: {
                            AdaptiveActionLabel(title: String(localized: "screen.commerce.prepare", defaultValue: "Choisir l’escorte"), systemImage: "person.2.fill")
                        }
                        .buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 14))
                        .disabled(!session.state.canSendConvoy(on: route, units: session.state.availableArmy))
                        .accessibilityIdentifier("commerce.prepare.\(route.rawValue)")
                    }
                    .listRowBackground(Palette.panel)
                }
                if let campaign = session.state.coastalCampaign {
                    Section {
                        Text(String(localized: "screen.defense.incoming", defaultValue: "Assaut dans \(String(campaign.tidesUntilAssault)) marée(s) · Force ennemie : \(String(campaign.enemyPower))"))
                        Button { showsDefense = true } label: {
                            AdaptiveActionLabel(title: String(localized: "screen.commerce.next_tide", defaultValue: "Préparer la prochaine marée"), systemImage: "water.waves")
                        }
                        .buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 14))
                        .accessibilityIdentifier("commerce.nextTide")
                        if session.state.resources.wood < TradeRoute.cargoWood || session.state.resources.provisions < TradeRoute.travelProvisions {
                            Text(String(localized: "screen.commerce.short_cargo", defaultValue: "Réunissez 20 bois et 5 vivres pour le prochain départ."))
                                .font(.footnote)
                        }
                        if session.state.convoyCapacity(for: session.state.availableArmy) < TradeRoute.cargoWood {
                            Text(String(localized: "screen.commerce.short_transport", defaultValue: "L’escorte disponible doit pouvoir transporter au moins 20 bois."))
                                .font(.footnote)
                        }
                    }
                    .listRowBackground(Palette.panel)
                }
            }
            .scrollContentBackground(.hidden).background(Palette.ocean).foregroundStyle(Palette.paper)
            .navigationTitle(String(localized: "screen.commerce.title", defaultValue: "Contrats maritimes"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "screen.raid.close", defaultValue: "Fermer"), action: dismiss.callAsFunction)
            } }
            .sheet(item: $selectedRoute) { (route: TradeRoute) in TradeConvoyPreparationView(route: route) }
            .sheet(isPresented: $showsDefense) { CoastalDefenseView() }
        }
        .tint(Palette.amber)
    }
}
