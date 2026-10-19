import Foundation

struct VillageGuideMessage: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}
