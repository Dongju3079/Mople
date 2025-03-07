//
//  CalendarPlanViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

struct ScheduleListTableCellModel {
    let title: String?
    let meet: MeetSummary?
    let participantCount: Int?
    let weather: Weather?
    
    var participantCountString: String? {
        guard let participantCount = participantCount else { return nil }
        
        return "\(participantCount)명 참여"
    }
}

extension ScheduleListTableCellModel {
    init(plan: Plan) {
        self.title = plan.title
        self.meet = plan.meet
        self.participantCount = plan.participantCount
        self.weather = plan.weather
    }
    
    init(testPlan: MonthlyPlan) {
        self.title = testPlan.title
        self.meet = testPlan.meet
        self.participantCount = testPlan.memberCount
        self.weather = testPlan.weather
    }
}
