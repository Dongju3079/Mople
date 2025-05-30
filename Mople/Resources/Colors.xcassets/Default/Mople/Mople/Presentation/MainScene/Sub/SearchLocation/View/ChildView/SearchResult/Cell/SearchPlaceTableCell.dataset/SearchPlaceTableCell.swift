//
//  SearchTableViewCell.swift
//  Mople
//
//  Created by CatSlave on 12/25/24.
//

import UIKit
import RxSwift
import SnapKit

final class SearchPlaceTableCell: UITableViewCell {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Closure
    public var deleteButtonTapped: (() -> Void)?
        
    // MARK: - UI Components
    private let placeIcon: UIImageView = {
        let view = UIImageView()
        view.image = .location
        view.contentMode = .scaleAspectFill
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.medium
        label.textColor = .gray01
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.regular
        label.textColor = .gray05
        label.numberOfLines = 2
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(.whiteClose, for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private lazy var addressStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [addressStackView, deleteButton])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        sv.setContentHuggingPriority(.init(1), for: .horizontal)
        sv.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [placeIcon, subStackView])
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .top
        sv.distribution = .fill
        return sv
    }()
     
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Highlight
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.contentView.backgroundColor = highlighted ? .bgPrimary : .defaultWhite
    }

    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Configure
    public func configure(with viewModel: SearchPlaceViewModel) {
        self.titleLabel.text = viewModel.title
        self.addressLabel.text = viewModel.address
    }
    
    public func shouldShowButton(isEnabled: Bool) {
        self.deleteButton.isHidden = !isEnabled
    }
    
    // MARK: - Action
    private func setAction() {
        self.deleteButton.rx.controlEvent(.touchUpInside)
            .asDriver()
            .drive(with: self, onNext: { cell, _ in
                cell.deleteButtonTapped?()
            })
            .disposed(by: disposeBag)
    }
}

