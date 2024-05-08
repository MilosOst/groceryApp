//
//  ShoppingListService.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-07.
//

import CoreData

class ShoppingListService {
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<ListItem>
    private let list: ShoppingList
    
    init(context: NSManagedObjectContext, fetchedResultsController: NSFetchedResultsController<ListItem>, list: ShoppingList) {
        self.context = context
        self.fetchedResultsController = fetchedResultsController
        self.list = list
    }
    
    /// Returns the index of the given inventory item in the fetched resulsts controller if it exists, nil otherwise
    private func itemIndex(_ item: InventoryItem) -> Int? {
        return (fetchedResultsController.fetchedObjects ?? []).firstIndex(where: { $0.item == item })
    }
    
    func isItemSelected(_ item: InventoryItem) -> Bool {
        return itemIndex(item) != nil
    }
    
    func toggleItem(_ item: InventoryItem) {
        // Check if item is already in the list
        if let index = itemIndex(item) {
            do {
                let object = fetchedResultsController.fetchedObjects![index]
                context.delete(object)
                list.itemCount -= 1
                try context.save()
            } catch {
                print(error)
            }
        } else {
            do {
                let listItem = ListItem(context: context)
                listItem.item = item
                listItem.quantity = 1
                list.addToItems(listItem)
                list.itemCount += 1
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    /// Checks or unchecks a ListItem
    func checkItem(_ item: ListItem) {
        item.isChecked.toggle()
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
