//
//  ProfileFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol SetupCoordinatorDependencies {
    func makeSetupController(action: ProfileViewAction) -> SetupViewController
    func makeProfileEditViewController(updateModel: ProfileUpdateModel) -> ProfileEditViewController
    func makeNotifyViewController() -> NotifyViewController
    func makePolicyViewController() -> PolicyViewController
}

final class SetupCoordinator: BaseCoordinator {
    private let dependencies: SetupCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: SetupCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeSetupController(action: getAccountAction())
        
        navigationController.pushViewController(vc, animated: false)
    }
}

extension SetupCoordinator {
    private func getAccountAction() -> ProfileViewAction {
        .init(presentEditView: presentEditView(updateModel:),
              presentNotifyView: presentNotifyView,
              presentPolicyView: presentPolicyView,
              logout: logout)
    }
    
    private func presentEditView(updateModel: ProfileUpdateModel) {
        let profileSetupView = dependencies.makeProfileEditViewController(updateModel: updateModel)
        self.presentView(view: profileSetupView)
    }
    
    private func presentNotifyView() {
        let notifyView = dependencies.makeNotifyViewController()
        self.presentView(view: notifyView)
    }
    
    private func presentPolicyView() {
        let policyView = dependencies.makePolicyViewController()
        self.presentView(view: policyView)
    }
    
    private func logout() {
        (self.parentCoordinator as? AccountAction)?.signOut()
    }
}

// MARK: - Helper
extension SetupCoordinator {
    
    // 커스텀 present로 이동하기 (탭바가 없는 상태로 이동하기 위해서)
    private func presentView(view: UIViewController) {
        guard let customNavi = navigationController as? MainNavigationController else { return }
        view.modalPresentationStyle = .custom
        view.transitioningDelegate = customNavi
        customNavi.present(view, animated: true, completion: nil)
    }
}

