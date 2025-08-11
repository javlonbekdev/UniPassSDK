////
////  LoginService.swift
////  UniPassSDK
////
////  Created by Javlonbek Dev on 08/08/25.
////
//
//
////
////  LoginService.swift
////  Unipass
////
////  Created by Javlonbek Dev on 16/07/25.
////
//
//import Foundation
//import UIKit
//import Combine
//
//@MainActor
//class LoginService {
//    static let shared = LoginService()
//    private let baseURL = "https://api.uni-pass.uz/user/"
//    private let session = URLSession.shared
//    private let logger = NetworkLogger.shared
//    
//    private init() {}
//    
//    func login(withPinfl: Bool, birthDate: String, field: String, faceImage: UIImage) -> AnyPublisher<LoginResponse, NetworkError> {
//        guard let url = URL(string: "\(baseURL)login\(withPinfl ? "" : "/by_passport")") else {
//            return Fail(error: NetworkError.invalidURL)
//                .eraseToAnyPublisher()
//        }
//        
//        // Convert image to base64
//        guard let imageData = faceImage.cropTo3x4Ratio()?.jpegData(compressionQuality: 0.8) else {
//            return Fail(error: NetworkError.networkError(NSError(domain: "ImageConversion", code: 0, userInfo: nil)))
//                .eraseToAnyPublisher()
//        }
//        
//        let base64Image = imageData.base64EncodedString()
//        
//        let loginPinflRequest = LoginPinflRequest(
//            pinfl: field,
//            faceImage: base64Image
//        )
//        
//        let loginPassportRequest = LoginPassportRequest(
//            passport: field,
//            birthDate: birthDate,
//            faceImage: base64Image
//        )
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // Add device info headers
//        let deviceInfo = DeviceInfoHelper.getDeviceInfo()
//        for (key, value) in deviceInfo {
//            request.setValue(value, forHTTPHeaderField: key)
//        }
//        
//        do {
//            if withPinfl {
//                request.httpBody = try JSONEncoder().encode(loginPinflRequest)
//            } else {
//                request.httpBody = try JSONEncoder().encode(loginPassportRequest)
//            }
//        } catch {
//            return Fail(error: NetworkError.networkError(error))
//                .eraseToAnyPublisher()
//        }
//        
//        // Log request
//        logger.logRequest(request)
//        
//        let startTime = Date()
//        
//        return session.dataTaskPublisher(for: request)
//            .tryMap { [weak self] data, response in
//                let duration = Date().timeIntervalSince(startTime)
//                self?.logger.logResponse(response, data: data, error: nil, duration: duration)
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    throw NetworkError.networkError(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))
//                }
//                
//                if httpResponse.statusCode != 200 {
//                    throw NetworkError.serverError(httpResponse.statusCode)
//                }
//                
//                return data
//            }
//            .decode(type: LoginResponse.self, decoder: JSONDecoder())
//            .mapError { error in
//                if let decodingError = error as? DecodingError {
//                    return NetworkError.decodingError(decodingError)
//                } else if let networkError = error as? NetworkError {
//                    return networkError
//                } else {
//                    return NetworkError.networkError(error)
//                }
//            }
//            .eraseToAnyPublisher()
//    }
//}
