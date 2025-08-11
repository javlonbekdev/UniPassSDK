//
//  LoginResponse.swift
//  UniPassSDK
//
//  Created by Javlonbek Dev on 08/08/25.
//


//
//  LoginResponse 2.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import Foundation

struct LoginResponse: Codable {
    let authenticationCode: Int
    let authenticationToken: String?
    let refreshToken: String?
    let description: String
    let face: FaceInfo
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case authenticationCode = "authentication_code"
        case authenticationToken = "authentication_token"
        case refreshToken = "refresh_token"
        case description
        case face
        case user
    }
}

struct FaceInfo: Codable {
    let isSpoofed: Bool
    let isAuthenticated: Bool
    let isFaceMatched: Bool
    let distance: Double
    let spoofingScore: Double
    
    enum CodingKeys: String, CodingKey {
        case isSpoofed = "is_spoofed"
        case isAuthenticated = "is_authenticated"
        case isFaceMatched = "is_face_matched"
        case distance
        case spoofingScore = "spoofing_score"
    }
}

struct User: Codable {
    // User properties will be added when available
}
