//
//  File.swift
//  UniPassSDK
//
//  Created by Javlonbek Dev on 25/08/25.
//

import Foundation
import UIKit
import Combine

// MARK: - Request/Response Models
struct VerifyIdentityRequest: Codable {
    let clientId: String
    let clientToken: String
    let faceImage: String
    let pinfl: String
    let profileId: Int
    let requestId: String
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientToken = "client_token"
        case faceImage = "face_image"
        case pinfl
        case profileId = "profile_id"
        case requestId = "request_id"
    }
}

struct VerifyIdentityResponse: Codable {
    let requestId: String
    let clientId: String
    let resultToken: String
    let authenticationCode: Int
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case clientId = "client_id"
        case resultToken = "result_token"
        case authenticationCode = "authentication_code"
        case description
    }
}

struct GenerateTokenResponse: Codable {
    let clientToken: String
    let tokenType: String
    let clientID: String
}

// MARK: - ViewModel States
enum UniPassViewState: Equatable {
    static func == (lhs: UniPassViewState, rhs: UniPassViewState) -> Bool {
        lhs == rhs
    }
    
    case idle
    case loading
    case success(VerifyIdentityResponse)
    case error(String)
}

// MARK: - UniPassViewModel
class UniPassViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var viewState: UniPassViewState = .idle
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://api.uni-pass.uz"
    
    // MARK: - Public Methods
    func login(with faceImage: UIImage, model: GenerateTokenResponse?) {
        guard let tokenModel = model else {
            updateViewState(.error("Token model topilmadi"))
            return
        }
        
        guard let imageData = faceImage.jpegData(compressionQuality: 0.8) else {
            updateViewState(.error("Rasm konvertatsiya qilishda xatolik"))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Bu yerda PINFL va profile_id ni olish kerak
        // Hozircha test uchun static qiymatlar
        let pinfl = "12345678901234" // Bu qiymat real loyihada foydalanuvchidan olinishi kerak
        let profileId = 25 // Bu qiymat ham real loyihada dynamic bo'lishi kerak
        
        verifyIdentity(
            faceImage: base64Image,
            pinfl: pinfl,
            profileId: profileId,
            tokenModel: tokenModel
        )
    }
    
    // MARK: - Private Methods
    private func verifyIdentity(faceImage: String, pinfl: String, profileId: Int, tokenModel: GenerateTokenResponse) {
        updateViewState(.loading)
        
        let requestId = UUID().uuidString
        
        let request = VerifyIdentityRequest(
            clientId: tokenModel.clientID,
            clientToken: tokenModel.clientToken,
            faceImage: faceImage,
            pinfl: pinfl,
            profileId: profileId,
            requestId: requestId
        )
        
        performVerifyRequest(request: request)
    }
    
    private func performVerifyRequest(request: VerifyIdentityRequest) {
        guard let url = URL(string: "\(baseURL)/client/verify/identity/by-pinfl") else {
            updateViewState(.error("Noto'g'ri URL"))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(request.clientToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("ios", forHTTPHeaderField: "X-App-Source")
        urlRequest.setValue("1000", forHTTPHeaderField: "App-Version-Code")
        urlRequest.setValue("1.0.0", forHTTPHeaderField: "App-Version-Name")
        urlRequest.setValue(UIDevice.current.identifierForVendor?.uuidString ?? "unknown", forHTTPHeaderField: "Device-Id")
        urlRequest.setValue(UIDevice.current.name, forHTTPHeaderField: "Device-Name")
        urlRequest.setValue("Apple", forHTTPHeaderField: "Device-Manufacturer")
        urlRequest.setValue(UIDevice.current.model, forHTTPHeaderField: "Device-Model")
        urlRequest.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "iOS-Version")
        urlRequest.setValue("uz", forHTTPHeaderField: "Accept-Language")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            updateViewState(.error("Request kodlashda xatolik: \(error.localizedDescription)"))
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if httpResponse.statusCode == 200 {
                    return data
                } else {
                    // Xatolik javobini parse qilish
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        throw NSError(domain: "UniPassError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    } else {
                        throw URLError(.badServerResponse)
                    }
                }
            }
            .decode(type: VerifyIdentityResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.updateViewState(.error("Xatolik: \(error.localizedDescription)"))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    if response.authenticationCode == 600 {
                        self?.updateViewState(.success(response))
                    } else {
                        self?.updateViewState(.error("Tasdiqlash muvaffaqiyatsiz: \(response.description)"))
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateViewState(_ newState: UniPassViewState) {
        DispatchQueue.main.async {
            self.viewState = newState
            self.isLoading = (newState == .loading)
        }
    }
    
    // MARK: - Helper Methods
    func resetState() {
        updateViewState(.idle)
    }
}
