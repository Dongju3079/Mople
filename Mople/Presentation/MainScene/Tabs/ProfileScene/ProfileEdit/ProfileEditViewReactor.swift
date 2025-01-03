//
//  ProfileEditViewReactor.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import ReactorKit

struct ProfileEditAction {
    var completed: (() -> Void)?
}

class ProfileEditViewReactor: Reactor {

    enum Action {
        case setLoading(isLoad: Bool)
        case editProfile(name: String, image: UIImage?)
    }
    
    enum Mutation {
        case editCompleted
        case notifyMessage(message: String?)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    private let profileEditUseCase: ProfileEdit
    private var completedAction: ProfileEditAction
    
    var initialState: State = State()
    
    init(profileEditUseCase: ProfileEdit,
         completedAction: ProfileEditAction) {
        print(#function, #line, "LifeCycle Test ProfileEditView Reactor Created" )
        self.profileEditUseCase = profileEditUseCase
        self.completedAction = completedAction
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test ProfileEditView Reactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        guard !currentState.isLoading else { return .empty()}
        
        switch action {
        case .setLoading(let isLoad):
            return .just(.setLoading(isLoad: isLoad))
        case let .editProfile(nickname, image) :
            return editProfile(name: nickname, image: image)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .editCompleted:
            completedAction.completed?()
        case .notifyMessage(let message):
            newState.message = message
        case .setLoading(let isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
    
    func handleError(err: Error) -> String {
        switch err {
        case NetworkError.notConnected:
            return AppError.networkError.info
        default:
            return AppError.unknownError.info
        }
    }
}

extension ProfileEditViewReactor {
    
    private func editProfile(name: String, image: UIImage?) -> Observable<Mutation> {
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
        
        #warning("이미지 업로드 먼저")
        let editProfile = profileEditUseCase.editProfile(nickname: name, image: image)
            .asObservable()
            .map({ _ in Mutation.editCompleted })
            .catch {
                Observable.just(Mutation.notifyMessage(message: self.handleError(err: $0)))
            }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))
            
        return Observable.concat([loadingOn,
                                  editProfile,
                                  loadingOff])
    }
}
