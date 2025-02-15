# Object Detection App  

A lightweight **iOS app** for real-time **object detection** using **YOLOv3**, **Apple’s Vision framework**, and **SwiftUI**.

---

## Features  

- **Live Object Detection** – Detects objects in real time using the device camera.  
- **CoreML & Vision Framework** – Uses Apple’s machine learning and computer vision tools for on-device inference.  
- **Optimized Performance** – Designed for low-latency, efficient object detection on iOS devices.  
- **Bounding Box Overlays** – Displays detected objects with bounding boxes and confidence scores.  
- **Modern Swift Architecture** – Uses **SwiftUI, Async/await, and AsyncStream** for a responsive and clean code structure.  

---

## Tech Stack  

| **Technology**   | **Purpose**  |
|------------------|-------------|
| **SwiftUI**      | Declarative UI for rendering bounding boxes. |
| **CoreML**       | Runs the **YOLOv3** object detection model. |
| **Vision**       | Handles frame preprocessing and object detection requests. |
| **AVFoundation** | Captures and streams real-time video from the device camera. |
| **Observation**  | Enables efficient state management and real-time UI updates. |
| **AsyncStream**  | Provides a modern way to process camera frames asynchronously. |

---

## How It Works  

### 1️⃣ Captures Camera Feed  
- Uses **AVCaptureSession** to stream real-time video from the device camera.  
- Provides an **AsyncStream** of pixel buffers for processing.  

### 2️⃣ Processes Frames with Vision & CoreML  
- Resizes frames to **416×416 pixels** to match the YOLOv3 input size.  
- Runs **YOLOv3 via VNCoreMLRequest** to detect objects in each frame.  
- Uses **async/await** to process frames without blocking the main thread.  

### 3️⃣ Updates UI with Bounding Boxes  
- Updates **SwiftUI views** with detected objects, including their labels, confidence scores, and bounding boxes.  

---

## Requirements  

- **Xcode 15+**  
- **iOS 17+**  
- **Swift 5.9+**  
- **A real iOS device** (Camera access required; not supported on the Simulator).  

---

## Model Information  

- **Model:** YOLOv3 (You Only Look Once)  
- **Architecture:** Deep Convolutional Neural Network (CNN)  
- **Input Size:** **416×416 pixels**  

---

## Example Classes YOLOv3 Can Detect  

The **YOLOv3 model** is trained on **80 different object classes** from the **COCO dataset**. Here are **10 common examples**:

| #  | Object        |
|----|--------------|
| 1  | Person       |
| 2  | Bicycle      |
| 3  | Car          |
| 4  | Motorcycle   |
| 5  | Airplane     |
| 6  | Bus          |
| 7  | Train        |
| 8  | Truck        |
| 9  | Boat         |
| 10 | Traffic Light |

For a full list of YOLOv3’s object classes, refer to the **[Ultralytics YOLOv3 Documentation](https://docs.ultralytics.com/models/yolov3/)**.

---
