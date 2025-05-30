//
//  Kingfisher+LoadImage.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    enum DefaultImageType {
        case meet
        case user
        case weather
        case history
        
        
        var image: UIImage {
            switch self {
            case .meet:
                    .defaultMeet
            case .user:
                    .defaultUser
            case .weather:
                    .weather
            case .history:
                    .defaultMeet
            }
        }
    }
    
    @discardableResult
    func kfSetimage(_ path: String?,
                    defaultImageType: DefaultImageType) -> DownloadTask? {
        guard let path = path,
              let url = URL(string: path) else {
            self.image = defaultImageType.image
            return nil
        }
        
        self.kf.indicatorType = .activity
        
        return self.kf.setImage(
            with: url,
            placeholder: defaultImageType.image,
            options: [.transition(.fade(0.2))]
        )
    }
}

