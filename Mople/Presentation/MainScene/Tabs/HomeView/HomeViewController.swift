//
//  HomeViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import ReactorKit
import Kingfisher

final class HomeViewController: UIViewController, View {
 
    typealias Reactor = HomeViewReactor
    
    var disposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextStyle.App.title
        label.font = FontStyle.Title.black
        label.textColor = ColorStyle.App.primary
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let notifyButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.bell, for: .normal)
        return btn
    }()
    
    private lazy var topStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, notifyButton])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        return sv
    }()
    
    private let recentPlanContainerView = UIView()
    
    private lazy var resentPlanCollectionView = RecentPlanCollectionViewController(reactor: reactor!)
    
    #warning("configure")
    private let emptyDataView: UILabel = {
        let label = UILabel()
        label.text = "빈 화면"
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private let makeGroupButton: CardButton = {
        let btn = CardButton()
        btn.setTitle(text: TextStyle.Home.createGroup)
        btn.setImage(image: .makeGroup)
        return btn
    }()
    
    private let makeScheduleButton: CardButton = {
        let btn = CardButton()
        btn.setTitle(text: TextStyle.Home.createSchedule)
        btn.setImage(image: .makeSchedule)
        return btn
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [makeGroupButton, makeScheduleButton])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 8, right: 20)
        return sv
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [topStackView,
                                                recentPlanContainerView,
                                                buttonStackView,
                                                spacerView])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    
    init(reactor: HomeViewReactor) {
        print(#function, #line, "LifeCycle Test HomeView Created" )

        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test HomeView Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        super.viewDidLoad()
        setupUI()
        addScheduleListCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function, #line)
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.BG.primary
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(mainStackView)
        self.recentPlanContainerView.addSubview(emptyDataView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        recentPlanContainerView.snp.makeConstraints { make in
            make.height.equalTo(270)
        }
        
        notifyButton.snp.makeConstraints { make in
            make.width.height.greaterThanOrEqualTo(40)
        }
        
        emptyDataView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func addScheduleListCollectionView() {
        add(child: resentPlanCollectionView, container: recentPlanContainerView)
    }
    
    func bind(reactor: HomeViewReactor) {
        rx.viewDidLoad
            .map { _ in Reactor.Action.checkNotificationPermission }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.makeGroupButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.createGroup }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.makeScheduleButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.createPlan }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$plans)
                .asDriver(onErrorJustReturn: [])
                .drive(with: self, onNext: { vc, schedules in
                    vc.emptyDataView.isHidden = !schedules.isEmpty
                    vc.recentPlanContainerView.isHidden = schedules.isEmpty
                })
                .disposed(by: disposeBag)
    }
}


