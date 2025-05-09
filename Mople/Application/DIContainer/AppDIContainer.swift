//
//  AppDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation

final class AppDIContainer {
    
    // MARK: - 앱 서비스
    
    lazy var appNetworkService: AppNetworkService = {
        
        let baseUrl = AppConfiguration.apiBaseURL
        
        let config = ApiDataNetworkConfig(baseURL: URL(string: baseUrl))
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        
        let transferService = DefaultDataTransferService(with: apiDataNetwork)
        
        return DefaultAppNetWorkService(dataTransferService: transferService)
    }()
    
    lazy var commonDIContainer = CommonDIContainer(appNetworkService: appNetworkService)
}

// MARK: - Make DIContainer
extension AppDIContainer {
    
    // MARK: - 런치 스크린
    func makeLaunchViewController(coordinator: LaunchCoordination) -> LaunchViewController {
        return LaunchViewController(
            viewModel: makeLaunchViewModel(coordinator: coordinator))
    }
    
    private func makeLaunchViewModel(coordinator: LaunchCoordination) -> LaunchViewModel {
        return DefaultLaunchViewModel(fetchUserInfo: commonDIContainer.makeFetchUserInfoUseCase(),
                                      coordinator: coordinator)
    }

    // MARK: - 로그인 플로우
    func makeLoginSceneDIContainer() -> AuthSceneDIContainer {
        return AuthSceneDIContainer(appNetworkService: appNetworkService,
                                     commonFactory: commonDIContainer)
    }
    
    // MARK: - 메인 플로우
    func makeMainSceneDIContainer(isLoign: Bool) -> MainSceneDIContainer {
        return MainSceneDIContainer(isLogin: isLoign,
                                    appNetworkService: appNetworkService,
                                    commonFactory: commonDIContainer)
    }
}



