//
//  ListDetailMenuDelegate.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-15.
//

import Foundation

protocol EditListMenuDelegate: AnyObject {
    func didSelectSortOption(_ option: ListItemsSortOption)
    func didSelectDelete()
    func didSelectMakeList()
    func didSelectMarkComplete()
    func didSelectRename()
}
