//
//  NotifyViewController.swift
//  Group
//
//  Created by CatSlave on 10/24/24.
//

import UIKit
import RxSwift

final class NotifyViewController: BaseViewController {
    
    var disposeBag = DisposeBag()
    
    private lazy var leftButtonObserver = addLeftButton(setImage: .arrowBack)

    init() {
        super.init(title: "알림 관리 뷰")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    // MARK: - Binding
    func bind() {
        leftButtonObserver
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}