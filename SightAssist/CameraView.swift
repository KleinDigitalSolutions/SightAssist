import SwiftUI
import AVFoundation

#if canImport(UIKit)
import UIKit

struct CameraView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

#else

struct CameraView: View {
    let session: AVCaptureSession
    var body: some View {
        Color.black
            .overlay(
                Text("Kamera nicht verfügbar")
                    .foregroundStyle(.white)
                    .padding()
            )
    }
}

#endif
