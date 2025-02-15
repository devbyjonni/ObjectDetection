//
//  ContentViewModel.swift
//  ObjectDetectionApp
//
//  Created by Jonni Akesson on 2025-02-15.
//

import Foundation
import AVFoundation
import Observation

@Observable
final class ContentViewModel {
    private let cameraManager: CameraManager
    private let objectDetector: ObjectDetector
    private(set) var detectedObjects: [ObservationModel] = []
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return cameraManager.previewLayer
    }
    
    init() {
        self.objectDetector = ObjectDetector()
        self.cameraManager = CameraManager()
    }
    
    /// Starts detection by setting up the camera and listening for frames.
    func startDetection() {
        Task {
            await cameraManager.setupCamera() // Ensure camera setup completes first
            await observeObjectDetection()    // Start observing after camera is ready
        }
    }
    
    /// Observes frames from the camera and processes them using async/await.

    private func observeObjectDetection() async {
        for await pixelBuffer in cameraManager.frameStream {
            let detectedObjects = await objectDetector.detectObjects(in: pixelBuffer)
            Task { @MainActor in
                self.detectedObjects = detectedObjects
            }
        }
    }
}
