//
//  PlaceholderCalendarCell.swift
//  App
//
//  Created by 김건우 on 12/6/23.
//

import Foundation

import Core
import FSCalendar
import Kingfisher
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class PlaceholderCalendarCell: FSCalendarCell {
    // MARK: - Properties
    static let identifier: String = "PlaceholderCalendarCell"
    
    // MARK: - Intializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupAutoLayout()
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func setupAutoLayout() {
        titleLabel.snp.makeConstraints {
            $0.center.equalTo(contentView.snp.center)
        }
    }
}
