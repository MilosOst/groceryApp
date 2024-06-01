//
//  UIFont+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-01.
//

import UIKit

enum PoppinsVariation: String {
    case thin = "Poppins-Thin"
    case extraLight = "Poppins-ExtraLight"
    case light = "Poppins-Light"
    case medium = "Poppins-Medium"
    case regular = "Poppins-Regular"
}

extension UIFont {
    static func poppinsFont(varation: PoppinsVariation, size: CGFloat) -> UIFont {
        return UIFont(name: varation.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
