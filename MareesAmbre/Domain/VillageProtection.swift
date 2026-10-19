import Foundation

extension VillageState {
    func isUnderProtection(at now: Date = .now) -> Bool {
        beginnerProtection?.isActive(at: now) ?? false
    }
    mutating func beginProtection(now: Date = .now) {
        guard beginnerProtection == nil, people != nil else { return }
        let protection = BeginnerProtection(startedAt: now)
        guard protection.isValid else { return }
        beginnerProtection = protection
        receiveMail(.protectionStarted(protection.endsAt), key: "protection.started", at: now)
    }
    @discardableResult
    mutating func extendProtection(now: Date = .now) -> Bool {
        guard var protection = beginnerProtection, protection.canExtend(at: now) else { return false }
        protection.extensionUsed = true
        guard protection.isValid else { return false }
        beginnerProtection = protection
        receiveMail(.protectionExtended(protection.endsAt), key: "protection.extended", at: now)
        return true
    }
    mutating func notifyProtectionExpiry(now: Date) {
        guard var protection = beginnerProtection, !protection.isActive(at: now), !protection.expiryNotified else { return }
        protection.expiryNotified = true
        beginnerProtection = protection
        receiveMail(.protectionEnded, key: "protection.ended", at: protection.endsAt)
    }
}
