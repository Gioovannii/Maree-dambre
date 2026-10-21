import Foundation

struct HeroMissions: Codable, Equatable {
    var chapter = 0
    var materials = 0
    var voyage: HeroVoyage?
    var report: HeroMissionReport?
    var equipment: HeroEquipment?
    var hasBoat: Bool { chapter == 3 }
    var available: [HeroMissionKind] {
        hasBoat ? [.surveyCoast, .rescueCrew] : HeroMissionKind.allCases.filter { $0.chapter == chapter }
    }
    func duration(for mission: HeroMissionKind) -> TimeInterval {
        mission.baseDuration * (hasBoat && mission.chapter == nil ? (equipment ?? HeroEquipment()).durationMultiplier : 1)
    }
    var isValid: Bool {
        guard (0...3).contains(chapter), (0...999).contains(materials), report?.isValid ?? true, equipment?.isValid ?? true,
              hasBoat || (equipment ?? HeroEquipment()).highestLevel == 0 else { return false }
        if let report, let completedChapter = report.mission.chapter, completedChapter >= chapter { return false }
        if let report, report.mission.chapter == nil, !hasBoat { return false }
        if let voyage {
            guard voyage.isValid, available.contains(voyage.mission), voyage.duration == duration(for: voyage.mission),
                  (voyage.equipment ?? HeroEquipment()) == (equipment ?? HeroEquipment()) else { return false }
        }
        return true
    }
}

extension VillageState {
    func canStartHeroMission(_ mission: HeroMissionKind) -> Bool {
        guard let hero, !heroIsOnRaid else { return false }
        let missions = hero.missions ?? HeroMissions()
        return missions.voyage == nil && missions.available.contains(mission)
            && missions.materials >= mission.materialCost
            && resources.wood >= mission.cost.wood && resources.amber >= mission.cost.amber
            && resources.provisions >= mission.cost.provisions
    }

    @discardableResult
    mutating func startHeroMission(_ mission: HeroMissionKind, now: Date = .now) -> Bool {
        guard canStartHeroMission(mission), now >= (lastProductionAt ?? now), now >= (hero?.experienceStartedAt ?? now), var captain = hero else { return false }
        var missions = captain.missions ?? HeroMissions()
        let voyage = HeroVoyage(mission: mission, origin: location, startedAt: now, duration: missions.duration(for: mission), equipment: missions.equipment)
        guard voyage.isValid else { return false }
        missions.materials -= mission.materialCost
        missions.voyage = voyage
        captain.missions = missions
        hero = captain
        resources.wood -= mission.cost.wood
        resources.amber -= mission.cost.amber
        resources.provisions -= mission.cost.provisions
        return true
    }

    mutating func settleHeroMission(now: Date) {
        guard var captain = hero, var missions = captain.missions, let voyage = missions.voyage, now >= voyage.endsAt else { return }
        let equipment = voyage.equipment ?? HeroEquipment()
        let xp = min(equipment.experience(for: voyage.mission), HeroProgression.maximumExperience - captain.totalExperience)
        let materials = min(equipment.materials(for: voyage.mission), 999 - missions.materials)
        captain.experience = captain.totalExperience + xp
        missions.materials += materials
        if voyage.mission.chapter != nil { missions.chapter += 1 }
        let report = HeroMissionReport(mission: voyage.mission, experience: xp, materials: materials, equipment: voyage.equipment)
        missions.report = report
        missions.voyage = nil
        captain.missions = missions
        hero = captain
        let key = "hero.mission.\(voyage.mission.rawValue).\(voyage.startedAt.timeIntervalSinceReferenceDate)"
        if location == voyage.origin {
            receiveMail(.heroMission(report), key: key, at: voyage.endsAt)
        } else if let index = otherVillages?.firstIndex(where: { $0.location == voyage.origin }) {
            otherVillages?[index].receiveMail(.heroMission(report), key: key, at: voyage.endsAt)
        }
    }
}
