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
    private static let acceptAll = ["Accept": "*/*"]
    private static let acceptJson = ["Accept": "application/json"]
    private static let contentJson = ["Content-Type": "application/json"]
    
    static func getReceiveJsonHeader() -> [String:String] {
        Self.acceptJson
    }
    
    static func getReceiveAllHeader() -> [String:String] {
        Self.acceptAll
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
                            bodyParameters: ["token": fcmToken,
                                             "subscribe": true])
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
    static func executeSignUp(requestModel: SignUpRequest) -> Endpoint<Data> {
        return try! Endpoint(path: "auth/sign-up",
                             method: .post,
                             headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                             bodyParametersEncodable: requestModel,
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
    
    static func getUserInfo() throws -> Endpoint<UserInfoDTO> {
        return try Endpoint(path: "user/info",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
}

// MARK: - Profile
extension APIEndpoints {
    
    static func setupProfile(requestModel: ProfileEditRequest) throws -> Endpoint<UserInfoDTO> {
        return try Endpoint(path: "user/info",
                            authenticationType: .accessToken,
                            method: .patch,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: requestModel)
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
    static func uploadImage(_ imageData: Data,
                            folderPath: ImageUploadPath) -> Endpoint<String?> {
        let boundary = UUID().uuidString
        let multipartFormEncoder = MultipartBodyEncoder(boundary: boundary)
        return try! Endpoint(path: "image/upload/\(folderPath.rawValue)",
                             method: .post,
                             headerParameters: HTTPHeader.getMultipartFormDataHeader(boundary),
                             bodyParameters: ["image": imageData],
                             bodyEncoder: multipartFormEncoder)
    }
    
    static func uploadReviewImage(id: Int,
                                  imageDatas: [Data]) throws -> Endpoint<Void> {
        print(#function, #line, "dataCount : \(imageDatas.count)" )
        print(#function, #line, "id : \(id)" )
        let boundary = UUID().uuidString
        let multipartFormEncoder = MultipartBodyEncoder(boundary: boundary)
        return try Endpoint(path: "image/review/review",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getMultipartFormDataHeader(boundary),
                            bodyParameters: ["reviewId": "\(id)",
                                             "images": imageDatas],
                            bodyEncoder: multipartFormEncoder)
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

// MARK: - Meet
extension APIEndpoints {
    static func createMeet(_ meet: CreateMeetRequest) throws -> Endpoint<MeetResponse> {
        return try Endpoint(path: "meet/create",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: meet)
    }
    
    static func fetchMeetList() throws -> Endpoint<[MeetResponse]> {
        return try Endpoint(path: "meet/list",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
        
    }
    
    static func fetchMeetDetail(_ meetId: Int) throws -> Endpoint<MeetResponse> {
        return try Endpoint(path: "meet/\(meetId)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
}

// MARK: - Plan
extension APIEndpoints {
    
    // MARK: - Fetch
    static func fetchPlan(planId: Int) throws -> Endpoint<PlanResponse> {
        return try Endpoint(path: "plan/detail/\(planId)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func fetchRecentPlan() throws -> Endpoint<RecentPlanResponse> {
        return try Endpoint(path: "plan/view",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
        
    }
    
    static func fetchMeetPlan(meetId: Int) throws -> Endpoint<[PlanResponse]> {
        return try Endpoint(path: "plan/list/\(meetId)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
        
    }
    
    // MARK: - CRUD
    static func joinPlan(planId: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "plan/join/\(planId)",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getReceiveAllHeader())
    }
    
    static func leavePlan(planId: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "plan/leave/\(planId)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getReceiveAllHeader())
    }
    
    static func createPlan(_ plan: PlanRequest) throws -> Endpoint<PlanResponse> {
        return try Endpoint(path: "plan/create",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: plan)
    }
    
    static func editPlan(_ plan: PlanRequest) throws -> Endpoint<PlanResponse> {
        return try Endpoint(path: "plan/update",
                            authenticationType: .accessToken,
                            method: .patch,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: plan)
    }
    
    
}

// MARK: - Review
extension APIEndpoints {
    static func fetchMeetReview(meetId: Int) throws -> Endpoint<[ReviewResponse]> {
        return try Endpoint(path: "review/list/\(meetId)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func fetchReviewDetail(reviewId: Int) throws -> Endpoint<ReviewResponse> {
        return try Endpoint(path: "review/\(reviewId)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func deleteReviewImage(reviewId: Int, imageIds: [String]) throws -> Endpoint<Void> {
        return try Endpoint(path: "review/images/\(reviewId)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParameters: ["reviewImages": imageIds]
        )
    }
}

// MARK: - Search Location
extension APIEndpoints {
    static func searchPlace(_ locationRequest: SearchLocationRequest) throws -> Endpoint<SearchPlaceResultResponse> {
        return try Endpoint(path: "location/kakao",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: locationRequest)
    }
}

// MARK: - 댓글
extension APIEndpoints {
    static func fetchCommentList(postId: Int) throws -> Endpoint<[CommentResponse]> {
        return try Endpoint(path: "comment/\(postId)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func createComment(postId: Int, comment: String) throws -> Endpoint<[CommentResponse]> {
        return try Endpoint(path: "comment/\(postId)",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParameters: ["contents": comment])
    }
    
    static func deleteComment(commentId: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "comment/\(commentId)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getReceiveAllHeader())
    }
    
    static func editComment(postId: Int,
                            commentId: Int,
                            comment: String) throws -> Endpoint<[CommentResponse]> {
        return try Endpoint(path: "comment/\(postId)/\(commentId)",
                            authenticationType: .accessToken,
                            method: .patch,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParameters: ["contents": comment])
    }
    
    static func reportComment(reportComment: ReportCommentRequest) throws -> Endpoint<Void> {
        return try Endpoint(path: "comment/report",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveAllHeader(),
                            bodyParametersEncodable: reportComment)
    }
}

// MARK: - 멤버 리스트
extension APIEndpoints {
    static func fetchMember(type: MemberListType) throws -> Endpoint<MemberListResponse> { // 모델 변경
        return try Endpoint(path: getFetchMemberPath(type: type),
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    private static func getFetchMemberPath(type: MemberListType) -> String {
        switch type {
        case let .meet(id):
            return "meet/members/\(id ?? 0)"
        case let .plan(id):
            return "plan/participants/\(id ?? 0)"
        case let .review(id):
            return "review/participants/\(id ?? 0)"
        }
    }
}

extension APIEndpoints {
    static func report(type: ReportType) throws -> Endpoint<Void> {
        return try Endpoint(path: getReportPath(type: type),
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveAllHeader())
    }
    
    private static func getReportPath(type: ReportType) -> String {
        switch type {
        case .plan:
            return "plan/report"
        case .review:
            return "review/report"
        case .comment:
            return "comment/report"
        }
    }
}
