//
//  SearchFamilyUseCase.swift
//  Domain
//
//  Created by 마경미 on 24.12.23.
//

import Foundation
import RxSwift

public protocol SearchFamilyMemberUseCaseProtocol {
    func excute(query: SearchFamilyQuery) -> Single<SearchFamilyPage?>
    func execute(memberIds: [String]) -> [ProfileData]?
}

public class SearchFamilyUseCase: SearchFamilyMemberUseCaseProtocol {
    private let searchFamilyRepository: SearchFamilyRepository
    
    public init(searchFamilyRepository: SearchFamilyRepository) {
        self.searchFamilyRepository = searchFamilyRepository
    }
    
    public func excute(query: SearchFamilyQuery) -> Single<SearchFamilyPage?> {
        return searchFamilyRepository.fetchFamilyMember(query: query)
    }
    
    public func execute(memberIds: [String]) -> [ProfileData]? {
        return searchFamilyRepository.getSavedFamilyMember(memberIds: memberIds)
    }
}
