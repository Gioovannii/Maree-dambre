import SpriteKit
import UIKit

enum WorldVillageMarker {
    @MainActor static func make(name: String, asset: String, color: UIColor, isHome: Bool) -> SKNode {
        let node = SKNode()
        node.name = "village"
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 36, height: 13))
        shadow.fillColor = WorldMapStyle.ocean.withAlphaComponent(0.35)
        shadow.strokeColor = .clear
        shadow.position.y = -2
        node.addChild(shadow)

        let base = SKShapeNode(ellipseOf: CGSize(width: 38, height: 18))
        base.fillColor = UIColor(red: 0.95, green: 0.86, blue: 0.63, alpha: 0.7)
        base.strokeColor = color
        base.lineWidth = 1.2
        node.addChild(base)
        let building = SKSpriteNode(imageNamed: asset)
        building.size = CGSize(width: 42, height: 42)
        building.position.y = 14
        node.addChild(building)

        let flag = SKShapeNode(circleOfRadius: 3.5)
        flag.position = CGPoint(x: 18, y: 25)
        flag.fillColor = color
        flag.strokeColor = WorldMapStyle.paper
        flag.lineWidth = 1
        node.addChild(flag)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.name = "name"
        label.text = name
        label.fontSize = 13
        label.fontColor = isHome ? WorldMapStyle.amber : WorldMapStyle.paper
        label.verticalAlignmentMode = .center
        label.position.y = -17
        let plate = SKShapeNode(rectOf: CGSize(width: label.frame.width + 22, height: 25), cornerRadius: 10)
        plate.name = "namePlate"
        plate.position.y = -17
        plate.fillColor = WorldMapStyle.ocean.withAlphaComponent(0.94)
        plate.strokeColor = color.withAlphaComponent(0.7)
        plate.lineWidth = 0.8
        node.addChild(plate)
        node.addChild(label)
        return node
    }
}
