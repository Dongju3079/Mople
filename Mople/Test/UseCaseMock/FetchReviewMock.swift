//
//  FetchReviewMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

final class FetchReviewMock: FetchReviewList {
    
    private func getReviews() -> [Review] {
        return Array(0...10).map { .mock(posterId: $0) }
    }
    
    func execute(meetId: Int) -> Single<[Review]> {
        return Observable.just(getReviews())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
    
    
}
