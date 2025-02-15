//
//  ObjectDetector.swift
//  ObjectDetectionApp
//
//  Created by Jonni Akesson on 2025-02-12.
//

import Vision
import os
import Observation

/// Observable object responsible for detecting objects using CoreML and Vision
@Observable
final class ObjectDetector {
    
    /// Logger for debugging and tracking object detection process
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.default.ObjectDetectionApp", category: "ObjectDetector")
    
    /// CoreML model wrapped for use with Apple's Vision framework
    private let model: VNCoreMLModel

    /// Initializes the ObjectDetector by loading the YOLOv3 model
    init() {
        do {
            // Load YOLOv3 model with its configuration
            let coreMLModel = try YOLOv3(configuration: MLModelConfiguration()).model
            self.model = try VNCoreMLModel(for: coreMLModel)
            logger.info("✅ YOLOv3 model loaded successfully.")
        } catch {
            // Fatal error if the model fails to load
            fatalError("🚨 Failed to load YOLOv3 model: \(error.localizedDescription)")
        }
    }
    
    /// Processes a given CVPixelBuffer using the Vision framework for object detection
    func detectObjects(in pixelBuffer: CVPixelBuffer) async -> [ObservationModel] {
        return await withCheckedContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    self.logger.error("🚨 Vision request failed: \(error.localizedDescription)")
                    continuation.resume(returning: []) // ✅ Return empty on failure
                    return
                }

                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    self.logger.warning("⚠️ No objects detected in frame.")
                    continuation.resume(returning: [])
                    return
                }

                let detectedObjects = results.compactMap { result -> ObservationModel? in
                    guard let label = result.labels.first else { return nil }
                    return ObservationModel(label: label.identifier, confidence: label.confidence, boundingBox: result.boundingBox)
                }

                self.logger.info("🔍 Detected \(detectedObjects.count) objects.")
                continuation.resume(returning: detectedObjects) // ✅ Resume with results
            }

            request.revision = VNCoreMLRequest.defaultRevision
            request.imageCropAndScaleOption = .centerCrop

            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

            do {
                try requestHandler.perform([request])
                self.logger.info("✅ Vision request completed successfully.")
            } catch {
                self.logger.error("🚨 Failed to perform Vision request: \(error.localizedDescription)")
                continuation.resume(returning: []) // ✅ Return empty on failure
            }
        }
    }
}
