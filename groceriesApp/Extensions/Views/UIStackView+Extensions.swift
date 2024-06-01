//
//  UIStackView+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-05.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.addArrangedSubview(subview)
        }
    }
}
