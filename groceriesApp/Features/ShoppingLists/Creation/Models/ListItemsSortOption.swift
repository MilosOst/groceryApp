//
//  ListItemsSortOption.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-09.
//

import Foundation


@objc enum ListItemsSortOption: Int16, Equatable {
    case name = 0
    case category = 1
}

extension ListItemsSortOption: CustomStringConvertible {
    var description: String {
        switch self {
        case .name:
            return "Name"
        case .category:
            return "Category"
        }
    }
}
