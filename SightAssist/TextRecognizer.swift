import Foundation

#if canImport(UIKit) && canImport(Vision)
import Vision
import UIKit

final class TextRecognizer {
    private let queue = DispatchQueue(label: "text.recognizer.queue")

    enum RecognitionError: LocalizedError {
        case invalidImage
        case processingFailed
        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Bild konnte nicht verarbeitet werden."
            case .processingFailed:
                return "Texterkennung fehlgeschlagen."
            }
        }
    }

    func recognizeText(in image: UIImage, languages: [String] = ["de-DE", "en-US"], completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(RecognitionError.invalidImage))
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.success(""))
                return
            }
            let lines: [String] = observations.compactMap { obs in
                obs.topCandidates(1).first?.string
            }
            let text = lines.joined(separator: "\n")
            if text.isEmpty {
                completion(.failure(RecognitionError.processingFailed))
            } else {
                completion(.success(text))
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = languages

        queue.async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}

#else

final class TextRecognizer {
    func recognizeText(in image: Any, languages: [String] = ["de-DE", "en-US"], completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success(""))
    }
}

#endif
