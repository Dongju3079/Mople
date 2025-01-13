//
//  ProfileEditViewController.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import PhotosUI

class ProfileEditViewController: TitleNaviViewController, View {
    typealias Reactor = ProfileEditViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Sub Reactor
    let profileSetupReactor: ProfileSetupViewReactor
    
    // MARK: - Observable
    private let completionObservable: PublishSubject<(nickname: String, image: UIImage?)> = .init()
    private let loadingObservable: PublishSubject<Bool> = .init()
    
    // MARK: - Variables
    let previousProfile: UserInfo
        
    // MARK: - UI Components
    private let profileContainerView = UIView()
    
    private lazy var profileSetupView: ProfileSetupViewController = {
        let viewController = ProfileSetupViewController(type: .edit(previousProfile: previousProfile),
                                                        reactor: profileSetupReactor,
                                                        lodingObserver: loadingObservable.asObserver(),
                                                        completionObserver: completionObservable.asObserver())
        return viewController
    }()

    // MARK: - LifeCycle
    init(profile: UserInfo,
         profileSetupReactor: ProfileSetupViewReactor,
         editProfileReactor: ProfileEditViewReactor) {
        self.previousProfile = profile
        self.profileSetupReactor = profileSetupReactor
        super.init(title: TextStyle.ProfileEdit.title)
        self.reactor = editProfileReactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAction()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        addProfileSetupView()
        setNaviItem()
    }

    private func setupLayout() {
        self.view.addSubview(profileContainerView)

        profileContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func addProfileSetupView() {
        addChild(profileSetupView)
        profileContainerView.addSubview(profileSetupView.view)
        profileSetupView.didMove(toParent: self)
        profileSetupView.view.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }

    // MARK: - Binding
    func bind(reactor: ProfileEditViewReactor) {
        loadingObservable
            .map({ Reactor.Action.setLoading(isLoad: $0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completionObservable
            .map { Reactor.Action.editProfile(name: $0.nickname, image: $0.image) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
    
    private func setupAction() {
        naviBar.leftItemEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.reactor?.action.onNext(.endView)
            })
            .disposed(by: disposeBag)
    }
}
