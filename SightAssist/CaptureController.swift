import Foundation
import AVFoundation

final class CaptureController: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    @Published var authorized: Bool = false

    override init() {
        super.init()
        configureAudioSession()
        checkAndConfigureCamera()
    }

    private func configureAudioSession() {
        let audio = AVAudioSession.sharedInstance()
        do {
            try audio.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audio.setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
    }

    private func checkAndConfigureCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorized = true
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorized = granted
                }
                if granted {
                    self?.configureSession()
                }
            }
        default:
            authorized = false
            // Consider prompting user to enable camera in Settings
        }
    }

    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)

            guard self.session.canAddOutput(self.photoOutput) else {
                self.session.commitConfiguration()
                return
            }
            self.session.addOutput(self.photoOutput)

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func capturePhoto(delegate: AVCapturePhotoCaptureDelegate) {
        let settings = AVCapturePhotoSettings()
        sessionQueue.async {
            self.photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }
}
