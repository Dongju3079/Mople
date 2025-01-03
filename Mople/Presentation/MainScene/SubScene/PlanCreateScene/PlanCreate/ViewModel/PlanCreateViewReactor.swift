//
//  PlanCreateViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/9/24.
//

import Foundation
import ReactorKit

final class PlanCreateViewReactor: Reactor {
    
    enum DateError: Error {
        case invalid
        
        var info: String {
            "선택된 시간이 너무 이릅니다."
        }
    }
    
    enum UpdatePlanType {
        case day
        case time
    }
    
    enum Action {
        enum SetValue {
            case meet(_ index: Int)
            case name(_ name: String)
            case date(_ date: DateComponents, type: UpdatePlanType)
            case place(_ placeInfo: PlaceInfo)
        }

        enum FlowAction {
            case groupSelectView
            case dateSelectView
            case timeSelectView
            case placeSelectView
            case endProcess
        }
        
        case setValue(SetValue)
        case flowAction(FlowAction)
        case fetchMeetList
        case requestPlanCreation
    }
    
    enum Mutation {
        enum UpdateValue {
            case meet(_ meet: MeetSummary)
            case name(_ name: String)
            case date(_ date: DateComponents)
            case time(_ date: DateComponents)
            case place(_ location: PlaceInfo)
        }
        
        case updateValue(UpdateValue)
        case updateMeetList(_ meets: [MeetSummary])
        case responsePlanCreation(_ plan: Plan)
        case notifyLoadingState(_ isLoading: Bool)
        case notifyMessage(_ message: String)
    }
    
    struct State {
        @Pulse var seletedMeet: MeetSummary?
        @Pulse var planTitle: String?
        @Pulse var selectedDay : DateComponents?
        @Pulse var selectedTime : DateComponents?
        @Pulse var selectedPlace: UploadPlace?
        @Pulse var meets: [MeetSummary] = []
        @Pulse var isLoading: Bool = false
        @Pulse var message: String?
        
        var isAllFieldsFilled: Bool {
            return seletedMeet != nil &&
            planTitle != nil &&
            planTitle?.isEmpty == false &&
            selectedDay != nil &&
            selectedTime != nil &&
            selectedPlace != nil
        }
    }
    
    private let fetchMeetListUseCase: FetchGroup
    private let createPlanUseCase: CreatePlan
    private weak var flow: PlanCreateFlow?
    
    var initialState: State = State()
    
    init(createPlanUseCase: CreatePlan,
         fetchMeetListUSeCase: FetchGroup,
         flow: PlanCreateFlow) {
        print(#function, #line, "LifeCycle Test PlanCreateViewReactor Created" )

        self.createPlanUseCase = createPlanUseCase
        self.fetchMeetListUseCase = fetchMeetListUSeCase
        self.flow = flow
        self.action.onNext(.fetchMeetList)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PlanCreateViewReactor Deinit" )
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setValue(value):
            return self.handleSetValueAction(value)
        case .requestPlanCreation:
            return self.requestPlanCreation()
        case .fetchMeetList:
            return self.fetchMeetList()
        case .flowAction(let action):
            return self.handleFlowAction(action)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateValue(value):
            self.handleValueMutation(&newState, value: value)
        case .updateMeetList(let meets):
            newState.meets = meets
        case .responsePlanCreation(let plan):
            self.flow?.completedProcess(plan: plan)
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        case let .notifyMessage(message):
            newState.message = message
        }
        
        return newState
    }
}

extension PlanCreateViewReactor {
    
    private func fetchMeetList() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        #warning("에러 처리")
        let updateMeet = fetchMeetListUseCase.fetchGroupList()
            .asObservable()
            .map({ $0.compactMap { meet in
                meet.meetSummary }
            })
            .map { Mutation.updateMeetList($0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  updateMeet,
                                  loadingStop])
    }
    
#warning("에러 처리")
    private func requestPlanCreation() -> Observable<Mutation> {
        do {
            guard let planCreationForm = try buliderPlanCreation() else { throw DateError.invalid }
            return self.createPlan(planCreationForm)
        } catch {
            if let err = error as? DateError {
                return .just(.notifyMessage(err.info))
            } else {
                return .just(.notifyMessage("Unknown Error"))
            }
        }
    }
}

// MARK: - 일정 생성 및 일정 유효성 체크
extension PlanCreateViewReactor {
    private func createPlan(_ plan: PlanUploadRequest) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let updatePlan = createPlanUseCase.createPlan(with: plan)
            .asObservable()
            .map { Mutation.responsePlanCreation($0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  updatePlan,
                                  loadingStop])
    }
    
    private func buliderPlanCreation() throws -> PlanUploadRequest? {
        guard let date = try self.createDate(),
              let meetId = currentState.seletedMeet?.id,
              let name = currentState.planTitle,
              let location = currentState.selectedPlace else { return nil }
        
        return .init(meetId: meetId,
                     name: name,
                     date: DateManager.toServerDateString(date),
                     location: location)
    }
    
    private func createDate() throws -> Date? {
        guard let date = currentState.selectedDay,
              let time = currentState.selectedTime,
              let combineDate = DateComponents(year: date.year,
                                               month: date.month,
                                               day: date.day,
                                               hour: time.hour,
                                               minute: time.minute).toDate() else { return nil }
        return try checkValidDate(combineDate)
    }
    
    private func checkValidDate(_ date: Date) throws -> Date {
        guard date > DateManager.addFiveMinutes(Date()) else { throw DateError.invalid }
        return date
    }
}

// MARK: - Set Value
extension PlanCreateViewReactor {
    private func handleValueMutation(_ state: inout State, value: Mutation.UpdateValue) {
        switch value {
        case .meet(let meet):
            state.seletedMeet = meet
        case .name(let name):
            state.planTitle = name
        case .date(let date):
            state.selectedDay = date
        case .time(let time):
            state.selectedTime = time
        case .place(let place):
            state.selectedPlace = .init(place: place)
        }
    }
    
    private func handleSetValueAction(_ action: Action.SetValue)  -> Observable<Mutation> {
        switch action {
        case let .meet(index):
            return self.parseMeetId(selectedIndex: index)
        case let .name(name):
            return .just(.updateValue(.name(name)))
        case let .date(date, type):
            return self.updateDate(date: date, type: type)
        case let .place(placeInfo):
            return .just(.updateValue(.place(placeInfo)))
        }
    }
    
    private func parseMeetId(selectedIndex: Int) -> Observable<Mutation> {
        guard let meet = currentState.meets[safe: selectedIndex] else { return .empty() }
        return .just(.updateValue(.meet(meet)))
    }
    
    private func updateDate(date: DateComponents, type: UpdatePlanType) -> Observable<Mutation> {
        switch type {
        case .day:
            return .just(.updateValue(.date(date)))
        case .time:
            return .just(.updateValue(.time(date)))
        }
    }
}

// MARK: - Flow Action
extension PlanCreateViewReactor {
    private func handleFlowAction(_ action: Action.FlowAction) -> Observable<Mutation> {
        switch action {
        case .groupSelectView:
            flow?.presentGroupSelectView()
        case .dateSelectView:
            flow?.presentDateSelectView()
        case .timeSelectView:
            flow?.presentTimeSelectView()
        case .placeSelectView:
            flow?.presentSearchLocationView()
        case .endProcess:
            flow?.endProcess()
        }
        return .empty()
    }
}

