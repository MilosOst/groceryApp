//
//  ItemNameChangeType.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-04.
//

import Foundation

/// Enum indicating the type of name change to be performed.
/// Local should only change the name for the current Template/List, whereas everywhere should change it globally.
enum ItemNameChangeType {
    case local
    case global
}
