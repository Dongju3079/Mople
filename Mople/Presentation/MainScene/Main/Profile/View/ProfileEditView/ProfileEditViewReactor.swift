//
//  ProfileEditViewReactor.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import ReactorKit

class ProfileEditViewReactor: Reactor, LifeCycleLoggable {

    enum Action {
        case setLoading(isLoad: Bool)
        case editProfile(name: String, image: UIImage?)
        case endView
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
    
    private let userInfoManagementUseCase: EditUserInfo
    private let imageUploadUseCase: ImageUpload
    private weak var navigator: NavigationCloseable?
    
    var initialState: State = State()
    
    init(userInfoManagementUseCase: EditUserInfo,
         imageUploadUseCase: ImageUpload,
         navigator: NavigationCloseable) {
        self.userInfoManagementUseCase = userInfoManagementUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.navigator = navigator
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setLoading(let isLoad):
            return .just(.setLoading(isLoad: isLoad))
        case let .editProfile(nickname, image) :
            return editProfile(name: nickname, image: image)
        case .endView:
            navigator?.dismiss()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .editCompleted:
            navigator?.dismiss()
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
        
        
        let editProfile = imageUploadUseCase.execute(image)
            .flatMap { [weak self] imagePath -> Single<Void> in
                guard let self else { return .error(AppError.unknownError)}
                return self.userInfoManagementUseCase
                    .execute(nickname: name, imagePath: imagePath)
            }
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
