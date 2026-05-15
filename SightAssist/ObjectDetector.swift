//
//  ObjectDetector.swift
//  SightAssist
//

import Foundation

#if canImport(UIKit) && canImport(Vision)
import Vision
import UIKit

final class ObjectDetector {
    private let queue = DispatchQueue(label: "object.detector.queue")

    struct DetectionResult {
        let description: String
    }

    func detect(in image: UIImage, completion: @escaping (Result<DetectionResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.success(DetectionResult(description: "Kein Bild verfügbar.")))
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        // Text-Erkennung
        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        textRequest.recognitionLanguages = ["de-DE", "en-US"]

        // Personenerkennung (Human Rectangle)
        let humanRequest = VNDetectHumanRectanglesRequest()

        queue.async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([textRequest, humanRequest])
            } catch {
                completion(.failure(error))
                return
            }

            let textObservations = textRequest.results ?? []
            let humanObservations = humanRequest.results ?? []

            let parts: [String] = buildDescription(
                textObservations: textObservations,
                humanObservations: humanObservations
            )

            let description: String
            if parts.isEmpty {
                description = "Keine Personen oder Texte erkannt."
            } else {
                description = parts.joined(separator: " ")
            }

            completion(.success(DetectionResult(description: description)))
        }
    }

    private func buildDescription(
        textObservations: [VNRecognizedTextObservation],
        humanObservations: [VNHumanObservation]
    ) -> [String] {
        var parts: [String] = []

        // Personen
        if !humanObservations.isEmpty {
            let count = humanObservations.count
            parts.append("\(count) \(count == 1 ? "Person" : "Personen") erkannt.")
        }

        // Text
        let detectedTexts: [String] = textObservations.compactMap { obs in
            obs.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }

        if !detectedTexts.isEmpty {
            let joined = detectedTexts.joined(separator: ", ")
            parts.append("Erkannter Text: \(joined).")
        }

        return parts
    }
}

#else

final class ObjectDetector {
    struct DetectionResult {
        let description: String
    }

    func detect(in image: Any, completion: @escaping (Result<DetectionResult, Error>) -> Void) {
        completion(.success(DetectionResult(description: "")))
    }
}

#endif
