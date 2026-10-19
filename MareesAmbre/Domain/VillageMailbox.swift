import Foundation

extension VillageState {
    static let maximumMailPerVillage = 100
    var allMail: [GameMail] {
        ((mailbox ?? []) + (otherVillages ?? []).flatMap { $0.mailbox ?? [] })
            .sorted { $0.createdAt == $1.createdAt ? $0.id > $1.id : $0.createdAt > $1.createdAt }
    }
    var unreadMailCount: Int { allMail.filter { !$0.isRead }.count }

    mutating func receiveMail(_ content: GameMailContent, key: String, at date: Date, imported: Bool = false) {
        let identifier = "\(seed).\(location.x).\(location.y).\(key)"
        guard !(mailbox ?? []).contains(where: { $0.id == identifier }) else { return }
        let message = GameMail(id: identifier, createdAt: date, village: location, content: content, imported: imported)
        guard message.isValid else { return }
        var messages = mailbox ?? []
        messages.append(message)
        messages.sort { $0.createdAt == $1.createdAt ? $0.id < $1.id : $0.createdAt < $1.createdAt }
        if messages.count > Self.maximumMailPerVillage {
            messages.removeFirst(messages.count - Self.maximumMailPerVillage)
        }
        mailbox = messages
    }
    mutating func importLegacyMail(now: Date) {
        guard mailbox == nil else { return }
        mailbox = []
        guard people != nil else { return }
        let date = lastProductionAt ?? now
        receiveMail(.welcome, key: "welcome", at: date)
        if let report = army?.raidReport { receiveMail(.raid(report), key: "legacy.raid", at: date, imported: true) }
        if let report = coastalCampaign?.report { receiveMail(.defense(report), key: "defense.\(report.tide)", at: date, imported: true) }
        if let report = commerce?.report { receiveMail(.commerce(report), key: "commerce.\(report.order.departedAtTide)", at: date, imported: true) }
        if let shipment, shipment.unloaded == shipment.cargo {
            receiveMail(.shipment(shipment), key: "shipment.\(shipment.departedAt.timeIntervalSinceReferenceDate)", at: date, imported: true)
        }
    }
    @discardableResult
    mutating func markMailRead(_ id: String) -> Bool {
        if let index = mailbox?.firstIndex(where: { $0.id == id }), mailbox?[index].isRead == false {
            mailbox?[index].isRead = true
            return true
        }
        for index in (otherVillages ?? []).indices {
            if otherVillages?[index].markMailRead(id) == true { return true }
        }
        return false
    }
    mutating func markAllMailRead() {
        for index in (mailbox ?? []).indices { mailbox?[index].isRead = true }
        for index in (otherVillages ?? []).indices { otherVillages?[index].markAllMailRead() }
    }
}
