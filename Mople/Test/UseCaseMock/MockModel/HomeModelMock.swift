//
//  HomeModelMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

extension HomeData {
    static func mock() -> Self {
        return .init(plans: Plan.recentMock(), meets: [MeetSummary.mock(id: 1)])
    }
}
