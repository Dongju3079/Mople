//
//  DetailUserInfoRepo.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//
import RxSwift

final class DefaultUserInfoRepo: BaseRepositories, UserInfoRepo {
    func getUserInfo() -> Single<UserInfoDTO> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.getUserInfo()
        }
    }
    
    func editProfile(nickname: String, imagePath: String?) -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.setupProfile(nickname: nickname,
                                          imagePath: imagePath)
        }
    }
}

