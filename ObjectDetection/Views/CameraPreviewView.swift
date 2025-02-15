//
//  CameraPreviewView.swift
//  YOLOv3Demo
//
//  Created by Jonni Akesson on 2025-02-12.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black // Ensure it doesn't default to black if no preview
        
        if let layer = previewLayer {
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            view.layer.addSublayer(layer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("🔍 updateUIView called. previewLayer is \(previewLayer == nil ? "nil" : "not nil")")
        Task { @MainActor in
            previewLayer?.frame = uiView.bounds
            if let layer = previewLayer, layer.superlayer == nil {
                uiView.layer.addSublayer(layer)
            }
        }
    }
}
