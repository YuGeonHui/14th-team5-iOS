//
//  CalendarViewRepository.swift
//  Data
//
//  Created by 김건우 on 12/15/23.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

public protocol CalendarImpl {
    var disposeBag: DisposeBag { get }
}

public final class CalendarViewRepository: CalendarImpl {
    public let disposeBag: DisposeBag = DisposeBag()
    
    public init() { }
}
