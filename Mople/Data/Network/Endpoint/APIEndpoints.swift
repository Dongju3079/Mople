//
//  APIEndpoints.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation

enum TokenError: Error {
    case noJWTToken
    case noFCMToken
}

enum HTTPHeader {
    static let acceptAll = ["Accept": "*/*"]
    static let acceptJson = ["Accept": "application/json"]
    static let contentJson = ["Content-Type": "application/json"]
    
    static func getReceiveJsonHeader() -> [String:String] {
        Self.acceptJson
    }
    
    static func getSendAndReceiveAllHeader() -> [String:String] {
        return Self.acceptAll.merging(Self.contentJson) { current, _ in current }
    }
    
    static func getSendAndReceiveJsonHeader() -> [String:String] {
        Self.acceptJson.merging(Self.contentJson) { current, _ in current }
    }
    
    static func getMultipartFormDataHeader(_ boundary: String) -> [String:String] {
        let multiType = ["Content-Type":"multipart/form-data; boundary=\(boundary)"]
        return Self.acceptJson.merging(multiType) { current, _ in current }
    }
}

struct APIEndpoints {
    
    private static func getAccessTokenParameters() throws -> [String:String] {
        guard let token = KeyChainService.cachedToken?.accessToken else { throw TokenError.noJWTToken }
        return ["Authorization":"Bearer \(token)"]
    }
    
    private static func getRefreshTokenParameters() throws -> [String:String] {
        guard let token = KeyChainService.cachedToken?.refreshToken else { throw TokenError.noJWTToken }
        return ["refreshToken": token]
    }
}

// MARK: - FCM Token
extension APIEndpoints {
    static func uploadFCMToken(_ fcmToken: String?) throws -> Endpoint<Void> {
        guard let fcmToken else { throw TokenError.noFCMToken }
        return try Endpoint(path: "token/save",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveAllHeader(),
                            bodyParameters: ["token": fcmToken])
    }
}

// MARK: - Token Refresh
extension APIEndpoints {
    static func reissueToken() throws -> Endpoint<Data> {
        return try Endpoint(path: "auth/recreate",
                            authenticationType: .refreshToken,
                            method: .post,
                            headerParameters: HTTPHeader.getReceiveJsonHeader(),
                            responseDecoder: RawDataResponseDecoder())
    }
}

// MARK: - Login
extension APIEndpoints {
    static func executeSignUp(platform: String,
                              identityToken: String,
                              email: String,
                              nickname: String,
                              imagePath: String?) -> Endpoint<Data> {
        return try! Endpoint(path: "auth/sign-up",
                             method: .post,
                             headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                             bodyParameters: ["socialProvider": platform,
                                              "providerToken": identityToken,
                                              "email": email,
                                              "nickname": nickname,
                                              "deviceType": "IOS",
                                              "image": imagePath ?? NSNull()],
                             responseDecoder: RawDataResponseDecoder())
    }
    
    static func executeSignIn(platform: String,
                              identityToken: String,
                              email: String) -> Endpoint<Data> {
        return try! Endpoint(path: "auth/sign-in",
                             method: .post,
                             headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                             bodyParameters: ["socialProvider": platform,
                                              "providerToken": identityToken,
                                              "email": email],
                             responseDecoder: RawDataResponseDecoder())
    }
}

// MARK: - Profile
extension APIEndpoints {
    
    static func setupProfile(nickname: String,
                             imagePath: String?) throws -> Endpoint<Void> {
        return try Endpoint(path: "user/info",
                            authenticationType: .accessToken,
                            method: .patch,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParameters: ["profileImg" : imagePath ?? NSNull(),
                                             "nickname" : nickname])
    }
    
    static func checkNickname(_ name: String) -> Endpoint<Data> {
        return try! Endpoint(path: "user/nickname/duplicate",
                             method: .get,
                             headerParameters: HTTPHeader.getReceiveJsonHeader(),
                             queryParameters: ["nickname":name],
                             responseDecoder: RawDataResponseDecoder())
    }
    
    static func getRandomNickname() -> Endpoint<Data> {
        return try! Endpoint(path: "user/nickname/random",
                             method: .get,
                             headerParameters: HTTPHeader.getReceiveJsonHeader(),
                             responseDecoder: RawDataResponseDecoder())
    }
}
// MARK: - 이미지 업로드
extension APIEndpoints {
    static func uploadImage(_ imageData: Data, folderPath: ImageUploadPath) -> Endpoint<Data> {
        let boundary = UUID().uuidString
        let multipartFormEncoder = MultipartBodyEncoder(boundary: boundary)
        print(#function, #line, "# 30 초기 바운더리 : \(boundary)")
        return try! Endpoint(path: "image/upload/\(folderPath.rawValue)",
                             method: .post,
                             headerParameters: HTTPHeader.getMultipartFormDataHeader(boundary),
                             bodyParameters: ["image": imageData],
                             bodyEncoder: multipartFormEncoder,
                             responseDecoder: RawDataResponseDecoder())
    }
    
}

// MARK: - 파이어베이스 토큰 저장
extension APIEndpoints {
    static func uploadToken(fcmToken: String) throws -> Endpoint<Void> {
        return try Endpoint(path: "token/save",
                             authenticationType: .accessToken,
                             method: .post,
                             headerParameters: HTTPHeader.getSendAndReceiveAllHeader(),
                             bodyParameters: ["token": fcmToken])
    }
}
