//
//  EmojiView.swift
//  App
//
//  Created by 마경미 on 10.12.23.
//

import UIKit
import Core

import RxSwift
import RxCocoa

final class EmojiView: BaseView<EmojiReactor> {
    private let emojiLabel = UILabel()
    private let countLabel = UILabel()
    
    override func setupUI() {
        addSubviews(emojiLabel, countLabel)
    }
    
    override func bind(reactor: EmojiReactor) {
        
    }
    
    override func setupAutoLayout() {
        emojiLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(9)
            $0.width.equalTo(16)
            $0.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(emojiLabel.snp.trailing)
            $0.trailing.equalToSuperview().inset(5)
            $0.width.equalTo(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    override func setupAttributes() {
        isUserInteractionEnabled = true
        backgroundColor =  UIColor(red: 0.192, green: 0.192, blue: 0.192, alpha: 1)
        layer.cornerRadius = 15
        
        countLabel.do {
            $0.textColor = .white
        }
    }
}

extension EmojiView {
    func setInitEmoji(emoji: EmojiData) {
        emojiLabel.text = emoji.emoji
        countLabel.text = "\(emoji.count)"
    }
}

extension Reactive where Base: EmojiView {
    var tap: ControlEvent<Void> {
        let tapGestureRecognizer = UITapGestureRecognizer()

        base.isUserInteractionEnabled = true
        base.addGestureRecognizer(tapGestureRecognizer)

        return ControlEvent(events: tapGestureRecognizer.rx.event.map { _ in })
    }
}

