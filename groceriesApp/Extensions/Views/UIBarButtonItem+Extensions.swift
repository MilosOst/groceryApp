//
//  UIBarButtonItem+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-24.
//

import UIKit

extension UIBarButtonItem {
    static func createEmptyButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
