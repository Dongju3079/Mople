//
//  PastPlanTableViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import UIKit

struct MeetReviewViewModel {
    let title: String?
    let date: Date?
    let participantCount: Int
    let imagePath: String?
    let imageCount: Int
    let isCreator: Bool
    
    var dateString: String? {
        return DateManager.toString(date: date, format: .dot)
    }
    
    var participantCountString: String {
        return L10n.participantCount(participantCount)
    }
}

extension MeetReviewViewModel {
    init(review: Review) {
        self.title = review.name
        self.date = review.date
        self.participantCount = review.participantsCount
        self.imagePath = review.images.first?.path
        self.imageCount = review.images.count
        self.isCreator = review.isCreator
    }
}
