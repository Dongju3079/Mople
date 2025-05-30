//
//  TitleButton.swift
//  Mople
//
//  Created by CatSlave on 11/20/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LabeledButton: UIView {
    
    fileprivate let defaultText: String?
    
    enum ViewMode {
        case left
        case right
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = .gray01
        return label
    }()
    
    private(set) lazy var button: BaseButton = {
        let btn = BaseButton()
        btn.setButtonAlignment(.left)
        btn.setBgColor(normalColor: .bgInput,
                       disabledColor: .inputDisable)
        btn.setRadius(8)
        btn.setLayoutMargins()
        return btn
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, button])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(title: String,
         inputText: String? = nil,
         icon: UIImage? = nil) {
        defaultText = inputText
        super.init(frame: .zero)
        setTitle(title)
        setText(inputText)
        setIconImage(icon)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        
        button.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}


// MARK: - 텍스트 설정
extension LabeledButton {
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    /// 텍스트 필드 플레이스 홀더 설정
    private func setText(_ text: String?) {
        button.setTitle(text: text,
                        font: FontStyle.Body1.regular,
                        normalColor: .gray05)
    }
    
    fileprivate func setSelectedTextText(_ text: String?) {
        button.setTitle(text: text,
                        font: FontStyle.Body1.regular,
                        normalColor: .gray02)
    }
    
    private func setIconImage(_ image: UIImage?) {
        guard let image else { return }
        button.setImage(image: image, imagePlacement: .leading, contentPadding: 16)
    }
}

extension Reactive where Base: LabeledButton {
    var selectedText: Binder<String?> {
        return Binder(self.base) { button, text in
            button.setSelectedTextText(text ?? button.defaultText)
        }
    }
    
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { button, enabled in
            button.button.isEnabled = enabled
        }
    }
}

