//
//  ProfileViewReactor.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import ReactorKit

struct ProfileViewAction {
    var presentEditView: (ProfileUpdateModel) -> Void
    var presentNotifyView: () -> Void
    var presentPolicyView: () -> Void
    var logout: () -> Void
}

final class SetupViewReactor: Reactor {
    
    enum Action {
        case fetchProfile
        case editProfile(updatedModel: ProfileUpdateModel)
        case presentNotifyView
        case presentPolicyView
        case logout
        case deleteAccount
    }
    
    enum Mutation {
        case loadedProfile(profile: ProfileInfo)
    }
    
    struct State {
        @Pulse var userProfile: ProfileInfo?
    }
    
    var initialState = State()
    
    var fetchProfileImpl: FetchProfile
    var viewAction: ProfileViewAction
    
    init(editProfileUseCase: FetchProfile,
         viewAction: ProfileViewAction) {
        self.fetchProfileImpl = editProfileUseCase
        self.viewAction = viewAction
        action.onNext(.fetchProfile)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchProfile:
            return self.getProfile()
        case .editProfile(let updateModel):
            return presentEditView(updatedModel: updateModel)
        case .presentNotifyView:
            return presentNotifyView()
        case .presentPolicyView:
            return presentPolicyView()
        case .logout:
            return self.logout()
        case .deleteAccount:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadedProfile(let profile):
            newState.userProfile = profile
        }
        
        return newState
    }
    
}

extension SetupViewReactor {
    private func getProfile() -> Observable<Mutation> {
        return fetchProfileImpl.fetchProfile()
            .asObservable()
            .map { Mutation.loadedProfile(profile: $0) }
    }
    
    private func presentEditView(updatedModel: ProfileUpdateModel) -> Observable<Mutation> {
        viewAction.presentEditView(updatedModel)
        
        return Observable.empty()
    }
    
    
    /// 코디네이터에게 알림관리 뷰로 이동요청
    private func presentNotifyView() -> Observable<Mutation> {
        viewAction.presentNotifyView()
        return Observable.empty()
    }
    
    /// 코디네이터에게 개인정보 처리방침 뷰로 이동요청
    private func presentPolicyView() -> Observable<Mutation> {
        viewAction.presentPolicyView()
        return Observable.empty()
    }
    
    /// 로그아웃시 키체인에 저장된 토큰정보 삭제 후 로그인 화면으로 이동
    private func logout() -> Observable<Mutation> {
        KeyChainService.shared.deleteToken()
        viewAction.logout()
        return Observable.empty()
    }
}