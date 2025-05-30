//
//  GroupCreateViewController.swift
//  Group
//
//  Created by CatSlave on 11/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CreateMeetViewController: TitleNaviViewController,
                                      View,
                                      TransformKeyboardResponsive,
                                      DismissTansitionControllabel {
    
    // MARK: - Reactor
    typealias Reactor = CreateMeetViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let resetImage: PublishSubject<Void> = .init()
    private let showImagePicker: PublishSubject<Void> = .init()
    
    // MARK: - Transition
    var dismissTransition: AppTransition = .init(type: .dismiss)
    
    // MARK: - Variables
    private var hasImage: Bool = false
    private let isEditMode: Bool
    
    // MARK: - Handle KeyboardEvent
    var keyboardHeight: CGFloat?
    var keyboardHeightDiff: CGFloat?
    var overlapOffsetY: CGFloat? 
    var adjustableView: UIView { self.mainStackView }
    var floatingView: UIView { self.completionButton }
    var floatingViewBottom: Constraint?
   
    // MARK: - Gesture
    private let imageTapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let imageContainerView = UIView()
    
    private let thumnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .defaultMeet
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private let imageEditIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .editCircle
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let textFieldView: LabeledTextField = {
        let textField = LabeledTextField(title: L10n.Createmeet.input,
                                         placeholder: L10n.Createmeet.inputPlaceholder,
                                         maxTextCount: 30)
        return textField
    }()
    
    private let completionButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Title3.semiBold,
                     normalColor: .defaultWhite)
        btn.setBgColor(normalColor: .appPrimary,
                       disabledColor: .disablePrimary)
        btn.setRadius(8)
        return btn
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, textFieldView])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         isFlow: Bool,
         isEdit: Bool,
         reactor: CreateMeetViewReactor) {
        self.isEditMode = isEdit
        super.init(screenName: screenName,
                   title: title)
        self.reactor = reactor
        configureTransition(isNeed: !isFlow)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardEvent()
        setImageGestrue()
        setupTapKeyboardDismiss()
    }
    
    // MARK: - Transition
    private func configureTransition(isNeed: Bool) {
        guard isNeed else { return }
        setupTransition()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        setNaviItem()
        setCompleteTitle()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .defaultWhite
        self.view.addSubview(mainStackView)
        self.view.addSubview(completionButton)
        self.imageContainerView.addSubview(thumnailView)
        self.imageContainerView.addSubview(imageEditIcon)

        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(completionButton.snp.top)
        }
    
        imageContainerView.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
        
        thumnailView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
        
        imageEditIcon.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(thumnailView).offset(6)
            make.size.equalTo(24)
        }
        
        completionButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(56)
            floatingViewBottom = make.bottom.equalToSuperview()
                .inset(UIScreen.getDefaultBottomPadding()).constraint
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    private func setCompleteTitle() {
        let title = isEditMode ? L10n.save : L10n.create
        completionButton.title = title
    }
}

// MARK: - Gesture Setup
extension CreateMeetViewController {
    private func setImageGestrue() {
        self.thumnailView.addGestureRecognizer(imageTapGesture)
        
        imageTapGesture.rx.event
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.showPhotos()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension CreateMeetViewController {

    func bind(reactor: CreateMeetViewReactor) {
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
        naviBar.leftItemEvent
            .map { Reactor.Action.endView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        textFieldView.textField.rx.editText
            .compactMap({ $0 })
            .map { Reactor.Action.setNickname($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completionButton.rx.controlEvent(.touchUpInside)
            .do(onNext: { [weak self]_ in
                self?.view.endEditing(true)
            })
            .map { Reactor.Action.createMeet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        showImagePicker
            .map { Reactor.Action.showImagePicker}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resetImage
            .map { Reactor.Action.resetImage}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$image)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, image in
                vc.setImage(image)
                vc.setHasImageState(image)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$canComplete)
            .asDriver(onErrorJustReturn: false)
            .drive(completionButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$previousMeet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, meet in
                vc.setPreviousMeet(meet)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoading in
                vc.rx.isLoading.onNext(isLoading)
            })
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
    private func handleError(_ err: CreateMeetError) {
        switch err {
        case .unknown:
            alertManager.showDefatulErrorMessage()
        case .failSelectPhoto(let compressionPhotoError):
            alertManager.showDefaultAlert(title: compressionPhotoError.info,
                                   subTitle: compressionPhotoError.subInfo)
        }
    }
}

// MARK: - 이미지 선택
extension CreateMeetViewController {
    private func showPhotos() {
        let defaultPhotoAction = alertManager.makeAction(title: L10n.Photo.defaultImage,
                                                         completion: setDefaultImage)
        let selectPhotoAction = alertManager.makeAction(title: L10n.Photo.selectImage,
                                                        completion: presentPhotos)
        
        if hasImage {
            alertManager.showActionSheet(actions: [selectPhotoAction, defaultPhotoAction])
        } else {
            alertManager.showActionSheet(actions: [selectPhotoAction])
        }
    }
    
    private func presentPhotos() {
        showImagePicker.onNext(())
    }
    
    private func setDefaultImage() {
        resetImage.onNext(())
    }
    
    private func setImage(_ image: UIImage?) {
        thumnailView.image = image ?? .defaultMeet
    }
    
    private func setHasImageState(_ image: Any?) {
        hasImage = image != nil
    }
}

// MARK: - 모임 프로필 수정
extension CreateMeetViewController {
    private func setPreviousMeet(_ meet: Meet) {
        textFieldView.text = meet.meetSummary?.name
        thumnailView.kfSetimage(meet.meetSummary?.imagePath,
                                defaultImageType: .meet)
        hasImage = thumnailView.image != nil
    }
}

// MARK: - 키보드
extension CreateMeetViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
