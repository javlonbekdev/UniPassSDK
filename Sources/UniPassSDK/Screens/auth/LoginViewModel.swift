////
////  LoginViewModel.swift
////  Unipass
////
////  Created by Javlonbek Dev on 16/07/25.
////
//
//import UIKit
//import Combine
//
//class LoginViewModel: BaseViewModel {
//    
//    // MARK: - Published Properties
//    @Published var activity: ActivityStatus = .idle
//    @Published var isLoginSuccessful = false
//    @Published var field = ""
//    @Published var birthField = ""
//    @Published var birthDate = Date()
//    @Published var passportText = ""
//    @Published var pinflText = ""
//    @Published var selectedSegment = 0
//    
//    // MARK: - Input Validation
//    @Published var isValid = false
//    
//    // MARK: - Private Properties
//    @MainActor
//    private let loginUseCase = LoginUseCase()
//    private var cancellables = Set<AnyCancellable>()
//    
//    // MARK: - Initialization
//    override init() {
//        super.init()
//        setupValidation()
//    }
//    
//    // MARK: - Setup Methods
//    private func setupValidation() {
//        //is valid
//        Publishers.CombineLatest3(
//            $pinflText,
//            $passportText,
//            $selectedSegment
//        )
//        .map { [weak self] pinfl, passport, index in
//            guard let self = self else { return false }
//            if index == 0 {
//                return self.validatePassportFormat(passport)
//            } else {
//                return self.validatePinflFormat(pinfl)
//            }
//        }
//        .assign(to: &$isValid)
//        
//        $selectedSegment
//            .sink { [weak self] index in
//                guard let self = self else { return }
//                self.field = index == 0 ? self.passportText : self.pinflText
//            }
//            .store(in: &cancellables)
//        
//        $field
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] text in
//                guard let self = self else { return }
//                if self.selectedSegment == 0 {
//                    let oldText = self.passportText
//                    self.passportText = text
//                    if (oldText.count == 1 && text.count == 2) || (oldText.count == 2 && text.count == 1) {
//                        self.selectedSegment = 0
//                    }
//                } else {
//                    self.pinflText = text
//                }
//            }
//            .store(in: &cancellables)
//        
//        $passportText
//            .sink { [weak self] text in
//                guard let self = self else { return }
//                if (text.first ?? "a").isLetter != true {
//                    self.field = ""
//                } else if text.count > 1, !text[text.index(after: text.startIndex)].isLetter {
//                    self.field = ""
//                }
//                if text.count > 9 {
//                    self.field = "\(text.prefix(9))"
//                }
//            }
//            .store(in: &cancellables)
//        
//        $pinflText
//            .sink { [weak self] text in
//                guard let self = self else { return }
//                if text.count > 14 {
//                    self.field = "\(text.prefix(14))"
//                }
//            }
//            .store(in: &cancellables)
//        
//        $birthField
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] text in
//                guard let self = self else { return }
//                switch text.count {
//                case 2: if text > "31" || text < "01" { self.birthField = "" }
//                case 3: self.birthField = "\(text.dropLast())" + (text.last == "." ? "" : ".\(text.last!)")
//                case 5: if text.suffix(2) > "12" || text.suffix(2) < "01" { self.birthField = "\(text.prefix(3))" }
//                case 6: self.birthField = "\(text.dropLast())" + (text.last == "." ? "" : ".\(text.last!)")
//                case 10: if text.suffix(4) > "2030" || text.suffix(4) < "0001" { self.birthField = "\(text.prefix(6))" }
//                    else {
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = "dd.MM.yyyy"
//                        let apiDate = formatter.date(from: birthField)
//                        if apiDate != birthDate {
//                            birthDate = apiDate ?? Date()
//                        }
//                    }
//                case 11: self.birthField = "\(text.dropLast())"
//                default: break
//                }
//            }
//            .store(in: &cancellables)
//        
//        $birthDate
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] date in
//                guard let self = self else { return }
//                let formatter = DateFormatter()
//                formatter.dateFormat = "dd.MM.yyyy"
//                let apiDate = formatter.string(from: birthDate)
//                if apiDate != birthField {
//                    self.birthField = apiDate
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    @MainActor func login(with faceImage: UIImage) {
//        activity = .loading()
//        
//        loginUseCase.executeLogin(withPinfl: selectedSegment == 1, field: field, birthDate: birthDate.apiDateStr, faceImage: faceImage)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    guard let self else { return }
//                    switch completion {
//                    case .finished: break
//                    case .failure(let error): self.activity = .error(error)
//                    }
//                },
//                receiveValue: { [weak self] response in
//                    self?.handleLoginResponse(response)
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    // MARK: - Private Methods
//    private func handleLoginResponse(_ response: LoginResponse) {
//        print("\n\n\n\nLogin Response: \(response.authenticationCode)\n\n\n\(response)\n\n\n\n")
//        switch response.authenticationCode {
//        case 200: handleSuccessfulLogin(response)
//        case 600: handleSuccessfulLogin(response)
//        case 601:
////            print("Authentication failed: \(response.description)")
//            handleAuthenticationFailure(response)
//        default: activity = .error(NetworkError.authenticationFailed(response.description.isEmpty
//                                                               ? "Noma'lum xatolik yuz berdi"
//                                                               : response.description))
//        }
//    }
//    
//    private func handleSuccessfulLogin(_ response: LoginResponse) {
//        if let token = response.authenticationToken {
//            // Save tokens
//            TokenManager.shared.saveAuthToken(token)
//            if let refreshToken = response.refreshToken {
//                TokenManager.shared.saveRefreshToken(refreshToken)
//            }
//            isLoginSuccessful = true
//        } else {
//            activity = .error(LoginError.tokenNotReceived)
//        }
//    }
//    
//    private func handleAuthenticationFailure(_ response: LoginResponse) {
//        let faceInfo = response.face
//        
//        if faceInfo.isSpoofed {
//            activity = .warn(message: "Yuz tasdiqlanmadi. Haqiqiy yuzingizni ko'rsating")
//        } else if !faceInfo.isFaceMatched {
//            activity = .warn(message: "Yuz mos kelmadi. Qaytadan urinib ko'ring")
//        } else {
//            activity = .error(NetworkError.authenticationFailed(response.description.isEmpty
//                                                                ? "Autentifikatsiya amalga oshmadi"
//                                                                : response.description))
//        }
//    }
//    
//    // MARK: - Validation Methods
//    private func validatePassportFormat(_ text: String) -> Bool {
//        // AA1234567 format
//        let passportRegex = "^[A-Z]{2}[0-9]{7}$"
//        let passportPredicate = NSPredicate(format: "SELF MATCHES %@", passportRegex)
//        return passportPredicate.evaluate(with: text.uppercased())
//    }
//    
//    private func validatePinflFormat(_ text: String) -> Bool {
//        // 14 digits
//        let jshshirRegex = "^[0-9]{14}$"
//        let jshshirPredicate = NSPredicate(format: "SELF MATCHES %@", jshshirRegex)
//        return jshshirPredicate.evaluate(with: text)
//    }
//}
//
//// MARK: - Token Manager
//@MainActor
//class TokenManager {
//    static let shared = TokenManager()
//    private init() {}
//    
//    private let authTokenKey = "AuthToken"
//    private let refreshTokenKey = "RefreshToken"
//    
//    func saveAuthToken(_ token: String) {
//        UserDefaults.standard.set(token, forKey: authTokenKey)
//    }
//    
//    func saveRefreshToken(_ token: String) {
//        UserDefaults.standard.set(token, forKey: refreshTokenKey)
//    }
//    
//    var getAuthToken: String? {
//        return UserDefaults.standard.string(forKey: authTokenKey)
//    }
//    
//    var getRefreshToken: String? {
//        return UserDefaults.standard.string(forKey: refreshTokenKey)
//    }
//    
//    func clearTokens() {
//        UserDefaults.standard.removeObject(forKey: authTokenKey)
//        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
//    }
//}
