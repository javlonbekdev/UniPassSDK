//
//  UIImage.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import Foundation
import UIKit
import AVFoundation

// MARK: - UIImage Crop Extension
extension UIImage {
    
    // MARK: - Crop to 3:4 Aspect Ratio
    func cropTo3x4Ratio() -> UIImage? {
        return cropToAspectRatio(width: 3, height: 4)
    }
    
    func cropTo4x3Ratio() -> UIImage? {
        return cropToAspectRatio(width: 4, height: 3)
    }
    
    // MARK: - Generic Aspect Ratio Crop
    func cropToAspectRatio(width: CGFloat, height: CGFloat) -> UIImage? {
        let targetRatio = width / height
        let currentRatio = size.width / size.height
        
        var cropRect: CGRect
        
        if currentRatio > targetRatio {
            // Image is wider than target ratio - crop width
            let newWidth = size.height * targetRatio
            cropRect = CGRect(
                x: (size.width - newWidth) / 2,
                y: 0,
                width: newWidth,
                height: size.height
            )
        } else {
            // Image is taller than target ratio - crop height
            let newHeight = size.width / targetRatio
            cropRect = CGRect(
                x: 0,
                y: (size.height - newHeight) / 2,
                width: size.width,
                height: newHeight
            )
        }
        
        return cropToRect(cropRect)
    }
    
    // MARK: - Crop to Rectangle
    func cropToRect(_ rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        
        // Scale rect to image's actual size
        let scale = cgImage.width / Int(size.width)
        let scaledRect = CGRect(
            x: rect.origin.x * CGFloat(scale),
            y: rect.origin.y * CGFloat(scale),
            width: rect.size.width * CGFloat(scale),
            height: rect.size.height * CGFloat(scale)
        )
        
        guard let croppedCGImage = cgImage.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: imageOrientation)
    }
    
    // MARK: - Smart Crop with Position
    enum CropPosition {
        case center
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    func cropTo3x4Ratio(position: CropPosition = .center) -> UIImage? {
        let targetRatio: CGFloat = 3.0 / 4.0
        let currentRatio = size.width / size.height
        
        var cropRect: CGRect
        
        if currentRatio > targetRatio {
            // Image is wider - crop width
            let newWidth = size.height * targetRatio
            let xOffset: CGFloat
            
            switch position {
            case .left, .topLeft, .bottomLeft:
                xOffset = 0
            case .right, .topRight, .bottomRight:
                xOffset = size.width - newWidth
            default:
                xOffset = (size.width - newWidth) / 2
            }
            
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: size.height)
        } else {
            // Image is taller - crop height
            let newHeight = size.width / targetRatio
            let yOffset: CGFloat
            
            switch position {
            case .top, .topLeft, .topRight:
                yOffset = 0
            case .bottom, .bottomLeft, .bottomRight:
                yOffset = size.height - newHeight
            default:
                yOffset = (size.height - newHeight) / 2
            }
            
            cropRect = CGRect(x: 0, y: yOffset, width: size.width, height: newHeight)
        }
        
        return cropToRect(cropRect)
    }
    
    // MARK: - Face-Centered Crop
    func cropTo3x4RatioWithFaceDetection() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return cropTo3x4Ratio() }
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [
            CIDetectorAccuracy: CIDetectorAccuracyHigh
        ])
        
        let faces = detector?.features(in: ciImage) as? [CIFaceFeature] ?? []
        
        if let face = faces.first {
            // Calculate crop rect centered on face
            let faceCenter = CGPoint(x: face.bounds.midX, y: face.bounds.midY)
            return cropTo3x4RatioCenteredAt(point: faceCenter)
        } else {
            // No face found, use center crop
            return cropTo3x4Ratio()
        }
    }
    
    // MARK: - Crop Centered at Point
    func cropTo3x4RatioCenteredAt(point: CGPoint) -> UIImage? {
        let targetRatio: CGFloat = 3.0 / 4.0
        let currentRatio = size.width / size.height
        
        var cropRect: CGRect
        
        if currentRatio > targetRatio {
            // Image is wider - crop width
            let newWidth = size.height * targetRatio
            let xOffset = max(0, min(point.x - newWidth / 2, size.width - newWidth))
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: size.height)
        } else {
            // Image is taller - crop height
            let newHeight = size.width / targetRatio
            let yOffset = max(0, min(point.y - newHeight / 2, size.height - newHeight))
            cropRect = CGRect(x: 0, y: yOffset, width: size.width, height: newHeight)
        }
        
        return cropToRect(cropRect)
    }
    
    // MARK: - Crop and Resize
