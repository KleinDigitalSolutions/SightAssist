//
//  ContentView.swift
//  SightAssist
//
//  Created by Özgür Azap on 15.05.26.
//

import SwiftUI
import AVFoundation
import Vision
import UIKit

struct ContentView: View {
    @StateObject private var speaker = Speaker()
    @StateObject private var controller = CaptureController()

    @State private var isCapturing = false
    @State private var captureProxy: PhotoCaptureProxy?

    private let textRecognizer = TextRecognizer()

    var body: some View {
        ZStack {
            CameraView(session: controller.session)
                .accessibilityLabel("Kameravorschau")
                .accessibilityHint("Doppeltippen, um ein Bild zu analysieren.")

            VStack {
                Spacer()
                Text(isCapturing ? "Analysiere..." : "Doppeltippen zum Analysieren")
                    .font(.headline)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)
            }
            .padding()

            // Unsichtbarer, aber zugänglicher Button über die ganze Fläche
            Color.clear
                .contentShape(Rectangle())
                .overlay(
                    Button(action: triggerAnalysis) {
                        Text("")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Bild analysieren")
                    .accessibilityHint("Doppeltippen, um ein Foto aufzunehmen und zu beschreiben.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
                .allowsHitTesting(true)
        }
        .onChange(of: controller.authorized) { _, newValue in
            if !newValue {
                speaker.speak("Kamerazugriff nicht erlaubt. Bitte in den Einstellungen aktivieren.")
            }
        }
        .onAppear {
            speaker.speak("SightAssist bereit. Doppeltippen zum Analysieren.")
        }
    }

    private func triggerAnalysis() {
        guard !isCapturing, controller.authorized else { return }
        isCapturing = true
        speaker.speak("Analysiere.")
        let proxy = PhotoCaptureProxy(controller: controller) { image in
            defer {
                isCapturing = false
                captureProxy = nil
            }
            guard let image = image else {
                speaker.speak("Kein Bild verfügbar.")
                return
            }
            Haptics.tap()
            textRecognizer.recognizeText(in: image) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let text):
                        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            speaker.speak("Ich konnte keinen Text erkennen.")
                        } else {
                            speaker.speak(text)
                        }
                    case .failure:
                        speaker.speak("Fehler bei der Texterkennung.")
                    }
                }
            }
        }
        captureProxy = proxy
        proxy.capture()
    }
}

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

#Preview {
    ContentView()
}
