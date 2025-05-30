//
//  FetchRecentMeeting.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import Foundation
import RxSwift

protocol FetchHomeData {
    func execute() -> Observable<HomeData>
}

final class FetchHomeDataUseCase: FetchHomeData {
    private let repo: PlanRepo
    
    init(repo: PlanRepo) {
        self.repo = repo
    }
    
    func execute() -> Observable<HomeData> {
        return repo.fetchHomeData()
            .map { $0.toDomain() }
            .asObservable()
    }
}





