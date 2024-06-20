//
//  EditListItemsModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import Foundation
import CoreData
import WidgetKit

class EditListItemsModel: EditListableItemsModel<ListItem> {
    private let shoppingList: ShoppingList
    
    init(list: ShoppingList, startItem: ListItem, context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate?) {
        self.shoppingList = list
        let fetchRequest = ListItem.fetchRequest()
        let predicate = NSPredicate(format: "list == %@", shoppingList)
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ListItem.isChecked), ascending: true),
            NSSortDescriptor(key: #keyPath(ListItem.item.name), ascending: true)
        ]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        // If sorted by category, add Category NSSortDescriptor
        if shoppingList.sortOrder == ListItemsSortOption.category.rawValue {
            let sortByCategory = NSSortDescriptor(key: #keyPath(ListItem.item.category.name), ascending: true)
            fetchRequest.sortDescriptors?.insert(sortByCategory, at: 0)
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = delegate
        
        super.init(fetchedResultsController: fetchedResultsController, context: context, delegate: delegate, startItem: startItem)
    }
    
    override func rename(at indexPath: IndexPath, newName: String, editType: ItemNameChangeType) throws {
        try super.rename(at: indexPath, newName: newName, editType: editType)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
