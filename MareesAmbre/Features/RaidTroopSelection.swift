struct RaidTroopSelection: Identifiable {
    let unit: ArmyUnit
    var count = 0
    var id: ArmyUnit { unit }
}
