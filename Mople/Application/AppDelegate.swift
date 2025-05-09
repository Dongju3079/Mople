//
//  AppDelegate.swift
//  Group_Project
//
//  Created by CatSlave on 7/11/24.
//

import UIKit
import KakaoSDKCommon
import FirebaseCore
import KakaoSDKAuth
import NMapsMap
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let appDIContainer = AppDIContainer()
    var appFlowCoordinator: AppFlowCoordinator?
    var wasInBackground: Bool = false {
        didSet {
            print(#function, #line, "application wasIn : \(wasInBackground)" )
        }
    }
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureRealmMigration()
        registerServices()
        reqeustRemoteNotifications()
        AppAppearance.setupAppearance()
        
        window = UIWindow(frame: UIScreen.main.bounds)

        let navigationController = AppNaviViewController(type: .main)

        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController,
                                                appDIContainer: appDIContainer)
        
        window?.rootViewController = navigationController
        appFlowCoordinator?.start()
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    private func reqeustRemoteNotifications() {
        print(#function, #line)
        UNUserNotificationCenter.current().delegate = self
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(#function, #line, "# 29" )
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            _ = AuthController.handleOpenUrl(url: url)
        }
        
        return false
    }
    
    // 알림허용 시 디바이스 토큰 발행 및 apns 서버로 업로드
    // ios 버전 업로드, 앱 업데이트 등 디바이스 토큰 바뀌는 경우
    // 개인 서버 사용 시 : 기존 토큰과 새로운 토큰 비교 후 변경된 경우에만 업로드
    // 파이어베이스 사용 시 : 토큰 발행 시 자동으로 파이어베이스 업로드, 변경또한 동일
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
                
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("디바이스 토큰 확인 \(deviceTokenString)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print(#function, #line, "Path : # 메서드 실행 순서 확인 ")
        wasInBackground = true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print(#function, #line, "Path : # 메서드 실행 순서 확인 ")
        guard wasInBackground else { return }
        checkNotifyPermission()
        updateNotifyCount()
        // 화면진입 노티 발송하기 (홈화면인 상태에서 화면이 백그라운드에 있는 경우에 다시 앱으로 진입했을 때를 인지하기 위해)
    }
    
    private func updateNotifyCount() {
        let badgeCount = UIApplication.shared.applicationIconBadgeNumber
        UserInfoStorage.shared.updateNotifyCount(badgeCount)
    }
    
    private func checkNotifyPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { setting in
            guard setting.authorizationStatus == .authorized else { return }
            self.registerForPushNotifications()
        }
    }
    
    func registerForPushNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

extension AppDelegate {
    private func registerServices() {
        registerFirebase()
        registerKakaoKey()
        registerNaverMap()
    }
    
    private func registerKakaoKey() {
        let kakaoKey = AppConfiguration.kakaoKey
        KakaoSDK.initSDK(appKey: kakaoKey)
    }
    
    private func registerFirebase() {
        FirebaseApp.configure()
    }
    
    private func registerNaverMap() {
        let naverId = AppConfiguration.naverID
        NMFAuthManager.shared().clientId = naverId
    }
}
//7d78e02635931ea890ac5f8c205d7fe9eb04f57749cf1a380ade9d3f7aa5ff57
// MARK: - Realm Migration
extension AppDelegate {
    
    /// Realm 마이그레이션
    func configureRealmMigration() {
        
        let newSchemaVersion: UInt64 = 2
        
        let config = Realm.Configuration(
            schemaVersion: newSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                self.migrateToV2(migration: migration, from: oldSchemaVersion)
            })
        Realm.Configuration.defaultConfiguration = config
        
        _ = try! Realm()
    }
    
    /// Realm 마이그레이션 버전 2
    private func migrateToV2(migration: Migration, from oldSchemaVersion: UInt64) {
        guard oldSchemaVersion < 2 else { return }
        migration.enumerateObjects(ofType: UserInfoEntity.className()) { oldObject, newObject in
            newObject?["notifyCount"] = 0
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function, #line, "Path : # 메서드 실행 순서 확인 ")
        let url = response.notification.request.content.userInfo
        guard let destination: NotificationDestination = .init(userInfo: url) else { return }
        appFlowCoordinator?.handleNotificationTap(destination: destination)
    }
}

//,
//   let badge = apsArray["badge"],
//   let sound = apsArray["sound"],
//   let alert = apsArray["alert"] as? [String:String],
//   let body = alert["body"],
//   let title = alert["title"]

//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    
//    let appDIContainer = AppDIContainer()
//    var appFlowCoordinator: AppFlowCoordinator?
//    
//    var window: UIWindow?
//    
//    var wasInBackground: Bool = false
//    
//    // 앱이 실행중이지 않다면(메모리에 없다면)
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        reqeustRemoteNotifications()
//        AppAppearance.setupAppearance()
//        
//        let window = UIWindow(windowScene: windowScene)
//        let navigationController = UINavigationController()
//
//        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController,
//                                                appDIContainer: appDIContainer)
//        
//        window.rootViewController = navigationController
//        
//        appFlowCoordinator?.start()
//        
//        self.window = window
//        self.window?.makeKeyAndVisible()
//    }
//    
//    private func reqeustRemoteNotifications() {
//        print(#function, #line)
//        UNUserNotificationCenter.current().delegate = self
//    }
//    
//    private func filterUrl(enterType: UIScene.ConnectionOptions) -> String? {
//        // Universal Link
//        if let userActivity = enterType.userActivities.first,
//           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//           let url = userActivity.webpageURL {
//            return url.absoluteString
//        }
//        
//        // Url Scheme
//        if let url = enterType.urlContexts.first?.url {
//            return url.absoluteString
//        }
//        
//        return nil
//    }
//    
//    
//    // MARK: - 앱이 메모리에 있을 때
//    
//    // Url Scheme
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        print(#function, #line, "# 29" )
//        guard let url = URLContexts.first?.url else { return }
//        if (AuthApi.isKakaoTalkLoginUrl(url)) {
//            _ = AuthController.handleOpenUrl(url: url)
//        }
//    }
//    
//    
//    
//    // Universal Link
//    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
//        print("SceneDelegate - continue userActivity")
//        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
//            return
//        }
//    }
//    
//    // 앱 접속 시 아이콘에 표시된 횟수 초기화
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
//    
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        self.wasInBackground = true
//        
//        
//    }
//
//    // Back -> Fore 인 상황
//    // Back : 알림 설정을 허용으로 변경
//    // Fore : 알림 설정을 확인한 뒤 허용인 경우 디바이스 토큰을 요청
//    // wasInBackground : 최초 접속시에도 메서드가 실행되는 것을 방지하기 위해 앱이 back에 존재하는 경우에만 요청
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        guard wasInBackground else { return }
//        
//        let center = UNUserNotificationCenter.current()
//        
//        center.getNotificationSettings { setting in
//            guard setting.authorizationStatus == .authorized else { return }
//            self.registerForPushNotifications()
//        }
//    }
//    
//    func registerForPushNotifications() {
//        DispatchQueue.main.async {
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//    }
//}
//
//extension SceneDelegate: UNUserNotificationCenterDelegate {
//
//    /// Foreground(앱 실행)중 알림 수신
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.sound, .banner, .badge])
//    }
//    
//    
//    /*
//     https://ios-development.tistory.com/264
//     알림을 클릭한 경우
//     해야하는 것
//     서버 : badge (미확인 한 알림을 확인하여 앱 아이콘에 표시)
//     앱
//     - 앱 내에서 알림표시에 숫자 업데이트
//     - 알림 클릭 시 앱 아이콘 숫자 초기화, 앱 내 알림 숫자 초기화, 서버로 badge 초기화된 횟수 전송
//     */
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let url = response.notification.request.content.userInfo
//
////        if let apsArray = url["aps"] as? [String:Any],
////           let alert = apsArray["alert"] as? [String:String],
////           let body = alert["body"],
////           let title = alert["title"] {
////
////        }
////
////        let urlString = url.reduce("Push Url") { partialResult, apsValue in
////            partialResult + "\n" + "Key : \(apsValue.key)" + "\n" + "Value : \(apsValue.value)"
////        }
//    }
//}

