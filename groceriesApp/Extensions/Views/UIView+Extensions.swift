//
//  UIView+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-02.
//

import UIKit

extension UIView {
    func constrainToEdgesOf(view: UIView, insets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
        ])
    }
}
