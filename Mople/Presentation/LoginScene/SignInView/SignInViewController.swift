//
//  LoginViewController.swift
//  Group
//
//  Created by CatSlave on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import ReactorKit
import AuthenticationServices

final class SignInViewController: UIViewController, View {
    
    typealias Reactor = SignInViewReactor
    
    // MARK: - Manager
    private let alertManager = AlertManager.shared
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleContainerView = UIView()
    
    private let appImageView: UIImageView = {
        let view = UIImageView()
        view.image = .launchScreenIcon
        view.contentMode = .center
        return view
    }()

    private let subTitle: UILabel = {
        let label = UILabel()
        label.text = TextStyle.App.subTitle
        label.font = FontStyle.Title3.medium
        label.textColor = ColorStyle.Gray._03
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [appImageView, subTitle])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        sv.setContentHuggingPriority(.defaultLow, for: .vertical)
        return sv
    }()
    
    private let kakaoLoginButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Login.kakao,
                        font: FontStyle.Title3.semiBold,
                        normalColor: ColorStyle.Gray._01)
        
        btn.setImage(image: .kakao,
                        imagePlacement: .leading,
                        contentPadding: 8)
        btn.setBgColor(normalColor: ColorStyle.Default.yellow)
        btn.setRadius(8)
        return btn
    }()
    
    private let appleLoginButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Login.apple,
                        font: FontStyle.Title3.semiBold,
                        normalColor: ColorStyle.Default.white)
        
        btn.setImage(image: .apple,
                        imagePlacement: .leading,
                        contentPadding: 8)
        btn.setBgColor(normalColor: ColorStyle.Default.black)
        btn.setRadius(8)
        return btn
    }()
    
    private lazy var loginStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [kakaoLoginButton, appleLoginButton])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleContainerView, loginStackView])
        sv.axis = .vertical
        sv.spacing = 0
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - Indicator
    fileprivate let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = 1
        return indicator
    }()
    
    // MARK: - LifeCycle
    init(reactor: SignInViewReactor) {
        print(#function, #line, "LifeCycle Test SignIn View Created" )
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SignIn View Deinit" )
    }
    

    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
    }
        
    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainStackView)
        self.view.addSubview(indicator)
        self.titleContainerView.addSubview(titleStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                .inset(UIScreen.getAdditionalBottomInset())
        }
        
        titleStackView.snp.makeConstraints { make in
            make.center.equalTo(titleContainerView)
            make.horizontalEdges.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview() 
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        indicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Binding
    func bind(reactor: SignInViewReactor) {
        self.appleLoginButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.appleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.kakaoLoginButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.kakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$message)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, message in
                vc.alertManager.showAlert(title: "로그인 에러", message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

#warning("일반 ViewController를 사용시 중복 구현, 보완필요")
extension Reactive where Base: SignInViewController {
    var isLoading: Binder<Bool> {
        return Binder(self.base) { vc, isLoading in
            vc.indicator.rx.isAnimating.onNext(isLoading)
            vc.view.isUserInteractionEnabled = !isLoading
        }
    }
}
