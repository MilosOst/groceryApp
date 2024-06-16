//
//  EditShoppingListItemsViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-15.
//

import UIKit

class EditShoppingListItemsViewController: EditListableItemsViewController<ListItem> {
    init(shoppingList: ShoppingList, startItem: ListItem) {
        super.init()
        self.model = EditListItemsModel(list: shoppingList, startItem: startItem, context: coreDataContext, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
}
