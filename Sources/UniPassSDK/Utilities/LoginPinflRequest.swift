//
//  LoginPinflRequest.swift
//  UniPassSDK
//
//  Created by Javlonbek Dev on 08/08/25.
//


//
//  LoginRequest.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import Foundation

struct LoginPinflRequest: Codable {
    let pinfl: String
    let faceImage: String
    
    enum CodingKeys: String, CodingKey {
        case pinfl = "pinfl"
        case faceImage = "face_image"
    }
}

struct LoginPassportRequest: Codable {
    let passport: String
    let birthDate: String
    let faceImage: String
    
    enum CodingKeys: String, CodingKey {
        case passport = "passport"
        case birthDate = "birth_date"
        case faceImage = "face_image"
    }
}
