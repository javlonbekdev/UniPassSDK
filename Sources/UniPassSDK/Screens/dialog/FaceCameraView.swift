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
        
        // Video output setup'ni sessionQueue'da qilish
        DispatchQueue.global(qos: .background).async { [videoDataOutput, captureSession, photoDataOutput] in
            
            videoDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            // Delegate'ni background queue bilan ulash
            let cameraQueue = DispatchQueue(label: "camera.processing.queue", qos: .userInitiated)
            videoDataOutput.setSampleBufferDelegate(self, queue: cameraQueue)
            
            if captureSession.canAddOutput(videoDataOutput) {
                captureSession.addOutput(videoDataOutput)
            }
            
            if captureSession.canAddOutput(photoDataOutput) {
                captureSession.addOutput(photoDataOutput)
            }
            
            if let videoConnection = videoDataOutput.connection(with: .video) {
                videoConnection.videoOrientation = .portrait
            }
        }
    }
}


extension FaceCameraView: AVCapturePhotoCaptureDelegate, @preconcurrency AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.handleFaceDetectionResults(request)
            }
        }
        
        let imageHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .leftMirrored)
        
        do {
            try imageHandler.perform([faceDetectionRequest])
        } catch {
            print("Vision error: \(error)")
        }
    }
    
    private func handleFaceDetectionResults(_ request: VNRequest) {
        // UI update'lar main thread'da
        faceLayers.forEach { $0.removeFromSuperlayer() }
        
        if let observations = request.results as? [VNFaceObservation] {
            processObservations(observations)
        }
    }
    
    private func processObservations(_ observations: [VNFaceObservation]) {
        guard let observation = observations.first(where: { $0.boundingBox.width * $0.boundingBox.height > 0.03 }) else { return }
        
        faceRect = observation.boundingBox
        
        // Head status calculation
        if let yaw = observation.yaw?.floatValue, abs(yaw) > 0.15 {
            headStatus = .leftRight
        } else if let roll = observation.roll?.floatValue, roll < 1.4 || roll > 1.75 {
            headStatus = .rotate
        } else if pitchResult(observation) {
            headStatus = .upDown
        } else {
            headStatus = .normal
        }
        
        updateFaceLayer(observation)
    }
    
    private func updateFaceLayer(_ observation: VNFaceObservation) {
        let faceRectConverted = previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
        faceRectLayerConverted = faceRectConverted
        
        let faceLayer = CAShapeLayer()
        faceLayer.path = CGPath(rect: faceRectConverted, transform: nil)
        faceLayer.fillColor = UIColor.clear.cgColor
        faceLayer.strokeColor = UIColor.yellow.cgColor
        
        faceLayers.append(faceLayer)
        layer.addSublayer(faceLayer)
    }
    
    private func pitchResult(_ observation: VNFaceObservation) -> Bool {
        guard let landmarks = observation.landmarks,
              let nose = landmarks.nose,
              let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else { return true }
        
        let noseY = averageY(of: nose.normalizedPoints)
        let eyeY = (averageY(of: leftEye.normalizedPoints) + averageY(of: rightEye.normalizedPoints)) / 2.0
        let deltaY = noseY - eyeY
        
        return !(deltaY > -0.02 && deltaY < 0.02)
    }
    
    private func averageY(of points: [CGPoint]) -> CGFloat {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.y }.reduce(0, +) / CGFloat(points.count)
    }
}
