import Foundation

#if canImport(UIKit) && canImport(Vision)
import Vision
import UIKit

final class TextRecognizer {
    private let queue = DispatchQueue(label: "text.recognizer.queue")

    func recognizeText(in image: UIImage, languages: [String] = ["de-DE", "en-US"], completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.success(""))
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
            completion(.success(text))
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

private extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
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
