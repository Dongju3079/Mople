//
//  DetailGroupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import ReactorKit

protocol MeetDetailDelegate: AnyObject, ChildLoadingDelegate {
    func selectedPlan(id: Int, type: PostType)
    func refresh()
}

enum MeetDetailError: Error {
    case noResponse(ResponseError)
    case midnight(DateTransitionError)
    case unknown(Error)
}

final class MeetDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Flow {
            case switchPage(isFuture: Bool)
            case pushMeetSetupView
            case createPlan
            case endFlow
            case showMeetImage
        }

        enum Loading {
            case planLoading(Bool)
            case reviewLoading(Bool)
        }
        
        case fetchMeetInfo
        case refresh
        case invite
        case flow(Flow)
        case loading(Loading)
        case editMeet(MeetPayload)
        case catchError(MeetDetailError)
    }
    
    enum Mutation {
        case setMeetInfo(meet: Meet)
        case updateMeetInfoLoading(Bool)
        case updatePlanListLoading(Bool)
        case updateReviewListLoading(Bool)
        case updateInviteUrl(String)
        case catchError(MeetDetailError)
    }
    
    struct State {
        @Pulse var meet: Meet?
        @Pulse var inviteUrl: String?
        @Pulse var meetInfoLoaded: Bool = false
        @Pulse var futurePlanLoaded: Bool = false
        @Pulse var pastPlanLoaded: Bool = false
        @Pulse var error: MeetDetailError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let meetId: Int
    private var isLoading = false
    
    // MARK: - UseCase
    private let fetchMeetUseCase: FetchMeetDetail
    private let inviteMeetUseCase: InviteMeet
    
    // MARK: - Coordinator
    private weak var coordinator: MeetDetailCoordination?
    
    // MARK: - Commands
    public weak var planListCommands: MeetPlanListCommands?
    public weak var reviewListCommands: MeetReviewListCommands?
    
    // MARK: - LifeCycle
    init(fetchMeetUseCase: FetchMeetDetail,
         inviteMeetUseCase: InviteMeet,
         coordinator: MeetDetailCoordination,
         meetID: Int) {
        self.fetchMeetUseCase = fetchMeetUseCase
        self.inviteMeetUseCase = inviteMeetUseCase
        self.coordinator = coordinator
        self.meetId = meetID
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initial Setup
    private func initialAction() {
        action.onNext(.fetchMeetInfo)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchMeetInfo:
            return fetchMeetInfo()
        case .invite:
            return requestInviteUrl()
        case let .editMeet(payload):
            return handleMeetPayload(with: payload)
        case .refresh:
            return resetPost()
        case let .loading(action):
            return handleChildLoading(action)
        case let .flow(action):
            return handleFlowAction(action)
        case let .catchError(err):
            return .just(.catchError(err))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .setMeetInfo(meet):
            newState.meet = meet
        case let .updateInviteUrl(url):
            newState.inviteUrl = url
        case let .updateMeetInfoLoading(isLoading):
            newState.meetInfoLoaded = isLoading
        case let .updatePlanListLoading(isLoading):
            newState.futurePlanLoaded = isLoading
        case let .updateReviewListLoading(isLoading):
            newState.pastPlanLoaded = isLoading
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Data Request
extension MeetDetailViewReactor {
    private func fetchMeetInfo() -> Observable<Mutation> {
        
        let fetchMeet = fetchMeetUseCase.execute(meetId: meetId)
            .map { [weak self] in
                self?.fetchPost()
                return Mutation.setMeetInfo(meet: $0)
            }
        
        return requestWithLoading(task: fetchMeet)
    }
    
    private func requestInviteUrl() -> Observable<Mutation> {
        guard let meetId = currentState.meet?.meetSummary?.id, !isLoading else { return .empty() }
        isLoading = true
        let inviteMeet = inviteMeetUseCase.execute(id: meetId)
            .map { Mutation.updateInviteUrl($0) }
        
        return requestWithLoading(task: inviteMeet)
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
    }
}

// MARK: - Coordinator
extension MeetDetailViewReactor {
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case let .switchPage(isFuture):
            coordinator?.swicthPlanListPage(isFuture: isFuture)
        case .pushMeetSetupView:
            guard let meet = currentState.meet else { return .empty() }
            coordinator?.pushMeetSetupView(meet: meet)
        case .createPlan:
            guard let meet = currentState.meet?.meetSummary else { return .empty() }
            coordinator?.presentPlanCreateView(meet: meet)
        case .endFlow:
            coordinator?.endFlow()
        case .showMeetImage:
            let meetSummary = currentState.meet?.meetSummary
            let title = meetSummary?.name
            let imagePath = meetSummary?.imagePath
            coordinator?.presentPhotoView(title: title,
                                          imagePath: imagePath)
        }
        
        return .empty()
    }
}

// MARK: - Notify
extension MeetDetailViewReactor {
    /// 미팅 수정 알림 수신
    private func handleMeetPayload(with payload: MeetPayload) -> Observable<Mutation> {
        guard case .updated(let meet) = payload else { return .empty() }
        return .just(.setMeetInfo(meet: meet))
    }
    
    private func resetPost() -> Observable<Mutation> {
        return fetchMeetInfo()
    }
}

// MARK: - Commands
extension MeetDetailViewReactor {
    private func fetchPost() {
        planListCommands?.fetchPlan()
        reviewListCommands?.fetchReview()
    }
}

// MARK: - Delegate
extension MeetDetailViewReactor: MeetDetailDelegate {
    
    func selectedPlan(id: Int, type: PostType) {
        coordinator?.presentPlanDetailView(postId: id, type: type)
    }
    
    func refresh() {
        action.onNext(.refresh)
    }
    
    func updateLoadingState(_ isLoading: Bool, index: Int) {
        switch index {
        case 0:
            action.onNext(.loading(.planLoading(isLoading)))
        case 1:
            action.onNext(.loading(.reviewLoading(isLoading)))
        default:
            break
        }
    }

    func catchError(_ error: Error, index: Int) {
        switch error {
        case let error as DateTransitionError:
            action.onNext(.catchError(.midnight(error)))
        case let error as ResponseError:
            action.onNext(.catchError(.noResponse(error)))
        default:
            return
        }
    }
}

// MARK: - Child Loading
extension MeetDetailViewReactor {
    private func handleChildLoading(_ action: Action.Loading) -> Observable<Mutation> {
        switch action {
        case let .planLoading(isLoad):
            return .just(.updatePlanListLoading(isLoad))
        case let .reviewLoading(isLoad):
            return .just(.updateReviewListLoading(isLoad))
        }
    }
}

// MARK: - Loading & Error
extension MeetDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateMeetInfoLoading(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = handleDataRequestError(err: dataError) else {
            return .catchError(.unknown(error))
        }
        return .catchError(.noResponse(responseError))
    }
    
    private func handleDataRequestError(err: DataRequestError) -> ResponseError? {
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: .meet(id: meetId))
    }
}
