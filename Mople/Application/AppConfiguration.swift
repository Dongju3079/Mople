//
//  AppConfiguration.swift
//  Group
//
//  Created by CatSlave on 8/19/24.
//

import Foundation

enum AppConfiguration {
    
    enum Network {
        static let defaultHeaders: [String: String] = [
            "os" : "iOS",
            "version": AppConfiguration.version
        ]
    }

    static let schemeTitle = getValue(forKey: "mainScheme")
    static let apiBaseURL = getValue(forKey: "ApiBaseURL")
    static let policyURL = getValue(forKey: "PolicyURL")
    static let kakaoKey = getValue(forKey: "KakaoKey")
    static let naverID = getValue(forKey: "NaverClientId")
    static let bundleID = Bundle.main.bundleIdentifier ?? "UNKNOWN"
    static let version = Bundle.main.releaseVersionNumber ?? "0.0"
    static let firebaseDevInfo = Bundle.main.path(forResource: "GoogleService-Dev-Info", ofType: "plist")
    
    private static func getValue(forKey key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("\(key) is missing in Info.plist")
        }
        return value
    }
}
