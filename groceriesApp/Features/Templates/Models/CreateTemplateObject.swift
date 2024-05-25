//
//  CreateTemplateInput.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import Foundation

struct CreateTemplateObject {
    var name: String = ""
    var sortOrder: ListItemsSortOption = .category
    var isFavourite: Bool = false
}
