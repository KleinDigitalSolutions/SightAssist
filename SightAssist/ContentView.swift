//
//  ContentView.swift
//  SightAssist
//
//  Created by Özgür Azap on 15.05.26.
//

import SwiftUI
import AVFoundation
import Vision

#if canImport(UIKit)
import UIKit
#endif

struct ContentView: View {
    @StateObject private var speaker = Speaker()
    @StateObject private var controller = CaptureController()

    @AppStorage("appMode") private var modeRawValue: String = AppMode.context.rawValue

    @State private var isCapturing = false
    @State private var dragOffset: CGFloat = 0
#if canImport(UIKit)
    @State private var captureProxy: PhotoCaptureProxy?
#endif

    private let textRecognizer = TextRecognizer()
    private let objectDetector = ObjectDetector()

    @State private var visionModel = VisionModel()
    @State private var ttsBuffer = ""

    private var currentMode: AppMode {
        AppMode(rawValue: modeRawValue) ?? .context
    }

    var body: some View {
        ZStack {
            CameraView(session: controller.session)
                .accessibilityLabel("Kameravorschau")
                .accessibilityHint(currentMode.accessibilityHint)

            // Kamera-verweigert-Overlay
            if controller.authorizationStatus == .denied || controller.authorizationStatus == .restricted {
                cameraDeniedOverlay
            }

            // Modus-Indikator am oberen Rand
            VStack {
                modeIndicator
                Spacer()
                statusLabel
            }
            .padding()

            // Analyse-Button (unsichtbar, volle Fläche)
            Color.clear
                .contentShape(Rectangle())
                .overlay(
                    Button(action: triggerAnalysis) {
                        Text("")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Bild analysieren (\(currentMode.shortLabel))")
                    .accessibilityHint(currentMode.accessibilityHint)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
                .allowsHitTesting(true)
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 80
                    if value.translation.width < -threshold {
                        // Nach links gewischt → nächster Modus
                        switchToNextMode()
                    } else if value.translation.width > threshold {
                        // Nach rechts gewischt → vorheriger Modus
                        switchToPreviousMode()
                    }
                    dragOffset = 0
                }
        )
        .onChange(of: controller.authorized) { _, newValue in
            if !newValue {
                speaker.speak("Kamerazugriff nicht erlaubt. Bitte in den Einstellungen aktivieren.")
            }
        }
        .task {
            await visionModel.prepare()
        }
        .onAppear {
            announceCurrentMode()
        }
    }

    // MARK: - Modus-Indikator

    private var modeIndicator: some View {
        HStack(spacing: 12) {
            ForEach(AppMode.allCases, id: \.self) { mode in
                ModeChip(mode: mode, isActive: mode == currentMode)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityHidden(true)
    }

    private var statusLabel: some View {
        let labelText: String = {
            if isCapturing { return "Analysiere..." }
            if currentMode == .vlm, case .downloading = visionModel.state {
                return "Lade KI-Modell..."
            }
            return "Doppeltippen zum Analysieren"
        }()
        return Text(labelText)
            .font(.headline)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)
    }

    private var cameraDeniedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Kamerazugriff erforderlich")
                .font(.headline)
            Text("SightAssist benötigt die Kamera, um Ihre Umgebung zu beschreiben.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button {
                openSystemSettings()
            } label: {
                Label("Einstellungen öffnen", systemImage: "gear")
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Öffnet die Systemeinstellungen, um den Kamerazugriff zu erlauben.")
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kamerazugriff nicht erlaubt. Tippen, um Einstellungen zu öffnen.")
    }

#if canImport(UIKit)
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
#else
    private func openSystemSettings() {}
#endif

    // MARK: - Modus-Umschaltung

    private func switchToNextMode() {
        let all = AppMode.allCases
        guard let idx = all.firstIndex(of: currentMode) else { return }
        let next = all[(idx + 1) % all.count]
        modeRawValue = next.rawValue
        announceCurrentMode()
    }

    private func switchToPreviousMode() {
        let all = AppMode.allCases
        guard let idx = all.firstIndex(of: currentMode) else { return }
        let prev = all[(idx - 1 + all.count) % all.count]
        modeRawValue = prev.rawValue
        announceCurrentMode()
    }

    private func announceCurrentMode() {
        speaker.speak(currentMode.voiceOverLabel)
    }

    // MARK: - Analyse-Trigger

    private func triggerAnalysis() {
        #if canImport(UIKit)
        guard !isCapturing, controller.authorized else { return }
        DispatchQueue.main.async {
            self.isCapturing = true
        }
        let modeMessage: String = {
            switch currentMode {
            case .context:   return "Analysiere Text."
            case .detection: return "Erkenne Objekte."
            case .vlm:       return "Beschreibe Bild."
            }
        }()
        speaker.speak(modeMessage)
        let proxy = PhotoCaptureProxy(controller: controller) { image in
            defer {
                DispatchQueue.main.async {
                    self.isCapturing = false
                    self.captureProxy = nil
                }
            }
            guard let image = image else {
                speaker.speak("Kein Bild verfügbar.")
                return
            }
            Haptics.tap()
            switch currentMode {
            case .context:
                textRecognizer.recognizeText(in: image) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let text):
                            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                            speaker.speak(trimmed.isEmpty ? "Ich konnte keinen Text erkennen." : trimmed)
                        case .failure:
                            speaker.speak("Fehler bei der Texterkennung.")
                        }
                    }
                }
            case .detection:
                objectDetector.detect(in: image) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let detection):
                            speaker.speak(detection.description)
                        case .failure:
                            speaker.speak("Fehler bei der Objekterkennung.")
                        }
                    }
                }
            case .vlm:
                ttsBuffer = ""
                Task {
                    do {
                        for try await chunk in visionModel.describe(image: image) {
                            await MainActor.run {
                                speaker.streamChunk(chunk, buffer: &ttsBuffer)
                            }
                        }
                        if !ttsBuffer.isEmpty {
                            speaker.speak(ttsBuffer)
                            ttsBuffer = ""
                        }
                    } catch {
                        speaker.speak("Fehler bei der Bildbeschreibung.")
                    }
                }
            }
        }
        captureProxy = proxy
        proxy.capture()
        #else
        speaker.speak("Diese Funktion ist auf dieser Plattform nicht verfügbar.")
        #endif
    }
}

#if canImport(UIKit)
final class PhotoCaptureProxy: NSObject, AVCapturePhotoCaptureDelegate {
    private let controller: CaptureController
    private let completion: (UIImage?) -> Void

    init(controller: CaptureController, completion: @escaping (UIImage?) -> Void) {
        self.controller = controller
        self.completion = completion
    }

    func capture() {
        controller.capturePhoto(delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let data = photo.fileDataRepresentation()
        let image = data.flatMap(UIImage.init(data:))
        completion(image)
    }
}
#endif

// MARK: - ModeChip

private struct ModeChip: View {
    let mode: AppMode
    let isActive: Bool

    var body: some View {
        Text(mode.shortLabel)
            .font(.caption)
            .fontWeight(isActive ? .bold : .regular)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isActive ? AnyShapeStyle(Color.accentColor.opacity(0.8)) : AnyShapeStyle(Material.ultraThinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .foregroundColor(isActive ? .white : .primary)
    }
}

#Preview {
    ContentView()
}
