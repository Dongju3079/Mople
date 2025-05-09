//
//  RequsetParticipationPlan.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol ParticipationPlan {
    func execute(planId: Int,
                 isJoining: Bool) -> Single<Void>
}

final class ParticipationPlanUseCase: ParticipationPlan {
    let participationRepo: PlanRepo
    
    init(participationRepo: PlanRepo) {
        self.participationRepo = participationRepo
    }
    
    func execute(planId: Int,
                 isJoining: Bool) -> Single<Void> {
        participationRepo.participationPlan(planId: planId,
                                                   isJoining: isJoining)
    }
}
