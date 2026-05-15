//
//  CameraGuidance.swift
//  SightAssist
//
//  Sagt an, in welche Richtung die Kamera bewegt werden muss,
//  wenn Text/Objekte teilweise außerhalb des Bildes sind.
//  Arbeitet mit Haptics für taktiles Feedback.
//

import Foundation

#if canImport(UIKit) && canImport(Vision)
import UIKit
import Vision

struct CameraGuidance {

    struct FramingHint {
        let direction: Direction?
        let detections: Int

        enum Direction: String {
            case up, down, left, right
            var spoken: String {
                switch self {
                case .up:    return "Kamera etwas nach oben."
                case .down:  return "Kamera etwas nach unten."
                case .left:  return "Kamera etwas nach links."
                case .right: return "Kamera etwas nach rechts."
                }
            }
        }
    }

    /// Analysiert, ob erkannte Objekte/Text nah am Bildrand sind
    static func assessFraming(textObservations: [VNRecognizedTextObservation] = [],
                              humanObservations: [VNHumanObservation] = [],
                              imageSize: CGSize) -> FramingHint {
        let allBoxes: [CGRect] =
            textObservations.compactMap { $0.boundingBox.normalizedToPixel(relativeTo: imageSize) }
            + humanObservations.compactMap { $0.boundingBox.normalizedToPixelIfValid(relativeTo: imageSize) }

        guard !allBoxes.isEmpty else {
            return FramingHint(direction: nil, detections: 0)
        }

        // Äußerster Rand der erkannten Inhalte
        let minX = allBoxes.map(\.minX).min()!
        let maxX = allBoxes.map(\.maxX).max()!
        let minY = allBoxes.map(\.minY).min()!
        let maxY = allBoxes.map(\.maxY).max()!

        let margin: CGFloat = 0.15 // 15% Randtoleranz
        let w = imageSize.width
        let h = imageSize.height

        // Priorität: horizontal > vertikal > näher ran
        if maxX > w * (1 - margin) && minX > w * margin {
            return FramingHint(direction: .right, detections: allBoxes.count)
        }
        if minX < w * margin && maxX < w * (1 - margin) {
            return FramingHint(direction: .left, detections: allBoxes.count)
        }
        if maxY > h * (1 - margin) && minY > h * margin {
            return FramingHint(direction: .down, detections: allBoxes.count)
        }
        if minY < h * margin && maxY < h * (1 - margin) {
            return FramingHint(direction: .up, detections: allBoxes.count)
        }

        // Gut im Bild
        return FramingHint(direction: nil, detections: allBoxes.count)
    }
}

private extension CGRect {
    func normalizedToPixel(relativeTo size: CGSize) -> CGRect? {
        guard width > 0, height > 0 else { return nil }
        return CGRect(
            x: origin.x * size.width,
            y: (1 - origin.y - size.height) * size.height,
            width: size.width * size.width,
            height: size.height * size.height
        )
    }

    func normalizedToPixelIfValid(relativeTo size: CGSize) -> CGRect? {
        // Vision NormalizedRect ist bereits 0..1
        guard width > 0, height > 0, origin.x >= 0, origin.y >= 0,
              origin.x + width <= 1, origin.y + height <= 1 else { return nil }
        return normalizedToPixel(relativeTo: size)
    }
}

#else

struct CameraGuidance {
    struct FramingHint {
        let direction: Direction?; let detections: Int
        enum Direction: String { case up, down, left, right
            var spoken: String { "" }
        }
    }
    static func assessFraming(textObservations: [Any] = [],
                              humanObservations: [Any] = [],
                              imageSize: CGSize) -> FramingHint {
        FramingHint(direction: nil, detections: 0)
    }
}

#endif
