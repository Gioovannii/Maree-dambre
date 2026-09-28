import Foundation
import ImageIO
import CoreGraphics

func pixels(_ path: String) -> (Data, Int, Int)? {
    guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
          let context = CGContext(data: nil, width: image.width, height: image.height,
                                  bitsPerComponent: 8, bytesPerRow: image.width * 4,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    guard let bytes = context.data else { return nil }
    return (Data(bytes: bytes, count: image.width * image.height * 4), image.width, image.height)
}
guard CommandLine.arguments.count == 3,
      let (a, width, height) = pixels(CommandLine.arguments[1]),
      let (b, otherWidth, otherHeight) = pixels(CommandLine.arguments[2]),
      width == otherWidth, height == otherHeight else { exit(1) }
var changed = 0
for index in stride(from: 0, to: a.count, by: 4) {
    if (0..<3).contains(where: { abs(Int(a[index + $0]) - Int(b[index + $0])) > 3 }) { changed += 1 }
}
let ratio = Double(changed) / Double(width * height)
// Native translucent controls can vary slightly between simulator captures.
// Reject differences affecting more than 0.1% of the screen.
print(String(format: "Pixel variation: %.4f%%", ratio * 100))
exit(ratio <= 0.001 ? 0 : 1)
