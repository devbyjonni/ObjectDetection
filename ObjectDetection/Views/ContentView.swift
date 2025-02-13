//
//  ContentView.swift
//  ObjectDetectionApp
//
//  Created by Jonni Akesson on 2025-02-12.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var detectedObjects: [Observation] = []
    
    var body: some View {
        ZStack {
            CameraPreviewView(previewLayer: cameraManager.previewLayer)
                .edgesIgnoringSafeArea(.all)
            
            ForEach(detectedObjects) { object in
                BoundingBoxView(object: object)
            }
        }
        .onAppear {
            cameraManager.setupCamera()
        }
        .onReceive(NotificationCenter.default.publisher(for: .detectedObjectsUpdated)) { notification in
            if let detected = notification.object as? [Observation] {
                detectedObjects = detected
            }
        }
    }
}

