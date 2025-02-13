//
//  ObjectDetector.swift
//  ObjectDetectionApp
//
//  Created by Jonni Akesson on 2025-02-12.
//

import Vision
import os

final class ObjectDetector {
    private let model: VNCoreMLModel
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.default.ObjectDetectionApp", category: "ObjectDetector")
    
    init() {
        do {
            let coreMLModel = try YOLOv3(configuration: MLModelConfiguration()).model
            self.model = try VNCoreMLModel(for: coreMLModel)
            logger.info("✅ YOLOv3 model loaded successfully.")
        } catch {
            fatalError("🚨 Failed to load YOLOv3 model: \(error.localizedDescription)")
        }
    }
    
    /// Detects objects in a given `CVPixelBuffer`
    func detectObjects(in pixelBuffer: CVPixelBuffer) {
        Task(priority: .userInitiated) {
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    self.logger.error("🚨 Vision request failed: \(error.localizedDescription)")
                    return
                }
                
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    self.logger.warning("⚠️ No objects detected in frame.")
                    return
                }
                
                let detectedObjects = results.compactMap { result -> Observation? in
                    guard let label = result.labels.first else { return nil }
                    return Observation(label: label.identifier, confidence: label.confidence, boundingBox: result.boundingBox)
                }
                
                self.logger.info("🔍 Detected \(detectedObjects.count) objects.")
                
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .detectedObjectsUpdated,
                        object: detectedObjects
                    )
                }
            }
            
            request.revision = VNCoreMLRequest.defaultRevision
            request.imageCropAndScaleOption = .centerCrop
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            
            do {
                try requestHandler.perform([request])
                self.logger.info("✅ Vision request completed successfully.")
            } catch {
                self.logger.error("🚨 Failed to perform Vision request: \(error.localizedDescription)")
            }
        }
    }
}
