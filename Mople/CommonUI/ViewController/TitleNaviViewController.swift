//
//  BaseViewController.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TitleNaviViewController: DefaultViewController {

    // MARK: - Variables
    public var titleViewBottom: ConstraintItem {
        return naviBar.snp.bottom
    }
        
    // MARK: - UI Components
    private(set) var naviBar = TitleNaviBar()

    // MARK: - LifeCycle
    init(title: String?) {
        super.init()
        setTitle(title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialsetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func initialsetup() {
        setupUI()
        setNavigation()
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        self.view.addSubview(naviBar)

        naviBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }
    }
    
    private func setNavigation() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    private func setTitle(_ title: String?) {
        self.naviBar.setTitle(title)
    }
}

// MARK: - 네비게이션 아이템 설정
extension TitleNaviViewController {
    public func setBarItem(type: TitleNaviBar.ButtonType, image: UIImage) {
        naviBar.setBarItem(type: type, image: image)
    }
    
    public func hideBaritem(type: TitleNaviBar.ButtonType, isHidden: Bool) {
        naviBar.hideBarItem(type: type, isHidden: isHidden)
    }
}
