//
//  ContentView.swift
//  SightAssist
//
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

    var body: some View {
        ZStack {
            CameraView(session: controller.session).accessibilityLabel("Kameravorschau")
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
                .padding(8).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            }
            .padding()
            Color.clear.contentShape(Rectangle())
                .onTapGesture(count: 2) { triggerGemma() }
                .onTapGesture(count: 1) { triggerScan() }
                .allowsHitTesting(true)
        }
        .gesture(DragGesture(minimumDistance: 50).onEnded { value in
            if value.translation.width < -80 { modeManager.switchToNext() }
            else if value.translation.width > 80 { modeManager.switchToPrevious() }
        })
        .onChange(of: controller.authorized) { _, v in if !v { speaker.speak("Kamerazugriff nicht erlaubt.") } }
        .onAppear { modeManager = ModeManager(speaker: speaker); modeManager.announceLaunch() }
        .task { await visionModel.prepare() }
        .onChange(of: modeManager?.currentMode) { _, m in
            guard let m else { return }
            if case .navigate = m { startNavigation() } else { stopNavigation() }
        }
    }

    private func triggerScan() {
        guard !isCapturing, controller.authorized, modeManager.currentMode != .navigate else { return }
        isCapturing = true; Haptics.thinking()
        capturePhoto { image in
            defer { isCapturing = false }
            guard let image else { speaker.speak("Kein Bild."); Haptics.error(); return }
            guard let uiImage = image as? UIImage else { return }
            objectDetector.scan(in: uiImage) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let s):
                        var p: [String] = []
                        if !s.text.isEmpty { p.append("Text: \(s.text)") }
                        if s.personCount > 0 { p.append("\(s.personCount) \(s.personCount == 1 ? "Person" : "Personen")") }
                        if s.dominantColor != "unbekannt" { p.append("Farbe: \(s.dominantColor)") }
                        speaker.speak(p.isEmpty ? "Nichts erkannt." : p.joined(separator: ". ") + ".")
                        Haptics.success()
                    case .failure: speaker.speak("Fehler beim Scannen."); Haptics.error()
                    }
                }
            }
        }
    }

    private func startNavigation() {
        speaker.speak("Navigation läuft.")
        navTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            guard !self.isCapturing else { return }
            self.isCapturing = true
            self.capturePhoto { image in
                defer { self.isCapturing = false }
                guard let image else { return }
                guard let uiImage = image as? UIImage else { return }
                self.navAnalyzer.analyze(image: uiImage) { result in
                    DispatchQueue.main.async {
                        if case .success(let n) = result, !n.description.isEmpty { self.speaker.speak(n.description) }
                    }
                }
            }
        }
    }

    private func stopNavigation() { navTimer?.invalidate(); navTimer = nil }

    private func triggerGemma() {
        guard !isCapturing, controller.authorized else { return }
        guard case .ready = visionModel.state else { speaker.speak("KI-Modell wird noch geladen."); return }
        isCapturing = true; Haptics.thinking(); speaker.speak("Beschreibe Bild.")
        capturePhoto { image in
            defer { isCapturing = false }
            guard let image else { speaker.speak("Kein Bild."); Haptics.error(); return }
            guard let uiImage = image as? UIImage else { return }
            self.ttsBuffer = ""
            Task {
                do {
                    for try await chunk in self.visionModel.describe(image: uiImage) {
                        await MainActor.run { self.speaker.streamChunk(chunk, buffer: &self.ttsBuffer) }
                    }
                    if !self.ttsBuffer.isEmpty { self.speaker.speak(self.ttsBuffer); self.ttsBuffer = "" }
                    Haptics.success()
                } catch { speaker.speak("Fehler bei der Beschreibung."); Haptics.error() }
            }
        }
    }

    private var cameraDeniedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill").font(.system(size: 40)).foregroundStyle(.secondary)
            Text("Kamerazugriff erforderlich").font(.headline)
            Button { openSettings() } label: {
                Label("Einstellungen öffnen", systemImage: "gear")
            }.buttonStyle(.borderedProminent)
        }
        .padding(32).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine).accessibilityLabel("Kamerazugriff nicht erlaubt.")
    }

#if canImport(UIKit)
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
#else
    private func openSettings() {}
#endif

    private func capturePhoto(completion: @escaping (Any?) -> Void) {
#if canImport(UIKit)
        let proxy = PhotoCaptureProxy(controller: controller, completion: { img in
            DispatchQueue.main.async { completion(img) }
        })
        captureProxy = proxy; proxy.capture()
#else
        completion(nil)
#endif
    }
}

#if canImport(UIKit)
final class PhotoCaptureProxy: NSObject, AVCapturePhotoCaptureDelegate {
    private let controller: CaptureController
    private let completion: (UIImage?) -> Void
    init(controller: CaptureController, completion: @escaping (UIImage?) -> Void) {
        self.controller = controller; self.completion = completion
    }
    func capture() { controller.capturePhoto(delegate: self) }
    func photoOutput(_ o: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        completion(photo.fileDataRepresentation().flatMap(UIImage.init(data:)))
    }
}
#endif

private struct ModeChip: View {
    let mode: AppMode; let isActive: Bool
    var body: some View {
        Text(mode.shortLabel).font(.caption).fontWeight(isActive ? .bold : .regular)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(isActive ? AnyShapeStyle(Color.accentColor.opacity(0.8)) : AnyShapeStyle(Material.ultraThinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 8)).foregroundColor(isActive ? .white : .primary)
    }
}

#Preview { ContentView() }
