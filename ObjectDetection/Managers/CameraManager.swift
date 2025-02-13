//
//  CameraManager.swift
//  ObjectDetectionApp
//
//  Created by Jonni Akesson on 2025-02-12.
//

import AVFoundation
import os

private let logger = Logger(subsystem: "com.yourapp.ObjectDetectionApp", category: "CameraManager")

final class CameraManager: NSObject, ObservableObject {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "camera-queue", qos: .userInitiated)
    private let objectDetector = ObjectDetector()
    private var isSessionConfigured = false
    
    func setupCamera() {
        guard !isSessionConfigured else {
            logger.info("⚠️ Camera setup skipped, already configured.")
            return
        }
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            logger.error("🚨 Camera access failed.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                logger.error("🚨 Failed to add camera input.")
                return
            }
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: queue)
            } else {
                logger.error("🚨 Failed to add video output.")
                return
            }
            
            let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            newPreviewLayer.videoGravity = .resizeAspectFill
            previewLayer = newPreviewLayer
            
            startSession()
            
            isSessionConfigured = true
        } catch {
            logger.error("🚨 Camera setup error: \(error.localizedDescription)")
        }
    }
    
    private func startSession() {
        Task(priority: .userInitiated) {
            if !session.isRunning {
                session.startRunning()
                logger.info("📷 Camera session started.")
            }
        }
    }
}

// MARK: - Camera Frame Capture
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            logger.error("🚨 Failed to get pixel buffer from sample buffer.")
            return
        }
        objectDetector.detectObjects(in: pixelBuffer)
    }
}
