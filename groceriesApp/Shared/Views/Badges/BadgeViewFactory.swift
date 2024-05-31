//
//  BadgeView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-30.
//

import UIKit

class BadgeViewFactory {
    static func makeBadge(text: String) -> UILabel {
        let size: CGFloat = 24
        let digits = CGFloat(text.count)
        let width = max(size, 0.45 * size * digits)
        
        let frame = CGRect(origin: .zero, size: CGSize(width: width, height: size))
        let badge = UILabel(frame: frame)
        badge.text = text
        badge.layer.cornerRadius = size / 2
        badge.layer.masksToBounds = true
        badge.textAlignment = .center
        badge.backgroundColor = .systemBlue
        badge.textColor = .white
        badge.font = .poppinsFont(varation: .light, size: 14)
        return badge
    }
}
