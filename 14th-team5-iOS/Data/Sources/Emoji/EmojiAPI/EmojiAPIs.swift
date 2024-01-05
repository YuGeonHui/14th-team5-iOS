//
//  EmojiAPIs.swift
//  Data
//
//  Created by 마경미 on 01.01.24.
//

import Foundation

public enum EmojiAPIs: API {
    case addReactions(String)
    case removeReactions(String)
    case fetchReactions(FetchEmojiRequestDTO)
    
    var spec: APISpec {
        switch self {
        case let .addReactions(postId):
            let urlString = "\(BibbiAPI.hostApi)/posts/\(postId)/reactions"
            return APISpec(method: .post, url: urlString)
        case let .removeReactions(postId):
            let urlString = "\(BibbiAPI.hostApi)/posts/\(postId)/reactions"
            return APISpec(method: .delete, url: urlString)
        case let .fetchReactions(postId):
            let urlString = "\(BibbiAPI.hostApi)/posts/\(postId.postId)/reactions/member"
            return APISpec(method: .get, url: urlString)
        }
    }
}
