//
//  PastPlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation
import ReactorKit

protocol MeetReviewListCommands: AnyObject {
    func fetchReview()
}

final class MeetReviewListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case selectedReview(index: Int)
        case requestReviewList
        case updateReview(ReviewPayload)
        case refresh
    }
    
    enum Mutation {
        case fetchReviewList(reviews: [Review])
    }
    
    struct State {
        @Pulse var reviews: [Review] = []
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let meetId: Int
    private let isJoin: Bool
    
    // MARK: - UseCase
    private let fetchReviewUseCase: FetchMeetReviewList
    
    // MARK: - Delegate
    private weak var delegate: MeetDetailDelegate?
    
    // MARK: - LifeCycle
    init(fetchReviewUseCase: FetchMeetReviewList,
         delegate: MeetDetailDelegate,
         meetId: Int,
         isJoin: Bool = false) {
        self.fetchReviewUseCase = fetchReviewUseCase
        self.delegate = delegate
        self.meetId = meetId
        self.isJoin = isJoin
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestReviewList:
            return fetchReviewList()
        case let .selectedReview(index):
            return presentReviewDetailView(index: index)
        case let .updateReview(payload):
            return handleReviewPayload(payload)
        case .refresh:
            return refreshReviewList()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchReviewList(reviews):
            newState.reviews = reviews.sorted(by: >)
        }
        
        return newState
    }
}

// MARK: - Data Requset
extension MeetReviewListViewReactor {

    /// 리뷰 리스트 불러오기
    private func fetchReviewList() -> Observable<Mutation> {
        
        let fetchPlanList = fetchReviewUseCase.execute(meetId: meetId)
            .catchAndReturn([])
            .map({ Mutation.fetchReviewList(reviews: $0) })
            
        return requestWithLoading(task: fetchPlanList)
    }
    
    private func refreshReviewList() -> Observable<Mutation> {
        delegate?.refresh()
        return .empty()
    }
}

// MARK: - Notify
extension MeetReviewListViewReactor {
    private func handleReviewPayload(_ payload: ReviewPayload) -> Observable<Mutation> {
        var reviewList = currentState.reviews
        
        switch payload {
        case let .updated(plan):
            self.updateReview(&reviewList, review: plan)
        case let .deleted(id):
            self.deleteReview(&reviewList, reviewId: id)
        default:
            break
        }
        return .just(.fetchReviewList(reviews: reviewList))
    }
    
    private func updateReview(_ reviewList: inout [Review], review: Review) {
        guard let updatedIndex = reviewList.firstIndex(where: {
            $0.id == review.id
        }) else { return }
        
        reviewList[updatedIndex] = review
        reviewList.sort(by: <)
    }
    
    private func deleteReview(_ reviewList: inout [Review], reviewId: Int) {
        reviewList.removeAll { $0.id == reviewId }
    }
}

// MARK: - Coordination
extension MeetReviewListViewReactor {
    private func presentReviewDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedReview = currentState.reviews[safe: index],
              let reviewId = selectedReview.id else { return .empty() }
        self.delegate?.selectedPlan(id: reviewId,
                                    type: .review)
        return .empty()
    }
}

// MARK: - Command
extension MeetReviewListViewReactor: MeetReviewListCommands {
    func fetchReview() {
        action.onNext(.requestReviewList)
    }
}

// MARK: - Loading & Error
extension MeetReviewListViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 1 }
}
