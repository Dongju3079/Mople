//
//  PlaceDetailViewController.swift
//  Mople
//
//  Created by CatSlave on 2/3/25.
//

import UIKit
import RxSwift
import ReactorKit

final class PlaceDetailViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = PlaceDetailViewReactor
    private var placeDetailReactor: PlaceDetailViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var placeInfo: PlaceInfo?
    
    // MARK: - UI Components
    private let mapView: MapInfoView = {
        let view = MapInfoView()
        view.setSelectButton(text: "약속장소 길찾기",
                             textFont: FontStyle.Title3.semiBold,
                             textColor: ColorStyle.Gray._01,
                             backColor: ColorStyle.App.tertiary)
        return view
    }()

    // MARK: - LifeCycle
    init(title: String,
         reactor: PlaceDetailViewReactor) {
        super.init(title: title)
        self.placeDetailReactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setNavi()
    }
    
    private func setLayout() {
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left, image: .backArrow)
    }
}

// MARK: - Reactor Setup
extension PlaceDetailViewController {
    private func setReactor() {
        reactor = placeDetailReactor
    }
    
    func bind(reactor: PlaceDetailViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        naviBar.leftItemEvent
            .map({ Reactor.Action.endProcess })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mapView.rx.selected
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.presentSelectMapView()
            })
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        reactor.pulse(\.$placeInfo)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, placeInfo in
                vc.mapView.setConfigure(.init(place: placeInfo))
                vc.placeInfo = placeInfo
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, err in
                vc.alertManager.showDefatulErrorMessage()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Select Map Service
extension PlaceDetailViewController {
    private func presentSelectMapView() {
        let naverMapAction: DefaultSheetAction = .init(text: "네이버 지도",
                                                       image: .naverMap,
                                                       completion: { [weak self] in
            guard let self,
                  let title = placeInfo?.title,
                  let placeLat =  placeInfo?.location?.latitude,
                  let placeLon = placeInfo?.location?.longitude,
                  let urlTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
                                                       
            guard let bundleId = Bundle.main.bundleIdentifier else { return }
            guard let url = URL(string: "nmap://route?dlat=\(placeLat)&dlng=\(placeLon)&dname=\(urlTitle)&appname=\(bundleId)"),
                  let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8") else { return }
            
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            } else {
              UIApplication.shared.open(appStoreURL)
            }
        })
        
        let kakaoMapAction: DefaultSheetAction = .init(text: "카카오맵",
                                                       image: .kakaoMap,
                                                       completion: { [weak self] in
            guard let self,
                  let title = placeInfo?.title,
                  let placeLat =  placeInfo?.location?.latitude,
                  let placeLon = placeInfo?.location?.longitude else { return }
            
            guard let url = URL(string: "kakaomap://look?p=\(placeLat),\(placeLon)"),
                  let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id304608425") else { return }
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            } else {
                UIApplication.shared.open(appStoreURL)
            }
        })
        
        sheetManager.showSheet(actions: [naverMapAction, kakaoMapAction])
    }
}


