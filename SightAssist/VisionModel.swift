//
//  VisionModel.swift
//  SightAssist
//
//  Lokale VLM-Bildbeschreibung mit Apple MLX und Google Gemma 4.
//  Läuft vollständig auf dem Gerät – kein Netzwerk nötig.
//
//  Abhängigkeiten (SPM):
//    - mlx-swift-lm  (https://github.com/ml-explore/mlx-swift-lm)
//    - swift-huggingface (https://github.com/huggingface/swift-huggingface)
//    - swift-transformers (https://github.com/huggingface/swift-transformers)
//

import Foundation
import SwiftUI

#if canImport(UIKit) && canImport(MLXLLM) && canImport(MLXLMCommon)
import UIKit
import MLXLLM
import MLXLMCommon
import MLXHuggingFace

@Observable
final class VisionModel {
    private var container: ModelContainer?
    private var isLoading = false

    enum State {
        case notLoaded
        case downloading(Double)   // 0.0 ... 1.0
        case loading
        case ready
        case inferring
        case error(String)

        var description: String {
            switch self {
            case .notLoaded:       return "Nicht geladen"
            case .downloading(let p): return "Lädt \(Int(p * 100))%"
            case .loading:          return "Initialisiere …"
            case .ready:            return "Bereit"
            case .inferring:        return "Analysiere …"
            case .error(let msg):   return "Fehler: \(msg)"
            }
        }
    }

    var state: State = .notLoaded

    // MARK: - Modell laden (einmalig)

    func prepare() async {
        guard container == nil, !isLoading else { return }
        isLoading = true
        state = .downloading(0)

        do {
            // Gemma 4 E2B – speziell für mobile/edge-Geräte optimiert
            // ~1,3 GB Download, ~3,2 GB im Speicher bei 4-bit
            container = try await MLXHuggingFace.loadModelContainer(
                hub: .init(
                    repo: "mlx-community/gemma-4-e2b-it-4bit",
                    downloadProgress: { [weak self] progress in
                        Task { @MainActor in
                            self?.state = .downloading(progress.fractionCompleted)
                        }
                    }
                )
            )
            state = .ready
        } catch {
            state = .error(error.localizedDescription)
        }
        isLoading = false
    }

    // MARK: - Bild analysieren

    func describe(
        image: UIImage,
        question: String? = nil
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                guard let container else {
                    continuation.finish(throwing: VisionModelError.notLoaded)
                    return
                }
                guard case .ready = state else {
                    continuation.finish(throwing: VisionModelError.notReady)
                    return
                }

                state = .inferring
                defer { state = .ready }

                let prompt = question ?? "Beschreibe kurz auf Deutsch, was zu sehen ist."
                let systemPrompt = """
                Du bist ein Assistent für blinde Menschen.
                Regeln:
                - Kein "Ich sehe", "Das Bild zeigt", "Auf dem Bild".
                - Direkt mit der Beschreibung beginnen.
                - Deutsch, präzise, maximal 3 Sätze.
                - Zahlen und Texte wortwörtlich vorlesen.
                """

                do {
                    let session = ChatSession(container)
                    let stream = session.streamResponse(
                        to: prompt,
                        systemPrompt: systemPrompt,
                        images: [image]
                    )
                    for try await chunk in stream {
                        continuation.yield(chunk)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

enum VisionModelError: LocalizedError {
    case notLoaded
    case notReady

    var errorDescription: String? {
        switch self {
        case .notLoaded: return "KI-Modell ist noch nicht geladen."
        case .notReady:  return "KI-Modell ist noch nicht bereit."
        }
    }
}

#else

// Fallback für Plattformen ohne MLX
@Observable
final class VisionModel {
    enum State {
        case notLoaded
        case downloading(Double)
        case loading
        case ready
        case inferring
        case error(String)
        var description: String { "Nicht verfügbar" }
    }

    var state: State = .notLoaded

    func prepare() async {}

    func describe(image: Any, question: String? = nil) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish(throwing: VisionModelError.notLoaded) }
    }
}

enum VisionModelError: LocalizedError {
    case notLoaded
    case notReady
    var errorDescription: String? { "Nicht verfügbar" }
}

#endif
