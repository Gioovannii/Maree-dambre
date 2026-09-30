import SwiftUI

struct ConstructionSiteArt: View {
    let kind: BuildingKind
    let progress: Double

    var body: some View {
        Group {
            if let asset = kind.imageAssetName {
                Image(asset + (progress < 0.5 ? "Early" : "Half"))
                    .resizable()
                    .scaledToFit()
            } else {
                BuildingArt(kind: kind)
            }
        }
        .accessibilityHidden(true)
    }
}
