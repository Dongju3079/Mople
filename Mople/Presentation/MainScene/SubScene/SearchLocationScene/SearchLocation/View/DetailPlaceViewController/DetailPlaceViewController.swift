//
//  DetailPlaceViewController.swift
//  Mople
//
//  Created by CatSlave on 1/2/25.
//

import UIKit
import NMapsMap
import ReactorKit
import RxSwift

final class DetailPlaceViewController: UIViewController, View {
    
    typealias Reactor = SearchPlaceReactor
    
    var disposeBag = DisposeBag()
    
    private let place: PlaceInfo
    
    private lazy var mapView = DefaultMapView(place: place)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    init(reactor: SearchPlaceReactor?,
         place: PlaceInfo) {
        print(#function, #line, "LifeCycle Test DetailPlaceViewController Created" )
        self.place = place
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DetailPlaceViewController Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func bind(reactor: SearchPlaceReactor) {
        self.mapView.selectedButton.rx.controlEvent(.touchUpInside)
            .compactMap { [weak self] in
                guard let self else { return nil }
                return Reactor.Action.selectedPlace(self.place)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}


