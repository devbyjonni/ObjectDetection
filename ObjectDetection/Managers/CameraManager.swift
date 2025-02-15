//
//  CameraManager.swift
//  ObjectDetectionApp
//
//  Created by Jonni Akesson on 2025-02-12.
//

import AVFoundation
import os
import Observation

/// Manages the camera session, captures video frames, and streams them asynchronously.
@Observable
final class CameraManager: NSObject {
    
    /// Logger for debugging camera operations.
    private let logger = Logger(subsystem: "com.yourapp.ObjectDetectionApp", category: "CameraManager")
    
    /// AVCaptureSession for handling camera input and output.
    private let session = AVCaptureSession()
    
    /// Video output for capturing frames.
    private let videoOutput = AVCaptureVideoDataOutput()
    
    /// Dispatch queue for handling video capture in the background.
    private let queue = DispatchQueue(label: "camera-queue", qos: .userInitiated)
    
    /// Preview layer for displaying the camera feed.
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    /// AsyncStream for asynchronously delivering pixel buffers
    private var frameStreamContinuation: AsyncStream<CVPixelBuffer>.Continuation?
    
    /// Provides a stream of camera frames for processing
    var frameStream: AsyncStream<CVPixelBuffer> {
        AsyncStream { continuation in
            self.frameStreamContinuation = continuation
        }
    }
    
    /// Sets up and configures the camera session.
    func setupCamera() async {
        do {
            try configureSession()
            startSession()
        } catch {
            logger.error("🚨 Camera setup failed: \(error.localizedDescription)")
        }
    }
    
    /// Configures the camera session with input and output.
    private func configureSession() throws {
        session.beginConfiguration()
        
        // Set camera resolution to match the Core ML model's input size
        session.sessionPreset = .vga640x480
        
        // Select the back camera
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        ).devices.first else {
            throw NSError(domain: "CameraManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No suitable camera found."])
        }
        
        // Create an input object for the camera
        let input = try AVCaptureDeviceInput(device: device)
        
        // Add input to session if possible
        guard session.canAddInput(input) else {
            throw NSError(domain: "CameraManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add camera input."])
        }
        session.addInput(input)
        
        // Add video output to session if possible
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            
            // Ensure the captured frames have the correct pixel format
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
        } else {
            throw NSError(domain: "CameraManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add video output."])
        }
        
        // Lock device settings and get resolution
        try device.lockForConfiguration()
        let dimensions = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        device.unlockForConfiguration()
        
        logger.info("📷 Camera configured. Resolution: \(dimensions.width)x\(dimensions.height)")
        
        session.commitConfiguration()
        
        // Create a preview layer to display the camera feed
        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        newPreviewLayer.videoGravity = .resizeAspectFill
        previewLayer = newPreviewLayer
    }
    
    /// Starts the camera session.
    private func startSession() {
        session.startRunning()
        logger.info("📷 Camera session started.")
    }
}

// MARK: - Camera Frame Capture (Using AsyncStream)
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// Processes each captured video frame and sends it into the async stream.
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        // Extract pixel buffer from the sample buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            logger.error("🚨 Failed to get pixel buffer from sample buffer.")
            return
        }
        
        // Yield the frame into the AsyncStream
        frameStreamContinuation?.yield(pixelBuffer)
    }
}
