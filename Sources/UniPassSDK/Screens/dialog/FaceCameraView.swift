//
//  FaceCameraView.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit
import Vision
@preconcurrency import AVFoundation

@MainActor
class FaceCameraView: BaseView {
    
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
//    var label = UILabel()
    
    var faceRect = CGRect()
    var faceRectLayerConverted = CGRect()
    
    override func setView() {
        snp.makeConstraints { $0.width.height.equalTo((isPhone ? 4 : 3) * screenSize.width / 5) }
        setupCamera()
        previewLayer.frame = .init(x: 0, y: 0, width: cameraWidth, height: cameraWidth)
    }
    
    open func startTimer() {
        Task.detached {
            await self.captureSession.startRunning()
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
        
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera queue"))
        captureSession.addOutput(videoDataOutput)
        captureSession.addOutput(photoDataOutput)
        
        let videoConnection = videoDataOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
}


extension FaceCameraView: AVCapturePhotoCaptureDelegate, @preconcurrency AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let borderHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .leftMirrored)
        
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                self.faceLayers.forEach({ drawing in drawing.removeFromSuperlayer() })
                
                let copyRect = self.faceRectLayerConverted
                if let observations = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionObservations(observations: observations, buffer: sampleBuffer)
                }
                if copyRect == self.faceRectLayerConverted {
                    self.cropImage = nil
                }
            }
        })
        
        let imageHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .up, options: [:])
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            if let results = request.results as? [VNFaceObservation], let face = results.first {
                guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    return
                }
                let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                
                // Convert CIImage to UIImage for further processing
                let context = CIContext()
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    let image = UIImage(cgImage: cgImage)
                    self.photo = image
                    self.extractFace(from: image, observation: face)
                }
            }
        }
        
        do {
            try borderHandler.perform([faceDetectionRequest])
            try imageHandler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func handleFaceDetectionObservations(observations: [VNFaceObservation], buffer: CMSampleBuffer) {
        // Oldin yuz qatlamlarini tozalaymiz
        faceLayers.forEach({ $0.removeFromSuperlayer() })
        
        if let observation = observations.filter({ $0.boundingBox.width * $0.boundingBox.height > 0.03 }).first {
            print(observation.boundingBox.width * observation.boundingBox.height)
            faceRect = observation.boundingBox

            // Yuqori / Pastga / Chap / O‘ng burilishlarni tekshirish
            if let yaw = observation.yaw?.floatValue, yaw < -0.15 || yaw > 0.15 { // expanded to 0.05
                headStatus = .leftRight
            } else if let roll = observation.roll?.floatValue, roll < 1.4 || roll > 1.75 { // expanded to 0.1
                headStatus = .rotate
            } else if pitchResult(observation) {
                headStatus = .upDown
            } else {
                headStatus = .normal
            }

            // Yuzni ekrandagi joylashuvini hisoblash
            let faceRectConverted = previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
                

            // Yangi `CAShapeLayer` yaratish
            let faceRectPath = CGPath(rect: faceRectConverted, transform: nil)
            let faceLayer = CAShapeLayer()
            faceLayer.path = faceRectPath
            faceLayer.fillColor = UIColor.clear.cgColor
            faceLayer.strokeColor = UIColor.yellow.cgColor

            // Qo'shish
            DispatchQueue.main.async {
                self.faceLayers.append(faceLayer)
                self.layer.addSublayer(faceLayer)  // Yuz qatlami
                  // Matn (UILabel)
            }
            
            faceRectLayerConverted = faceRectConverted
        }
    }
    
    func extractFace(from image: UIImage, observation: VNFaceObservation) {
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
            
            DispatchQueue.main.async { self.cropImage = faceImage  }
        }
    }
    
    func pitchResult(_ observation: VNFaceObservation) -> Bool {
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
    
    func averageY(of points: [CGPoint]) -> CGFloat {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.y }.reduce(0, +) / CGFloat(points.count)
    }
}

