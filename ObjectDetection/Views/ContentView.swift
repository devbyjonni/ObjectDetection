//
//  ContentView.swift
//  ObjectDetectionApp
//
//  Created by Jonni Akesson on 2025-02-12.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        ZStack {
            CameraPreviewView(previewLayer: viewModel.previewLayer)
                .edgesIgnoringSafeArea(.all)
            
            ForEach(viewModel.detectedObjects) { object in
                BoundingBoxView(object: object)
            }
        }
        .onAppear {
            viewModel.startDetection()
        }
    }
}
