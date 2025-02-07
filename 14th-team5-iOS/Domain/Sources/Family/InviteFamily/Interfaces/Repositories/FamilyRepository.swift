//
//  FamilyRepository.swift
//  Domain
//
//  Created by 김건우 on 12/29/23.
//

import Foundation

import RxSwift

public protocol FamilyRepositoryProtocol {
    var disposeBag: DisposeBag { get }
    
    func createFamily() -> Observable<FamilyResponse?>
    func fetchInvitationUrl() -> Observable<FamilyInvitationLinkResponse?>
    func fetchFamilyMembers() -> Observable<PaginationResponseFamilyMemberProfile?>
}
