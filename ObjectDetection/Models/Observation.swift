//
//  Observation.swift
//  ObjectDetectionApp
//
//  Created by Jonni Akesson on 2025-02-12.
//

import Foundation
import Vision

struct Observation: Identifiable {
    let id = UUID()
    let label: String
    let confidence: VNConfidence
    let boundingBox: CGRect
}
