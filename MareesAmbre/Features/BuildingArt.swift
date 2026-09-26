import SwiftUI

/// Isometric landmark illustrations make each village building recognizable at map scale.
struct BuildingArt: View {
    let kind: BuildingKind

    private let plaster = Color(red: 0.90, green: 0.82, blue: 0.65)
    private let shadedStone = Color(red: 0.63, green: 0.57, blue: 0.44)
    private let roof = Color(red: 0.58, green: 0.29, blue: 0.22)
    private let darkRoof = Color(red: 0.39, green: 0.22, blue: 0.19)

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            func polygon(_ points: [CGPoint], color: Color) {
                var path = Path()
                path.addLines(points.map { CGPoint(x: $0.x * w, y: $0.y * h) })
                path.closeSubpath()
                context.fill(path, with: .color(color))
            }

            context.fill(
                Path(ellipseIn: CGRect(x: w * 0.08, y: h * 0.79, width: w * 0.82, height: h * 0.13)),
                with: .color(.black.opacity(0.20))
            )

            switch kind {
            case .hall:
                drawHall(polygon, context: context, size: size)
            case .lumbermill:
                drawMill(polygon, context: context, size: size)
            case .farm:
                drawFarm(polygon, context: context, size: size)
            case .amberWorks:
                drawAmberWorkshop(polygon, context: context, size: size)
            case .watchtower:
                drawWatchtower(polygon, context: context, size: size)
            case .warehouse:
                drawWarehouse(polygon, context: context, size: size)
            }
        }
        .accessibilityHidden(true)
    }

    private func drawHall(_ polygon: ([CGPoint], Color) -> Void, context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        polygon([.init(x: 0.19, y: 0.41), .init(x: 0.50, y: 0.52), .init(x: 0.50, y: 0.90), .init(x: 0.19, y: 0.76)], plaster)
        polygon([.init(x: 0.50, y: 0.52), .init(x: 0.83, y: 0.37), .init(x: 0.83, y: 0.73), .init(x: 0.50, y: 0.90)], shadedStone)
        polygon([.init(x: 0.10, y: 0.43), .init(x: 0.40, y: 0.20), .init(x: 0.58, y: 0.51), .init(x: 0.50, y: 0.56)], Palette.amber)
        polygon([.init(x: 0.40, y: 0.20), .init(x: 0.72, y: 0.11), .init(x: 0.91, y: 0.37), .init(x: 0.58, y: 0.51)], Color(red: 0.82, green: 0.56, blue: 0.24))
        polygon([.init(x: 0.34, y: 0.23), .init(x: 0.43, y: 0.04), .init(x: 0.56, y: 0.19), .init(x: 0.56, y: 0.52), .init(x: 0.34, y: 0.45)], Color(red: 0.79, green: 0.72, blue: 0.57))
        polygon([.init(x: 0.56, y: 0.19), .init(x: 0.69, y: 0.13), .init(x: 0.69, y: 0.45), .init(x: 0.56, y: 0.52)], Color(red: 0.58, green: 0.54, blue: 0.44))
        polygon([.init(x: 0.31, y: 0.24), .init(x: 0.43, y: 0.07), .init(x: 0.51, y: 0.22), .init(x: 0.43, y: 0.34)], roof)
        polygon([.init(x: 0.43, y: 0.07), .init(x: 0.56, y: 0.02), .init(x: 0.66, y: 0.16), .init(x: 0.51, y: 0.22)], darkRoof)
        context.fill(Path(CGRect(x: w * 0.43, y: h * 0.62, width: w * 0.10, height: h * 0.28)), with: .color(Color(red: 0.30, green: 0.24, blue: 0.19)))
        context.fill(Path(CGRect(x: w * 0.24, y: h * 0.56, width: w * 0.075, height: h * 0.085)), with: .color(Palette.amber))
        context.fill(Path(CGRect(x: w * 0.70, y: h * 0.52, width: w * 0.065, height: h * 0.08)), with: .color(Palette.amber))
        var mast = Path()
        mast.move(to: CGPoint(x: w * 0.49, y: h * 0.07))
        mast.addLine(to: CGPoint(x: w * 0.49, y: h * 0.0))
        context.stroke(mast, with: .color(Palette.paper), lineWidth: 2)
    }

    private func drawMill(_ polygon: ([CGPoint], Color) -> Void, context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        polygon([.init(x: 0.14, y: 0.44), .init(x: 0.49, y: 0.55), .init(x: 0.49, y: 0.83), .init(x: 0.14, y: 0.70)], Color(red: 0.75, green: 0.55, blue: 0.34))
        polygon([.init(x: 0.49, y: 0.55), .init(x: 0.84, y: 0.40), .init(x: 0.84, y: 0.67), .init(x: 0.49, y: 0.83)], Color(red: 0.54, green: 0.39, blue: 0.28))
        polygon([.init(x: 0.09, y: 0.43), .init(x: 0.42, y: 0.18), .init(x: 0.59, y: 0.51), .init(x: 0.49, y: 0.56)], Color(red: 0.34, green: 0.36, blue: 0.31))
        polygon([.init(x: 0.42, y: 0.18), .init(x: 0.74, y: 0.10), .init(x: 0.91, y: 0.39), .init(x: 0.59, y: 0.51)], Color(red: 0.25, green: 0.29, blue: 0.27))
        for index in 0..<3 {
            let y = h * (0.71 + Double(index) * 0.045)
            let log = CGRect(x: w * 0.60, y: y, width: w * 0.23, height: h * 0.035)
            context.fill(Path(roundedRect: log, cornerRadius: 2), with: .color(Color(red: 0.88, green: 0.68, blue: 0.40)))
            context.stroke(Path(ellipseIn: CGRect(x: log.minX - 2, y: log.minY, width: h * 0.035, height: h * 0.035)), with: .color(Color(red: 0.43, green: 0.29, blue: 0.18)), lineWidth: 1)
        }
        context.fill(Path(CGRect(x: w * 0.68, y: h * 0.43, width: w * 0.065, height: h * 0.11)), with: .color(Palette.amber))
    }

    private func drawFarm(_ polygon: ([CGPoint], Color) -> Void, context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        for row in 0..<5 {
            let y = h * (0.70 + Double(row) * 0.045)
            var furrow = Path()
            furrow.move(to: CGPoint(x: w * 0.06, y: y))
            furrow.addLine(to: CGPoint(x: w * 0.47, y: y + h * 0.12))
            context.stroke(furrow, with: .color(Palette.amber.opacity(0.88)), lineWidth: 2)
        }
        polygon([.init(x: 0.37, y: 0.43), .init(x: 0.61, y: 0.52), .init(x: 0.61, y: 0.78), .init(x: 0.37, y: 0.69)], plaster)
        polygon([.init(x: 0.61, y: 0.52), .init(x: 0.84, y: 0.42), .init(x: 0.84, y: 0.68), .init(x: 0.61, y: 0.78)], shadedStone)
        polygon([.init(x: 0.30, y: 0.44), .init(x: 0.49, y: 0.23), .init(x: 0.67, y: 0.50), .init(x: 0.61, y: 0.54)], roof)
        polygon([.init(x: 0.49, y: 0.23), .init(x: 0.74, y: 0.20), .init(x: 0.89, y: 0.41), .init(x: 0.67, y: 0.50)], darkRoof)
        context.fill(Path(CGRect(x: w * 0.47, y: h * 0.59, width: w * 0.09, height: h * 0.19)), with: .color(Color(red: 0.31, green: 0.23, blue: 0.18)))
        let silo = CGRect(x: w * 0.13, y: h * 0.42, width: w * 0.19, height: h * 0.30)
        context.fill(Path(roundedRect: silo, cornerRadius: w * 0.08), with: .color(Color(red: 0.81, green: 0.75, blue: 0.57)))
        context.fill(Path(ellipseIn: CGRect(x: silo.minX, y: silo.minY - h * 0.035, width: silo.width, height: h * 0.10)), with: .color(Color(red: 0.66, green: 0.61, blue: 0.46)))
    }

    private func drawAmberWorkshop(_ polygon: ([CGPoint], Color) -> Void, context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        polygon([.init(x: 0.18, y: 0.45), .init(x: 0.50, y: 0.56), .init(x: 0.50, y: 0.84), .init(x: 0.18, y: 0.71)], Color(red: 0.72, green: 0.62, blue: 0.43))
        polygon([.init(x: 0.50, y: 0.56), .init(x: 0.82, y: 0.42), .init(x: 0.82, y: 0.69), .init(x: 0.50, y: 0.84)], Color(red: 0.49, green: 0.47, blue: 0.38))
        polygon([.init(x: 0.10, y: 0.45), .init(x: 0.42, y: 0.20), .init(x: 0.59, y: 0.52), .init(x: 0.50, y: 0.57)], Color(red: 0.55, green: 0.34, blue: 0.25))
        polygon([.init(x: 0.42, y: 0.20), .init(x: 0.73, y: 0.11), .init(x: 0.90, y: 0.40), .init(x: 0.59, y: 0.52)], Color(red: 0.39, green: 0.25, blue: 0.23))
        let furnace = CGRect(x: w * 0.28, y: h * 0.55, width: w * 0.26, height: h * 0.25)
        context.fill(Path(roundedRect: furnace, cornerRadius: 5), with: .color(Color(red: 0.37, green: 0.28, blue: 0.23)))
        context.fill(Path(ellipseIn: CGRect(x: furnace.minX + w * 0.035, y: furnace.minY + h * 0.055, width: furnace.width - w * 0.07, height: furnace.height * 0.52)), with: .color(Palette.amber))
        polygon([.init(x: 0.63, y: 0.30), .init(x: 0.71, y: 0.40), .init(x: 0.66, y: 0.56), .init(x: 0.61, y: 0.41)], Color(red: 1.0, green: 0.80, blue: 0.35))
        polygon([.init(x: 0.75, y: 0.46), .init(x: 0.82, y: 0.54), .init(x: 0.77, y: 0.67), .init(x: 0.72, y: 0.56)], Color(red: 1.0, green: 0.86, blue: 0.52))
        context.fill(Path(CGRect(x: w * 0.67, y: h * 0.18, width: w * 0.09, height: h * 0.18)), with: .color(Color(red: 0.46, green: 0.43, blue: 0.36)))
    }

    private func drawWatchtower(_ polygon: ([CGPoint], Color) -> Void, context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        polygon([.init(x: 0.20, y: 0.78), .init(x: 0.50, y: 0.89), .init(x: 0.80, y: 0.76), .init(x: 0.50, y: 0.66)], Color(red: 0.60, green: 0.55, blue: 0.43))
        polygon([.init(x: 0.34, y: 0.38), .init(x: 0.48, y: 0.43), .init(x: 0.48, y: 0.78), .init(x: 0.34, y: 0.73)], plaster)
        polygon([.init(x: 0.48, y: 0.43), .init(x: 0.64, y: 0.36), .init(x: 0.64, y: 0.70), .init(x: 0.48, y: 0.78)], shadedStone)
        polygon([.init(x: 0.22, y: 0.36), .init(x: 0.48, y: 0.26), .init(x: 0.74, y: 0.36), .init(x: 0.48, y: 0.47)], roof)
        polygon([.init(x: 0.25, y: 0.34), .init(x: 0.48, y: 0.12), .init(x: 0.71, y: 0.34), .init(x: 0.48, y: 0.43)], darkRoof)
        context.fill(Path(CGRect(x: w * 0.43, y: h * 0.54, width: w * 0.09, height: h * 0.07)), with: .color(Palette.amber))
        var flag = Path()
        flag.move(to: CGPoint(x: w * 0.48, y: h * 0.13))
        flag.addLine(to: CGPoint(x: w * 0.48, y: h * 0.0))
        flag.addLine(to: CGPoint(x: w * 0.68, y: h * 0.06))
        flag.addLine(to: CGPoint(x: w * 0.48, y: h * 0.10))
        context.fill(flag, with: .color(Palette.amber))
    }

    private func drawWarehouse(_ polygon: ([CGPoint], Color) -> Void, context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        polygon([.init(x: 0.17, y: 0.42), .init(x: 0.50, y: 0.54), .init(x: 0.50, y: 0.87), .init(x: 0.17, y: 0.74)], plaster)
        polygon([.init(x: 0.50, y: 0.54), .init(x: 0.83, y: 0.40), .init(x: 0.83, y: 0.72), .init(x: 0.50, y: 0.87)], shadedStone)
        polygon([.init(x: 0.10, y: 0.42), .init(x: 0.42, y: 0.18), .init(x: 0.58, y: 0.51), .init(x: 0.50, y: 0.55)], roof)
        polygon([.init(x: 0.42, y: 0.18), .init(x: 0.74, y: 0.10), .init(x: 0.90, y: 0.39), .init(x: 0.58, y: 0.51)], darkRoof)
        context.fill(Path(CGRect(x: w * 0.31, y: h * 0.59, width: w * 0.11, height: h * 0.15)), with: .color(Color(red: 0.34, green: 0.27, blue: 0.20)))
        context.fill(Path(roundedRect: CGRect(x: w * 0.55, y: h * 0.61, width: w * 0.20, height: h * 0.10), cornerRadius: 4), with: .color(Color(red: 0.76, green: 0.56, blue: 0.34)))
        context.stroke(Path(ellipseIn: CGRect(x: w * 0.69, y: h * 0.61, width: h * 0.10, height: h * 0.10)), with: .color(Color(red: 0.42, green: 0.28, blue: 0.19)), lineWidth: 2)
    }
}
