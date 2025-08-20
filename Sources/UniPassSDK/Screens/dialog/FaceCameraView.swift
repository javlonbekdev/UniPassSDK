//
//  FaceCameraView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit
import Vision
import SnapKit
@preconcurrency import AVFoundation

class FaceCameraView: UIView {
    var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    
    let cameraWidth = UIScreen.main.bounds.width * (UIDevice.current.userInterfaceIdiom == .phone ? 4 : 3) / 5
    
    
    var timer: Timer?
    var photo: UIImage?
    var cropImage: UIImage?
    
    var attendance: (() -> ())?
    var update: ((Double, HeadStatus) -> ())?
    
    var headStatus: HeadStatus = .normal
    
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue",
                                               qos: .userInitiated)
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let photoDataOutput = AVCapturePhotoOutput()
    private var faceLayers: [CAShapeLayer] = []
    
    var faceRect = CGRect()
    var faceRectLayerConverted = CGRect()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        snp.makeConstraints { $0.width.height.equalTo((isPhone ? 4 : 3) * screenSize.width / 5) }
        setupCamera()
        previewLayer.frame = .init(x: 0, y: 0, width: cameraWidth, height: cameraWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startTimer() {
//        Task.detached {
//            await self.captureSession.startRunning()
//        }
//        self.setupTimer()
        
        Task { [weak self] in
            guard let self = self else { return }
            
            let session = await MainActor.run { self.captureSession }
            
            await withCheckedContinuation { continuation in
                sessionQueue.async {
                    session.startRunning()
                    continuation.resume()
                }
            }
            setupTimer()
        }
    }
    
    open func stopTimer() {
        DispatchQueue.global(qos: .background).async { [captureSession] in
            captureSession.stopRunning()
            DispatchQueue.main.async { [weak self] in
                self?.timer?.invalidate()
                self?.timer = nil
            }
        }
    }
    
    func setupTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in // change from 0.2 to 0.4
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.captureSession.isRunning ? self.attendance?() : ()
                self.update?(self.faceRect.width * self.faceRect.height, self.headStatus)
            }
        }
    }
    
    private func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                    setupPreview()
                }
            }
        }
    }
    
    private func setupPreview() {
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        
//        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
//        
//        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera queue"))
//        captureSession.addOutput(videoDataOutput)
//        captureSession.addOutput(photoDataOutput)
        
        if captureSession.canAddOutput(photoDataOutput) {
                captureSession.addOutput(photoDataOutput)
            }
        
        let videoConnection = videoDataOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
}


extension FaceCameraView: AVCapturePhotoCaptureDelegate, @preconcurrency AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        
//        // Vision processing'ni background'da qilish
//        let borderHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .leftMirrored)
//        
//        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
//            guard let self = self else { return }
//            
//            // Main thread'ga o'tish UI update uchun
//            DispatchQueue.main.async {
//                self.processFaceDetectionResults(request: request, buffer: sampleBuffer)
//            }
//        }
        
//        let imageHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .up, options: [:])
//        let faceRectRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
//            guard let self = self else { return }
//            
//            if let results = request.results as? [VNFaceObservation], let face = results.first {
//                // Background'da image processing
//                self.processImageExtraction(imageBuffer: imageBuffer, observation: face)
//            }
//        }
//        
//        // Vision request'larni background'da bajarish
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try borderHandler.perform([faceDetectionRequest])
//                try imageHandler.perform([faceRectRequest])
//            } catch {
//                print("Vision error: \(error.localizedDescription)")
//            }
//        }
    }
    
    // Main thread'da UI update qilish uchun alohida metod
//    @MainActor
    private func processFaceDetectionResults(request: VNRequest, buffer: CMSampleBuffer) {
        // UI elementlarni tozalash
        faceLayers.forEach { $0.removeFromSuperlayer() }
        
        let copyRect = faceRectLayerConverted
        
        if let observations = request.results as? [VNFaceObservation] {
            handleFaceDetectionObservations(observations: observations, buffer: buffer)
        }
        
        if copyRect == faceRectLayerConverted {
            cropImage = nil
        }
    }
    
    // Background'da image processing
    private func processImageExtraction(imageBuffer: CVPixelBuffer, observation: VNFaceObservation) {
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let image = UIImage(cgImage: cgImage)
            
            // Main thread property'ni background'dan set qilish
            DispatchQueue.main.async { [weak self] in
                self?.photo = image
            }
            
            extractFace(from: image, observation: observation)
        }
    }
    
    // Face detection observations'ni handle qilish
    private func handleFaceDetectionObservations(observations: [VNFaceObservation], buffer: CMSampleBuffer) {
        if let observation = observations.filter({ $0.boundingBox.width * $0.boundingBox.height > 0.03 }).first {
            
            // Background thread'da calculations
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let faceRect = observation.boundingBox
                
                // Head status calculation
                var headStatus: HeadStatus = .normal
                
                if let yaw = observation.yaw?.floatValue, yaw < -0.15 || yaw > 0.15 {
                    headStatus = .leftRight
                } else if let roll = observation.roll?.floatValue, roll < 1.4 || roll > 1.75 {
                    headStatus = .rotate
                } else if self.pitchResult(observation) {
                    headStatus = .upDown
                }
                
                // Main thread'ga qaytish UI update uchun
                DispatchQueue.main.async {
                    self.faceRect = faceRect
                    self.headStatus = headStatus
                    
                    // Face layer qo'shish
                    let faceRectConverted = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
                    self.faceRectLayerConverted = faceRectConverted
                    
                    let faceRectPath = CGPath(rect: faceRectConverted, transform: nil)
                    let faceLayer = CAShapeLayer()
                    faceLayer.path = faceRectPath
                    faceLayer.fillColor = UIColor.clear.cgColor
                    faceLayer.strokeColor = UIColor.yellow.cgColor
                    
                    self.faceLayers.append(faceLayer)
                    self.layer.addSublayer(faceLayer)
                }
            }
        }
    }
    
    private func extractFace(from image: UIImage, observation: VNFaceObservation) {
        guard let cgImage = image.cgImage else { return }
        
        let boundingBox = observation.boundingBox
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let rect = CGRect(
            x: boundingBox.origin.x * width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * height,
            width: boundingBox.width * width,
            height: boundingBox.height * height
        )
        
        if let croppedCGImage = cgImage.cropping(to: rect) {
            let faceImage = UIImage(cgImage: croppedCGImage)
            
            DispatchQueue.main.async { [weak self] in
                self?.cropImage = faceImage
            }
        }
    }
    
    nonisolated private func pitchResult(_ observation: VNFaceObservation) -> Bool {
        if let landmarks = observation.landmarks,
           let nose = landmarks.nose,
           let leftEye = landmarks.leftEye,
           let rightEye = landmarks.rightEye {
            
            let noseY = averageY(of: nose.normalizedPoints)
            let eyeY = (averageY(of: leftEye.normalizedPoints) + averageY(of: rightEye.normalizedPoints)) / 2.0
            
            let deltaY = noseY - eyeY
            
            if deltaY > -0.02 && deltaY < 0.02 { // expanded to 0.01
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    nonisolated private func averageY(of points: [CGPoint]) -> CGFloat {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.y }.reduce(0, +) / CGFloat(points.count)
    }
}
