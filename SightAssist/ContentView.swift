//
//  ContentView.swift
//  SightAssist
//
//  Created by Özgür Azap on 15.05.26.
//
//  Drei Modi, keine visuelle UI nötig — alles Sprache + Haptik.
//  Single Tap = Scannen. Double Tap = Gemma. Wischen = Modus.
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
    @State private var modeManager: ModeManager!

    @State private var isCapturing = false
    @State private var ttsBuffer = ""
    @State private var visionModel = VisionModel()
    @State private var navAnalyzer = LiveNavigationAnalyzer()
    @State private var navTimer: Timer?

#if canImport(UIKit)
    @State private var captureProxy: PhotoCaptureProxy?
#endif

    private let objectDetector = ObjectDetector()
    private let textRecognizer = TextRecognizer()

    var body: some View {
        ZStack {
            CameraView(session: controller.session)
                .accessibilityLabel("Kameravorschau")

            if controller.authorizationStatus == .denied || controller.authorizationStatus == .restricted {
                cameraDeniedOverlay
            }

            VStack {
                Spacer()
                HStack(spacing: 12) {
                    ForEach(AppMode.allCases, id: \.self) { mode in
                        ModeChip(mode: mode, isActive: mode == modeManager?.currentMode)
                    }
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            }
            .padding()

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(count: 2) { triggerGemma() }
                .onTapGesture(count: 1) { triggerScan() }
                .allowsHitTesting(true)
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -80 { modeManager.switchToNext() }
                    else if value.translation.width > 80 { modeManager.switchToPrevious() }
                }
        )
        .onChange(of: controller.authorized) { _, newValue in
            if !newValue { speaker.speak("Kamerazugriff nicht erlaubt.") }
        }
        .onAppear {
            modeManager = ModeManager(speaker: speaker)
            modeManager.announceLaunch()
        }
        .task { await visionModel.prepare() }
        .onChange(of: modeManager?.currentMode) { _, newMode in
            guard let newMode else { return }
            switch newMode {
            case .navigate: startNavigation()
            default: stopNavigation()
            }
        }
    }

    // MARK: - Mode 1 & 2: Scannen + Navigieren

    private func triggerScan() {
        guard !isCapturing, controller.authorized else { return }
        let mode = modeManager.currentMode

        if mode == .navigate { return } // Navigation läuft live, kein Tap

        isCapturing = true
        Haptics.thinking()

        capturePhoto { image in
            defer { isCapturing = false }
            guard let image else {
                speaker.speak("Kein Bild.")
                Haptics.error()
                return
            }

            if mode == .scan {
                objectDetector.scan(in: image) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let scan):
                            var parts: [String] = []
                            if !scan.text.isEmpty { parts.append("Text: \(scan.text)") }
                            if scan.personCount > 0 { parts.append("\(scan.personCount) \(scan.personCount == 1 ? "Person" : "Personen")") }
                            if scan.dominantColor != "unbekannt" { parts.append("Farbe: \(scan.dominantColor)") }
                            let msg = parts.isEmpty ? "Nichts erkannt." : parts.joined(separator: ". ") + "."
                            speaker.speak(msg)
                            Haptics.success()
                        case .failure:
                            speaker.speak("Fehler beim Scannen.")
                            Haptics.error()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Live Navigation

    private func startNavigation() {
        speaker.speak("Navigation läuft.")
        navTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            guard !isCapturing else { return }
            isCapturing = true
            capturePhoto { image in
                defer { isCapturing = false }
                guard let image else { return }
                navAnalyzer.analyze(image: image) { result in
                    DispatchQueue.main.async {
                        if case .success(let nav) = result, !nav.description.isEmpty {
                            speaker.speak(nav.description)
                        }
                    }
                }
            }
        }
    }

    private func stopNavigation() {
        navTimer?.invalidate()
        navTimer = nil
    }

    // MARK: - Double Tap: Gemma (jeder Modus)

    private func triggerGemma() {
        guard !isCapturing, controller.authorized else { return }
        guard case .ready = visionModel.state else {
            speaker.speak("KI-Modell wird noch geladen.")
            return
        }
        isCapturing = true
        Haptics.thinking()
        speaker.speak("Beschreibe Bild.")

        capturePhoto { image in
            defer { isCapturing = false }
            guard let image else {
                speaker.speak("Kein Bild.")
                Haptics.error()
                return
            }
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
                    Haptics.success()
                } catch {
                    speaker.speak("Fehler bei der Beschreibung.")
                    Haptics.error()
                }
            }
        }
    }

    // MARK: - Kamera-Fehler

    private var cameraDeniedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Kamerazugriff erforderlich")
                .font(.headline)
            Text("SightAssist benötigt die Kamera.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                openSettings()
            } label: {
                Label("Einstellungen öffnen", systemImage: "gear")
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kamerazugriff nicht erlaubt. Tippen für Einstellungen.")
    }

#if canImport(UIKit)
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
#else
    private func openSettings() {}
#endif

    // MARK: - Foto aufnehmen

    private func capturePhoto(completion: @escaping (UIImage?) -> Void) {
#if canImport(UIKit)
        let proxy = PhotoCaptureProxy(controller: controller, completion: { image in
            DispatchQueue.main.async { completion(image) }
        })
        captureProxy = proxy
        proxy.capture()
#else
        completion(nil)
#endif
    }
}

// MARK: - PhotoCaptureProxy

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
