//
//  ProfileCreateViewController.swift
//  Group
//
//  Created by CatSlave on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import PhotosUI

class SignUpViewController: DefaultViewController, View, KeyboardDismissable {
    
    // MARK: - Reactor
    typealias Reactor = SignUpViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let resetImage: PublishSubject<Void> = .init()
    private let showAlbum: PublishSubject<Void> = .init()
    
    // MARK: - Variables
    private var hasImage: Bool = false
 
    // MARK: - UI Components
    private let mainTitle: UILabel = {
        let label = UILabel()
        label.text = L10n.CreateProfile.header
        label.font = FontStyle.Heading.bold
        label.textColor = .gray01
        label.numberOfLines = 2
        return label
    }()
    
    private let profileSetupView = ProfileSetupView(type: .create)

    // MARK: - LifeCycle
    init(screenName: ScreenName,
         signUpReactor: SignUpViewReactor) {
        super.init(screenName: screenName)
        self.reactor = signUpReactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAction()
        setupTapKeyboardDismiss()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainTitle)
        self.view.addSubview(profileSetupView)

        mainTitle.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(28)
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        profileSetupView.snp.makeConstraints { make in
            make.top.equalTo(mainTitle.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(mainTitle.snp.horizontalEdges)
            make.bottom.equalToSuperview()
                .inset(UIScreen.getDefaultBottomPadding())
        }
    }
    
    // MARK: - Action
    private func setAction() {
        profileSetupView.rx.imageViewTapped
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.showPhotos()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension SignUpViewController {
    func bind(reactor: SignUpViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }

    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        profileSetupView.rx.editName
            .compactMap({ $0 })
            .map { Reactor.Action.setNickname($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileSetupView.rx.duplicateTapped
            .map { Reactor.Action.duplicateCheck }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileSetupView.rx.completeTapped
            .map { Reactor.Action.complete }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resetImage
            .map { Reactor.Action.resetImage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        showAlbum
            .map { Reactor.Action.showImagePicker }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$creationNickname)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, name in
                vc.profileSetupView.setNickname(name)
                vc.profileSetupView.rx.isDuplicateEnable.onNext(true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$profileImage)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, image in
                vc.profileSetupView.setImage(image)
                vc.setHasImageState(image)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$canDuplicateCheck)
            .asDriver(onErrorJustReturn: false)
            .drive(self.profileSetupView.rx.isDuplicateEnable)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isValidNickname)
            .asDriver(onErrorJustReturn: false)
            .drive(self.profileSetupView.rx.isDuplicate)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Error Handling
    private func handleError(_ err: SignUpError) {
        switch err {
        case .unknown:
            alertManager.showDefatulErrorMessage()
        case let .failSelectPhoto(err):
            alertManager.showDefaultAlert(title: err.info,
                                   subTitle: err.subInfo)
        }
    }
}

// MARK: - 이미지 선택
extension SignUpViewController {
    private func showPhotos() {
        let defaultPhotoAction = alertManager.makeAction(title: L10n.Photo.defaultImage,
                                                         completion: { [weak self] in
            self?.resetImage.onNext(())
        })
        
        let selectPhotoAction = alertManager.makeAction(title: L10n.Photo.selectImage,
                                                        completion: { [weak self] in
            self?.showAlbum.onNext(())
        })
        
        if hasImage {
            alertManager.showActionSheet(actions: [selectPhotoAction, defaultPhotoAction])
        } else {
            alertManager.showActionSheet(actions: [selectPhotoAction])
        }
    }
    
    private func setHasImageState(_ image: UIImage?) {
        hasImage = image != nil
    }
}

