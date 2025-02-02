//
//  PlanDetailViewController.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

final class PlanDetailViewController: TitleNaviViewController, View, ScrollKeyboardResponsive {
    
    typealias Reactor = PlanDetailViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Handle KeyboardEvent
    var keyboardHeight: CGFloat?
    var keyboardHeightDiff: CGFloat?
    var scrollView: UIScrollView? { commentListView?.tableView }
    var scrollViewHeight: CGFloat?
    var floatingView: UIView { chatingTextFieldView }
    var floatingViewBottom: Constraint?
    var startOffsetY: CGFloat = .zero
    var remainingOffsetY: CGFloat = .zero
    
    // MARK: - Observable
    private var loadingObserver: PublishSubject<Bool> = .init()
    
    // MARK: - UI Components
    private let planInfoView = PlanInfoView()
    
    private(set) var commentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.Default.white
        return view
    }()
    
    public var commentListView: CommentListViewController?
    
    private let chatingTextFieldView: ChatingTextFieldView = {
        let chatingView = ChatingTextFieldView()
        chatingView.backgroundColor = ColorStyle.Default.white
        return chatingView
    }()

    init(title: String?,
         reactor: PlanDetailViewReactor) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentListView?.setHeaderView(planInfoView)
        initalSetup()
        setAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function, #line, "Path : # view will ")
        super.viewWillAppear(animated)
        setupKeyboardEvent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print(#function, #line, "Path : # view disappear ")
        super.viewDidDisappear(animated)
        removeKeyboardObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewHeight()
    }
    
    private func initalSetup() {
        setLayout()
        setNavi()
        setupKeyboardDismissGestrue()
    }
    
    private func setLayout() {
        self.view.addSubview(commentContainer)
        self.view.addSubview(chatingTextFieldView)
        
        commentContainer.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
        }

        chatingTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(commentContainer.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            floatingViewBottom = make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                .inset(UIScreen.getDefatulBottomInset()).constraint
        }
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left, image: .backArrow)
        self.naviBar.setBarItem(type: .right, image: .blackMenu)
    }

    func bind(reactor: PlanDetailViewReactor) {
        inputBind(reactor: reactor)
        outputBind(reactor: reactor)
        handleCommentCommand(reactor: reactor)
        handleParentChildLoading(reactor: reactor)
    }
    
    private func setAction() {
        self.naviBar.leftItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Helper
extension PlanDetailViewController {
    private func updateScrollViewHeight() {
        guard scrollViewHeight == nil else { return }
        self.scrollViewHeight = commentContainer.bounds.height
    }
}

// MARK: - Handle Reactor
extension PlanDetailViewController {
    private func inputBind(reactor: Reactor) {
//        self.chatingTextFieldView.rx.isEditMode
//            .filter { [weak self] in
//                $0 == false &&
//            })
//            .disposed(by: disposeBag)
    }
    
    private func outputBind(reactor: Reactor) {
        reactor.pulse(\.$planInfo)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, viewModel in
                vc.planInfoView.configure(with: viewModel)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$startOffsetY)
            .asDriver(onErrorJustReturn: .zero)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, offsetY in
                vc.setStartOffsetY(offsetY)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleCommentCommand(reactor: Reactor) {
        let keyboardSended = chatingTextFieldView.rx.keyboardSendButtonTapped
        let buttonSended = chatingTextFieldView.rx.sendButtonTapped
        
        [keyboardSended, buttonSended].forEach {
            $0.map { comment in
                Reactor.Action.writeComment(comment)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        }
        
        reactor.pulse(\.$editComment)
            .skip(1)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, comment in
                vc.setEditComment(comment)
            })
            .disposed(by: disposeBag)
    }
    
    private func setEditComment(_ comment: String?) {
        let hasComment = comment != nil
        chatingTextFieldView.rx.text.onNext(comment)
        chatingTextFieldView.rx.isResign.onNext(!hasComment)
    }
    
    private func handleParentChildLoading(reactor: Reactor) {
        Observable.merge(reactor.pulse(\.$isLoading),
                         reactor.pulse(\.$isCommentLoading))
        .skip(1)
        .asDriver(onErrorJustReturn: false)
        .filter { [weak self] isLoad in
            self?.indicator.isAnimating == false && isLoad
        }
        .map { _ in true }
        .drive(self.rx.isLoading)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(reactor.pulse(\.$isLoading),
                                 reactor.pulse(\.$isCommentLoading))
        .skip(1)
        .filter { isPlanInfoLoaded, isCommentLoaded  in
            !isPlanInfoLoaded && !isCommentLoaded
        }
        .map { _ in false }
        .asDriver(onErrorJustReturn: false)
        .drive(with: self, onNext: { vc, _ in
            vc.rx.isLoading.onNext(false)
            vc.chatingTextFieldView.rx.text.onNext(nil)
        })
        .disposed(by: disposeBag)
    }
}

extension PlanDetailViewController {
    private func setStartOffsetY(_ offsetY: CGFloat) {
        guard let keyboardHeight else { return }
        self.startOffsetY = offsetY - keyboardHeight
    }
}

extension PlanDetailViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    private func setupKeyboardDismissGestrue() {
        setupTapKeyboardDismiss()
    }
    
    func dismissCompletion() {
        print(#function, #line)
        guard self.reactor?.currentState.editComment != nil else { return }
        self.reactor?.action.onNext(.notifyCancleEditComment)
        self.chatingTextFieldView.rx.text.onNext(nil)
    }
}


