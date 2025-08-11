//
//  DeviceInfoHelper.swift
//  UniPassSDK
//
//  Created by Javlonbek Dev on 08/08/25.
//


//
//  DeviceInfoHelper.swift
//  Unipass
//
//  Created by Javlonbek Dev on 16/07/25.
//

import UIKit

@MainActor
class DeviceInfoHelper {
    static func getDeviceInfo() -> [String: String] {
        let device = UIDevice.current
        return [
            "App-Version-Code": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1",
            "App-Version-Name": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0",
            "Device-Id": getDeviceId(),
            "Device-Name": device.name,
            "Device-Manufacturer": "Apple",
            "Device-Model": getDeviceModel(),
            "iOS-Version": device.systemVersion,
            "Accept-Language": Locale.current.languageCode ?? "la",
            "X-App-Source": ""
        ]
    }
    
    private static func getDeviceId() -> String {
        // Use keychain to store persistent device ID
        if let deviceId = getDeviceIdFromKeychain() {
            return deviceId
        }
        
        let newDeviceId = UUID().uuidString
        saveDeviceIdToKeychain(newDeviceId)
        return newDeviceId
    }
    
    static var isAppStoreVersion: Bool {
        guard let url = Bundle.main.appStoreReceiptURL else { return false }
        print(url.lastPathComponent)
        return url.lastPathComponent == "receipt"
    }
    
    private static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "Unknown"
            }
        }
    }
    
    private static func getDeviceIdFromKeychain() -> String? {
        // Keychain implementation for device ID
        // This is a simplified version - use proper keychain wrapper
        return UserDefaults.standard.string(forKey: "DeviceId")
    }
    
    private static func saveDeviceIdToKeychain(_ deviceId: String) {
        // Keychain implementation for device ID
        // This is a simplified version - use proper keychain wrapper
        UserDefaults.standard.set(deviceId, forKey: "DeviceId")
    }
}
