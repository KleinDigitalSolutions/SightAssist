//
//  LiveNavigationAnalyzer.swift
//  SightAssist
//
//  Kontinuierliche Live-Analyse für Modus: Navigieren.
//  Erkennt: Ampelfarben, Buslinien, Schilder.
//

import Foundation

#if canImport(UIKit) && canImport(Vision)
import Vision
import UIKit

final class LiveNavigationAnalyzer {
    private let queue = DispatchQueue(label: "navigation.analyzer.queue")

    struct NavResult {
        let description: String
    }

    func analyze(image: UIImage, completion: @escaping (Result<NavResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.success(NavResult(description: "")))
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .fast
        textRequest.usesLanguageCorrection = false
        textRequest.recognitionLanguages = ["de-DE", "en-US"]

        queue.async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([textRequest])
            } catch {
                completion(.failure(error))
                return
            }

            let texts: [String] = (textRequest.results ?? []).compactMap { obs in
                obs.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            }.filter { !$0.isEmpty }

            let results = Self.extractNavigationInfo(from: texts)
            completion(.success(NavResult(description: results)))
        }
    }

    private static func extractNavigationInfo(from texts: [String]) -> String {
        var parts: [String] = []

        // Ampel
        for text in texts {
            if text.contains("ROT") || text.contains("HALT") {
                parts.append("Ampel rot.")
                break
            } else if text.contains("GRÜN") || text.contains("GRUN") {
                parts.append("Ampel grün.")
                break
            }
        }

        // Buslinien (Zahlen, typischerweise 2-3 Stellen)
        let busPattern = try? NSRegularExpression(pattern: "^[M]?\\d{2,3}[A-Z]?$")
        for text in texts {
            let range = NSRange(location: 0, length: text.utf16.count)
            if busPattern?.firstMatch(in: text, options: [], range: range) != nil {
                parts.append("Bus \(text).")
                break
            }
        }

        // Schilder / markante Wörter
        let signWords = ["AUSGANG", "EINGANG", "NOTAUSGANG", "TOILETTE", "WC",
                         "AUFZUG", "TREPPE", "INFO", "HALTESTELLE"]
        for text in texts {
            for word in signWords {
                if text.contains(word) {
                    parts.append("\(word.lowercased()).")
                    break
                }
            }
            if parts.count > 2 { break }
        }

        if parts.isEmpty {
            return ""
        }
        return parts.joined(separator: " ")
    }
}

#else

final class LiveNavigationAnalyzer {
    struct NavResult { let description: String }
    func analyze(image: Any, completion: @escaping (Result<NavResult, Error>) -> Void) {
        completion(.success(NavResult(description: "")))
    }
}

#endif
