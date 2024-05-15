//
//  ListDetailMenuDelegate.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-15.
//

import Foundation

protocol ListDetailMenuDelegate: AnyObject {
    func didSelectSortOption(_ option: ListItemsSortOption)
    func didSelectDelete()
    func didSelectMarkComplete()
}
