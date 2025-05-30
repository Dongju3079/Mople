//
//  ErrorHandlingService.swift
//  Mople
//
//  Created by CatSlave on 3/25/25.
//

import Foundation

final class DefaultErrorHandlingService {
    
    private let alertManager = AlertManager.shared
    private var isShowAlert: Bool = false
    
    func handleError(_ err: DataRequestError) {
        guard isShowAlert == false else { return }
        isShowAlert = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch err {
            case .expiredToken:
                handleTokenExpired(err: err)
            default:
                showDefaultAlert(with: err)
            }
        }
    }
    
    private func showDefaultAlert(with err: DataRequestError) {
        guard let title = err.info else { return }
        alertManager.showWarningAlert(title: title,
                                      subTitle: err.subInfo,
                                      defaultAction: .init(completion: { [weak self] in
            self?.isShowAlert = false
        }))
    }
    
    private func handleTokenExpired(err: DataRequestError) {
        guard case .expiredToken = err,
              let title = err.info,
              let subTitle = err.subInfo else { return }
        
        alertManager.showWarningAlert(title: title,
                                      subTitle: subTitle,
                                      defaultAction: .init(completion: {
            self.isShowAlert = false
            NotificationManager.shared.post(name: .sessionExpired)
        }))
    
    }
}
