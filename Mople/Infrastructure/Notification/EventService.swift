//
//  NotificationService.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//
import UIKit
import RxSwift

// MARK: - 아이템 타입
typealias MeetPayload = EventService.Payload<Meet>
typealias PlanPayload = EventService.Payload<Plan>
typealias ReviewPayload = EventService.Payload<Review>

final class EventService {
    
    static let shared = EventService()
    private init() {}
    
    enum Payload<T> {
        case created(T)
        case updated(T)
        case deleted(id: Int)
        
        var notiName: Notification.Name {
            switch T.self {
            case is Meet.Type: return .meet
            case is Plan.Type: return .plan
            case is Review.Type: return .review
            default: return .init("Default")
            }
        }
    }
    
    private let reloadDayKey = "reloadDay"
    private let payloadKey = "payload"
    private let senderKey = "sender"
    
    
    // MARK: - Void
    func post(name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func receiveObservable(name: Notification.Name) -> Observable<Void> {
        return NotificationCenter.default.rx.notification(name)
            .map { _ in }
    }
    
    // MARK: - New Day Post
    func postReloadDay(on reloadDay: Date) {
        NotificationCenter.default.post(name: .reloadDay,
                                        object: nil,
                                        userInfo: [reloadDayKey: reloadDay])
    }
    
    func addReloadObservable() -> Observable<Date> {
        return NotificationCenter.default.rx.notification(.reloadDay, object: nil)
            .share(replay: 1)
            .compactMap { [weak self] in
                guard let self,
                      let reloadDay = $0.userInfo?[self.reloadDayKey] as? Date else { return nil }
                return reloadDay
            }
    }
    
    
    // MARK: - With Item
    func postItem<T>(_ payload: Payload<T>, from sender: Any) {
        NotificationCenter.default.post(name: payload.notiName,
                                        object: nil,
                                        userInfo: [payloadKey:payload,
                                                    senderKey: String(describing: sender)])
    }
    
    func addMeetObservable() -> Observable<MeetPayload> {
        return makeObservable(name: .meet)
    }

    func addPlanObservable() -> Observable<PlanPayload> {
        return makeObservable(name: .plan)
    }
    
    func addReviewObservable() -> Observable<ReviewPayload> {
        return makeObservable(name: .review)
    }
    
    private func makeObservable<T>(name: Notification.Name) -> Observable<T> {
        return NotificationCenter.default.rx.notification(name, object: nil)
            .share(replay: 1)
            .compactMap { [weak self] in
                guard let self,
                      let sender = $0.userInfo?[self.senderKey] as? String,
                      let payload = $0.userInfo?[self.payloadKey] as? T else { return nil }
                self.log(from: sender, payload: payload)
                return payload
            }
    }
    
    // MARK: - Log
    private func log(from sender: String, payload: Any) {
        printIfDebug("Event: sender[\(sender)] payload[\(payload)]")
    }
}

extension Notification.Name {
    static let meet = Notification.Name(String(describing: Meet.self))
    static let plan = Notification.Name(String(describing: Plan.self))
    static let review = Notification.Name(String(describing: Review.self))
    static let postReview = Notification.Name("postReview")
    static let reloadDay = Notification.Name("reloadDay")
    static let sessionExpired = Notification.Name("sessionExpired")
}
