//
//  BoundingBoxView.swift
//  YOLOv3Demo
//
//  Created by Jonni Akesson on 2025-02-12.
//


import SwiftUI

struct BoundingBoxView: View {
    let object: ObservationModel
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            let adjustedBox = CGRect(
                x: object.boundingBox.origin.x * width,
                y: (1 - object.boundingBox.origin.y - object.boundingBox.height) * height,
                width: object.boundingBox.width * width,
                height: object.boundingBox.height * height
            )
            
            Rectangle()
                .stroke(Color.green, lineWidth: 2)
                .frame(width: adjustedBox.width, height: adjustedBox.height)
                .position(x: adjustedBox.midX, y: adjustedBox.midY)
                .overlay(
                    Text("\(object.label) (\(Int(object.confidence * 100))%)")
                        .padding(4)
                        .background(Color.green.opacity(0.5))
                        .foregroundColor(.white)
                        .font(.caption)
                )
        }
    }
}

