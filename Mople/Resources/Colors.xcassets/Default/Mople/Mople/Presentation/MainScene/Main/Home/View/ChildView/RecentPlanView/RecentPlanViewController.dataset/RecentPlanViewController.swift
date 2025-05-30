//
//  ScheduleCollectionViewController.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

final class RecentPlanViewController: BaseViewController, View {
    
    // MARK: - Section
    typealias Section = SectionModel<Void, Plan>
    
    // MARK: - Reactor
    typealias Reactor = HomeViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let footerTapObserver: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let emptyPlanView: DefaultEmptyView = {
        let emptyView = DefaultEmptyView(imageSize: .init(width: 100, height: 100))
        emptyView.setTitle(text: L10n.Home.emptyPlan)
        emptyView.setImage(image: .emptyHomePlan)
        emptyView.backgroundColor = .defaultWhite
        emptyView.layer.cornerRadius = 12
        return emptyView
    }()
    
    // MARK: - LifeCycle
    init(reactor: HomeViewReactor?) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moveToLastItem()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setCollectionView()
        setLayout()
    }
    
    private func setLayout() {
        view.addSubview(collectionView)
        view.addSubview(emptyPlanView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyPlanView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    private func setCollectionView() {
        collectionView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        collectionView.register(RecentPlanCollectionCell.self, forCellWithReuseIdentifier: RecentPlanCollectionCell.reuseIdentifier)
        collectionView.register(RecentPlanFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: RecentPlanFooterView.reuseIdentifier)
    }
    
    // MARK: - DataSource
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<Section> {
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<Section>(
             configureCell: { _, collectionView, indexPath, item in
                 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentPlanCollectionCell.reuseIdentifier, for: indexPath) as! RecentPlanCollectionCell
                 cell.configure(with: .init(plan: item))
                 return cell
             },
             configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
                 guard let self else { return UICollectionReusableView() }
                 if kind == UICollectionView.elementKindSectionFooter {
                     let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecentPlanFooterView.reuseIdentifier, for: indexPath) as! RecentPlanFooterView
                     footer.setTapAction(on: self.footerTapObserver.asObserver())
                     return footer
                 } else {
                     return UICollectionReusableView()
                 }
             }
         )
        return dataSource
    }
}

// MARK: - Reactor Setup
extension RecentPlanViewController {

    func bind(reactor: HomeViewReactor) {
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
        footerTapObserver
            .map({ _ in Reactor.Action.flow(.calendar) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .map { Reactor.Action.flow(.planDetail(index: $0.item)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$plans)
            .map { [Section(model: (), items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(self.collectionView.rx.items(dataSource: configureDataSource()))
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$plans)
                .asDriver(onErrorJustReturn: [])
                .drive(with: self, onNext: { vc, schedules in
                    vc.emptyPlanView.isHidden = !schedules.isEmpty
                    vc.collectionView.isHidden = schedules.isEmpty
                })
                .disposed(by: disposeBag)
    }
}

extension RecentPlanViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionView.horizontalSnapToItem(targetContentOffset: targetContentOffset,
                                          scrollView: scrollView,
                                          velocity: velocity)
    }
}

extension RecentPlanViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fullWidth = collectionView.bounds.width - 40
        let fullHeight = collectionView.bounds.height
                
        return CGSize(width: fullWidth, height: fullHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let fullHeight = collectionView.bounds.height
        return CGSize(width: 109, height: fullHeight)
    }
    
    // 컬렉션 뷰 레이아웃 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - 컨텐츠 위치 체크
extension RecentPlanViewController {
    
    private func hasReachedBottom() -> Bool {
        guard collectionView.contentWidth != 0 else { return false }
        return collectionView.offsetMaxX == collectionView.contentWidth
    }
    
    private func moveToLastItem() {
        guard hasReachedBottom(),
              let lastItem = collectionView.indexPathsForVisibleItems.last else { return }
        
        collectionView.selectItem(at: lastItem, animated: false, scrollPosition: .centeredHorizontally)
    }
}

