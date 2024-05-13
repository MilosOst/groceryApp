//
//  UIAlertController+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-13.
//

import UIKit

extension UIAlertController {
    func addActions(_ actions: [UIAlertAction]) {
        for action in actions {
            addAction(action)
        }
    }
}
