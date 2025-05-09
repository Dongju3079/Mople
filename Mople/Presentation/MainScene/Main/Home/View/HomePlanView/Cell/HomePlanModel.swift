//
//  HomePlanViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

struct HomePlanModel {
    let title: String?
    let meet: MeetSummary?
    let date: Date?
    let address: String?
    let addressTitle: String?
    let participantCount: Int
    let weather: Weather?
    
    var participantCountString: String {
        return "\(participantCount)명 참여"
    }
    
    var dateString: String? {
        return DateManager.toString(date: date, format: .full)
    }
    
    var fullAddress: String? {
        [address, addressTitle].compactMap { $0 }.joined(separator: " ")
    }
}

extension HomePlanModel {
    init(plan: Plan) {
        self.title = plan.title
        self.meet = plan.meet
        self.date = plan.date
        self.address = plan.address
        self.addressTitle = plan.addressTitle
        self.participantCount = plan.participantCount
        self.weather = plan.weather
    }
}

