//
//  ObjectDetector.swift
//  SightAssist
//
//  Multi-Detektion: Text + Personen + dominante Farbe — parallel.
//

import Foundation

#if canImport(UIKit) && canImport(Vision)
import Vision
import UIKit

final class ObjectDetector {
    private let queue = DispatchQueue(label: "object.detector.queue")

    struct ScanResult {
        let text: String
        let personCount: Int
        let dominantColor: String
    }

    func scan(in image: UIImage, completion: @escaping (Result<ScanResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(RecognitionError.invalidImage))
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        // Text
        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        textRequest.recognitionLanguages = ["de-DE", "en-US"]

        // Personen
        let humanRequest = VNDetectHumanRectanglesRequest()

        queue.async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([textRequest, humanRequest])
            } catch {
                completion(.failure(error))
                return
            }

            let textResults = textRequest.results ?? []
            let humanResults = humanRequest.results ?? []

            // Text extrahieren
            let texts: [String] = textResults.compactMap { obs in
                obs.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines)
            }.filter { !$0.isEmpty }
            let text = texts.joined(separator: ". ")

            // Farbe (dominant, Zentrum)
            let color = Self.dominantColor(in: cgImage)

            // Framing-Hinweis
            let framing = CameraGuidance.assessFraming(
                textObservations: textResults,
                humanObservations: humanResults,
                imageSize: CGSize(width: cgImage.width, height: cgImage.height)
            )

            var parts: [String] = []
            if !text.isEmpty { parts.append("Text: \(text).") }
            if humanResults.count > 0 {
                parts.append("\(humanResults.count) \(humanResults.count == 1 ? "Person" : "Personen").")
            }
            if color != "unbekannt" { parts.append("Farbe: \(color).") }
            if let dir = framing.direction { parts.append(dir.spoken) }

            let description = parts.isEmpty ? "Nichts erkannt." : parts.joined(separator: " ")

            completion(.success(ScanResult(
                text: text,
                personCount: humanResults.count,
                dominantColor: color
            )))
        }
    }

    // MARK: - Dominante Farbe im Bildzentrum

    private static func dominantColor(in cgImage: CGImage) -> String {
        let w = cgImage.width
        let h = cgImage.height
        let rect = CGRect(x: w / 4, y: h / 4, width: w / 2, height: h / 2)

        guard let cropped = cgImage.cropping(to: rect) else { return "unbekannt" }
        guard let data = cropped.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return "unbekannt" }

        let length = CFDataGetLength(data)
        var rSum = 0.0, gSum = 0.0, bSum = 0.0
        let pixelCount = length / 4
        guard pixelCount > 0 else { return "unbekannt" }

        for i in stride(from: 0, to: length, by: 4) {
            rSum += Double(bytes[i])
            gSum += Double(bytes[i + 1])
            bSum += Double(bytes[i + 2])
        }

        let r = rSum / Double(pixelCount)
        let g = gSum / Double(pixelCount)
        let b = bSum / Double(pixelCount)

        return classifyColor(r: r, g: g, b: b)
    }

    private static func classifyColor(r: Double, g: Double, b: Double) -> String {
        let maxVal = max(r, g, b)
        let minVal = min(r, g, b)
        let saturation = maxVal > 0 ? (maxVal - minVal) / maxVal : 0

        if saturation < 0.15 {
            if maxVal > 200 { return "weiß" }
            if maxVal < 80 { return "schwarz" }
            return "grau"
        }

        let hue: Double
        if maxVal == r {
            hue = (g - b) / (maxVal - minVal)
        } else if maxVal == g {
            hue = 2.0 + (b - r) / (maxVal - minVal)
        } else {
            hue = 4.0 + (r - g) / (maxVal - minVal)
        }
        let h = (hue * 60).truncatingRemainder(dividingBy: 360)
        if h < 0 { return classifyByBrightness(r: r, g: g, b: b) }

        switch h {
        case 0..<25:   return r > 180 ? "rot" : "dunkelrot"
        case 25..<45:  return "orange"
        case 45..<70:  return g > 160 ? "gelb" : "braun"
        case 70..<170: return g > b ? "grün" : "türkis"
        case 170..<260: return b > r ? "blau" : "violett"
        case 260..<320: return "lila"
        default: return classifyByBrightness(r: r, g: g, b: b)
        }
    }

    private static func classifyByBrightness(r: Double, g: Double, b: Double) -> String {
        let avg = (r + g + b) / 3
        if avg > 180 { return "hellrot" }
        if avg < 80 { return "dunkel" }
        return "rot"
    }
}

enum RecognitionError: LocalizedError {
    case invalidImage
    var errorDescription: String? { "Bild konnte nicht verarbeitet werden." }
}

#else

final class ObjectDetector {
    struct ScanResult { let text = ""; let personCount = 0; let dominantColor = "" }
    func scan(in image: Any, completion: @escaping (Result<ScanResult, Error>) -> Void) {
        completion(.failure(NSError(domain: "", code: 0)))
    }
}

#endif
