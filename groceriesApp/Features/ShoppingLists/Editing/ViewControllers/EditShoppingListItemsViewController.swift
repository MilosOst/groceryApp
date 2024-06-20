//
//  EditShoppingListItemsViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-15.
//

import UIKit
import WidgetKit

class EditShoppingListItemsViewController: EditListableItemsViewController<ListItem> {
    init(shoppingList: ShoppingList, startItem: ListItem) {
        super.init()
        self.model = EditListItemsModel(list: shoppingList, startItem: startItem, context: coreDataContext, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func priceDidChange(in cell: EditListableItemCell, to price: String?) {
        super.priceDidChange(in: cell, to: price)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    override func quantityDidChange(in cell: EditListableItemCell, to quantity: String?) {
        super.quantityDidChange(in: cell, to: quantity)
        WidgetCenter.shared.reloadTimelines(ofKind: "com.MilosOst.KaufList.ListItemsWidget")
    }
    
    override func unitDidChange(in cell: EditListableItemCell, to unit: String?) {
        super.unitDidChange(in: cell, to: unit)
        WidgetCenter.shared.reloadTimelines(ofKind: "com.MilosOst.KaufList.ListItemsWidget")
    }
    
    override func removePressed(_ cell: EditListableItemCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let alert = UIAlertController.makeDeleteDialog(title: nil, message: nil, handler: { [self] _ in
            do {
                try model.deleteItem(at: indexPath)
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
}
