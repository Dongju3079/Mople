//
//  PlanDetailSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import RxSwift

protocol PostDetailSceneDependencies {
    // MARK: - 기본 뷰
    func makePlanDetailViewController(coordinator: PostDetailCoordination) -> PostDetailViewController
    
    // MARK: - 이동 뷰
    func makePlaceDetailViewController(place: PlaceInfo,
                                       coordinator: PlaceDetailCoordination) -> PlaceDetailViewController
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController
    func makePhotoBookViewController(title: String?,
                                     imagePaths: [String],
                                     defaultType: UIImageView.DefaultImageType,
                                     coordinator: NavigationCloseable) -> PhotoBookViewController
    
    func makeReviewEditViewController(review: Review,
                                      coordinator: ReviewEditViewCoordination) -> ReviewEditViewController

    // MARK: - 이동 플로우
    func makePlanEditFlowCoordiantor(plan: Plan) -> BaseCoordinator
}

final class PostDetailSceneDIContainer: BaseContainer, PostDetailSceneDependencies {
    
    private var mainReactor: PostDetailViewReactor?
    private let postType: PostType
    private let id: Int
    
    init(appNetworkService: AppNetworkService,
         commonFactory: ViewDependencies,
         type: PostType,
         id: Int) {
        self.postType = type
        self.id = id
        super.init(appNetworkService: appNetworkService,
                   commonFactory: commonFactory)
    }
    
    func makePostDetailCoordinator() -> PostDetailFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

// MARK: - Default View
extension PostDetailSceneDIContainer {
    
    // MARK: - 포스트 상세
    func makePlanDetailViewController(coordinator: PostDetailCoordination) -> PostDetailViewController {
        let screenName: ScreenName = postType == .plan ? .plan_detail : .review_detail
        let title = postType == .plan ? L10n.Postdetail.plan : L10n.Postdetail.review
        let reportUseCase = makeReportUseCase()
        return .init(screenName: screenName,
                     title: title,
                     postType: postType,
                     reactor: makePostDetailViewReactor(type: postType,
                                                        coordinator: coordinator,
                                                        reportUseCase: reportUseCase),
                     commentVC: makeCommentListViewController(reportUseCase: reportUseCase))
    }
    
    private func makePostDetailViewReactor(type: PostType,
                                           coordinator: PostDetailCoordination,
                                           reportUseCase: ReportPost) -> PostDetailViewReactor {
        let planRepo = DefaultPlanRepo(networkService: appNetworkService)
        let reviewRepo = DefaultReviewRepo(networkService: appNetworkService)
        mainReactor = PostDetailViewReactor(type: type,
                                            id: id,
                                            fetchPlanDetailUseCase: makeFetchPlanDetailUsecase(repo: planRepo),
                                            fetchReviewDetailUseCase: makeFetchReviewDetailUseCase(repo: reviewRepo),
                                            deletePlanUseCase: makeDeletePlanUseCase(repo: planRepo),
                                            deleteReviewUseCase: makeDeleteReviewUseCase(repo: reviewRepo),
                                            participationPlanUseCase: makeParticipationPlanUseCase(repo: planRepo),
                                            reportUseCase: reportUseCase,
                                            coordinator: coordinator)
        return mainReactor!
    }
    
    
    private func makeFetchPlanDetailUsecase(repo: PlanRepo) -> FetchPlanDetail {
        return FetchPlanDetailUseCase(repo: repo)
    }
    
    private func makeDeletePlanUseCase(repo: PlanRepo) -> DeletePlan {
        return DeletePlanUseCase(repo: repo)
    }
    
    private func makeParticipationPlanUseCase(repo: PlanRepo) -> ParticipationPlan {
        return ParticipationPlanUseCase(participationRepo: repo)
    }
    
    private func makeFetchReviewDetailUseCase(repo: ReviewRepo) -> FetchReviewDetail {
        return FetchReviewDetailUseCase(repo: repo)
    }
    
    private func makeDeleteReviewUseCase(repo: ReviewRepo) -> DeleteReview {
        return DeleteReviewUseCase(repo: repo)
    }

    // MARK: - 댓글뷰
    private func makeCommentListViewController(reportUseCase: ReportPost) -> CommentListViewController {
        return .init(reactor: makeCommentListViewReactor(
            reportUseCase: reportUseCase)
        )
    }
    
    private func makeCommentListViewReactor(reportUseCase: ReportPost) -> CommentListViewReactor {
        let reactor = CommentListViewReactor(fetchCommentListUseCase: makeFetchCommentListUseCase(),
                                             createCommentUseCase: makeCreateCommentUseCase(),
                                             deleteCommentUseCase: makeDeleteCommentUseCase(),
                                             editCommentUseCase: makeEditCommentUseCase(),
                                             reportUseCase: reportUseCase,
                                             delegate: mainReactor!)
        mainReactor?.commentListCommands = reactor
        return reactor
    }
    
