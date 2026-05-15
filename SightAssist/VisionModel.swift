import Foundation

#if canImport(MLXLLM) && canImport(MLXLMCommon) && canImport(MLXHuggingFace) && canImport(HuggingFace) && canImport(Tokenizers)
import UIKit
import MLXLLM
import MLXLMCommon
import MLXHuggingFace
import HuggingFace
import Tokenizers

final class VisionModel {
    private var container: ModelContainer?
    private var isPreparing = false

    enum State {
        case notLoaded, loading, ready, inferring
        case error(String)
        var description: String {
            switch self {
            case .notLoaded: return "Nicht geladen"
            case .loading: return "Lädt KI-Modell"
            case .ready: return "Bereit"
            case .inferring: return "Analysiere"
            case .error(let m): return "Fehler: \(m)"
            }
        }
    }
    var state: State = .notLoaded

    func prepare() async {
        guard !isPreparing, container == nil else { return }
        isPreparing = true; state = .loading
        do {
            let config = ModelConfiguration(id: "mlx-community/gemma-4-e2b-it-4bit")
            container = try await #huggingFaceLoadModelContainer(configuration: config)
            state = .ready
        } catch { state = .error(error.localizedDescription) }
        isPreparing = false
    }

    func describe(image: UIImage, question: String? = nil) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream<String, Error> { c in Task {
            guard let container else { c.finish(throwing: VisionModelError.notLoaded); return }
            state = .inferring; defer { state = .ready }
            let prompt = question ?? "Beschreibe kurz auf Deutsch, was zu sehen ist."
            let system = "Assistent fuer blinde Menschen. Deutsch, max. 3 Saetze."
            do {
                let session = ChatSession(container)
                let combined = "System: \(system)\nUser: \(prompt)"
                let r = try await session.respond(to: combined)
                c.yield(r); c.finish()
            } catch { c.finish(throwing: error) }
        }}
    }
}

enum VisionModelError: LocalizedError {
    case notLoaded
    var errorDescription: String? { "KI-Modell nicht geladen." }
}

#else

final class VisionModel {
    enum State {
        case notLoaded, loading, ready, inferring
        case error(String)
        var description: String { "Nicht verfuegbar" }
    }
    var state: State = .notLoaded
    func prepare() async {}
    func describe(image: Any, question: String? = nil) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish(throwing: VisionModelError.notLoaded) }
    }
}

enum VisionModelError: LocalizedError {
    case notLoaded
    var errorDescription: String? { "Nicht verfuegbar" }
}

#endif