//    func cropTo3x4RatioAndResize(to targetSize: CGSize) -> UIImage? {
//        guard let croppedImage = cropTo3x4Ratio() else { return nil }
//        return croppedImage.resize(to: targetSize)
//    }
    
    // MARK: - Multiple Crop Options
    func getCropOptions() -> [UIImage] {
        var options: [UIImage] = []
        
        // Center crop
        if let centerCrop = cropTo3x4Ratio(position: .center) {
            options.append(centerCrop)
        }
        
        // Top crop
        if let topCrop = cropTo3x4Ratio(position: .top) {
            options.append(topCrop)
        }
        
        // Bottom crop
        if let bottomCrop = cropTo3x4Ratio(position: .bottom) {
            options.append(bottomCrop)
        }
        
        // Face-centered crop
        if let faceCrop = cropTo3x4RatioWithFaceDetection() {
            options.append(faceCrop)
        }
        
        return options
    }
    
    // MARK: - Crop with Preview
    func getCropPreview() -> (croppedImage: UIImage?, cropRect: CGRect) {
        let targetRatio: CGFloat = 3.0 / 4.0
        let currentRatio = size.width / size.height
        
        let cropRect: CGRect
        
        if currentRatio > targetRatio {
            let newWidth = size.height * targetRatio
            cropRect = CGRect(
                x: (size.width - newWidth) / 2,
                y: 0,
                width: newWidth,
                height: size.height
            )
        } else {
            let newHeight = size.width / targetRatio
            cropRect = CGRect(
                x: 0,
                y: (size.height - newHeight) / 2,
                width: size.width,
                height: newHeight
            )
        }
        
        return (cropToRect(cropRect), cropRect)
    }
}

// MARK: - Image Crop Utility
class ImageCropUtility {
    
    static func cropImageTo3x4(image: UIImage, method: CropMethod = .center) -> UIImage? {
        switch method {
        case .center:
            return image.cropTo3x4Ratio(position: .center)
        case .faceDetection:
            return image.cropTo3x4RatioWithFaceDetection()
        case .top:
            return image.cropTo3x4Ratio(position: .top)
        case .bottom:
            return image.cropTo3x4Ratio(position: .bottom)
        case .custom(let point):
            return image.cropTo3x4RatioCenteredAt(point: point)
        }
    }
    
    enum CropMethod {
        case center
        case faceDetection
        case top
        case bottom
        case custom(CGPoint)
    }
}

// MARK: - Usage Examples
class CropExamples {
    
    func example1_BasicCrop() {
        let originalImage = UIImage(named: "photo.jpg")!
        
        // Simple 3:4 crop
        let croppedImage = originalImage.cropTo3x4Ratio()
        print("Original size: \(originalImage.size)")
        print("Cropped size: \(croppedImage?.size ?? .zero)")
        
        // Calculate aspect ratio
        if let cropped = croppedImage {
            let ratio = cropped.size.width / cropped.size.height
            print("Aspect ratio: \(ratio)") // Should be 0.75 (3:4)
        }
    }
}

// MARK: - Camera Integration Example
extension UIImagePickerController {
    
    func cropCapturedImageTo3x4() -> UIImage? {
        // This would be called after image capture
        // Assuming you have the captured image
        let capturedImage = UIImage() // Your captured image
        
        // Crop with face detection for best results
        return capturedImage.cropTo3x4RatioWithFaceDetection()
    }
}