    private func makeFetchCommentListUseCase() -> FetchCommentList {
        return FetchCommentListUseCase(repo: makeCommentRepo())
    }
    
    private func makeCreateCommentUseCase() -> CreateComment {
        return CreateCommentUseCase(repo: makeCommentRepo())
    }
    
    private func makeDeleteCommentUseCase() -> DeleteComment {
        return DeleteCommentUseCase(repo: makeCommentRepo())
    }
    
    private func makeEditCommentUseCase() -> EditComment {
        return EditCommentUseCase(repo: makeCommentRepo())
    }
    
    private func makeCommentRepo() -> CommentRepo {
        return DefaultCommentRepo(networkService: appNetworkService)
    }
    
    // MARK: - 신고 유즈케이스
    private func makeReportUseCase() -> ReportPost {
        let repo = DefaultReportRepo(networkService: appNetworkService)
        return ReportPostUseCase(repo: repo)
    }
}

// MARK: - View
extension PostDetailSceneDIContainer {
    
    // MARK: - 상세 지도
    func makePlaceDetailViewController(place: PlaceInfo,
                                       coordinator: PlaceDetailCoordination) -> PlaceDetailViewController {
        return PlaceDetailViewController(screenName: .map_detail,
                                         title: L10n.placedetail,
                                         reactor: makePlaceDetailViewReactor(place: place,
                                                                             coordinator: coordinator))
    }
    
    private func makePlaceDetailViewReactor(place: PlaceInfo, coordinator: PlaceDetailCoordination) -> PlaceDetailViewReactor {
        return PlaceDetailViewReactor(place: place,
                                  locationService: DefaultLocationService(),
                                  coordinator: coordinator)
    }
    
    // MARK: - 멤버 리스트
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController {
        return commonViewFactory.makeMemberListViewController(type: getMemberListType(),
                                                          coordinator: coordinator)
    }
    
    private func getMemberListType() -> MemberListType {
        if case .plan = postType {
            return .plan(id: id)
        } else {
            return .review(id: id)
        }
    }
    
    // MARK: - 리뷰 편집
    func makeReviewEditViewController(review: Review,
                                       coordinator: ReviewEditViewCoordination) -> ReviewEditViewController {
        let title = review.isReviewd ? L10n.Review.edit : L10n.Review.create
        return .init(screenName: .review_write,
                     title: title,
                     reactor: makePlanDetailViewReactor(review: review,
                                                        coordinator: coordinator))
    }
    
    private func makePlanDetailViewReactor(review: Review,
                                           coordinator: ReviewEditViewCoordination) -> ReviewEditViewReactor {
        let reviewRepo = DefaultReviewRepo(networkService: appNetworkService)
        let imageRepo = DefaultImageUploadRepo(networkService: appNetworkService)
        return .init(review: review,
                     fetchReview: makeFetchReviewUseCase(repo: reviewRepo),
                     deleteReviewImage: makeDeleteReviewUseCase(repo: reviewRepo),
                     imageUpload: makeReviewImageUploadUseCase(repo: imageRepo),
                     photoService: DefaultPhotoService(),
                     coordinator: coordinator)
    }
    
    private func makeFetchReviewUseCase(repo: ReviewRepo) -> FetchReviewDetail {
        return FetchReviewDetailUseCase(repo: repo)
    }
    
    private func makeDeleteReviewUseCase(repo: ReviewRepo) -> DeleteReviewImage {
        return DeleteReviewImageUseCase(repo: repo)
    }
    
    private func makeReviewImageUploadUseCase(repo: ImageUploadRepo) -> ReviewImageUpload {
        return ReviewImageUploadUseCase(repo: repo)
    }
    
    // MARK: - 포토북
    func makePhotoBookViewController(title: String?,
                                     imagePaths: [String],
                                     defaultType: UIImageView.DefaultImageType,
                                     coordinator: NavigationCloseable) -> PhotoBookViewController {
        return commonViewFactory.makePhotoViewController(title: title,
                                                         imagePath: imagePaths,
                                                         defaultImageType: defaultType,
                                                         coordinator: coordinator)
    }
}

// MARK: - Flow
extension PostDetailSceneDIContainer {
    
    // MARK: - 일정 편집
    func makePlanEditFlowCoordiantor(plan: Plan) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonViewFactory: commonViewFactory,
            type: .edit(plan))
        return planCreateDI.makePlanCreateFlowCoordinator()
    }
}

