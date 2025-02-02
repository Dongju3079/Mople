//
//  HomeResponse.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

struct RecentPlanResponse: Decodable {
    let plans: [PlanResponse]
    let meets: [MeetSummaryResponse]

}

extension RecentPlanResponse {
    func toDomain() -> RecentPlan {
        return .init(plans: plans.map({ $0.toDomain() }),
                     meets: meets.map({ $0.toDomain() }))
    }
}
