//
//  DefaultCommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

final class DefaultCommentRepo:BaseRepositories, CommentRepo {
    func fetchCommentList(postId: Int) -> Single<[CommentResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchCommentList(id: postId)
        }
    }
    
    func createComment(postId: Int, comment: String) -> Single<[CommentResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.createComment(id: postId,
                                           comment: comment)
        }
    }
    
    func deleteComment(commentId: Int) -> Single<Void> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.deleteComment(commentId: commentId)
        }
    }
    
    func editComment(postId: Int, commentId: Int, comment: String) -> Single<[CommentResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.editComment(postId: postId,
                                         commentId: commentId,
                                         comment: comment)
        }
    }
}
