//
//  EntityCreationError.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import Foundation

enum EntityCreationError: Error {
    case emptyName
    case duplicateName
}
