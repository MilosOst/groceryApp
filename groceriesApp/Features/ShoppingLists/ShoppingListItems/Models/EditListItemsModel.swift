//
//  EditListItemsModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import Foundation
import CoreData

class EditListItemsModel {
    private let shoppingList: ShoppingList
    private let context: NSManagedObjectContext
    let startItem: ListItem
    private weak var delegate: NSFetchedResultsControllerDelegate?
    private let fetchedResultsController: NSFetchedResultsController<ListItem>
    
    init(list: ShoppingList, startItem: ListItem, context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate?) {
        self.shoppingList = list
        self.startItem = startItem
        self.context = context
        self.delegate = delegate
        
        
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
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = delegate
    }
    
    func loadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    var numberOfItems: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var indexPathForStartItem: IndexPath? {
        fetchedResultsController.indexPath(forObject: startItem)
    }
    
    func item(at indexPath: IndexPath) -> ListItem {
        fetchedResultsController.object(at: indexPath)
    }
    
    // MARK: - Editing
    func updateQuantity(at indexPath: IndexPath, quantity: Float) throws {
        let item = item(at: indexPath)
        item.quantity = quantity
        try context.save()
    }
    
    func updateUnit(at indexPath: IndexPath, unit: String?) throws {
        let item = item(at: indexPath)
        item.unit = unit
        try context.save()
    }
    
    func updatePrice(at indexPath: IndexPath, price: Float) throws {
        let item = item(at: indexPath)
        item.price = price
        try context.save()
    }
    
    func updateNotes(at indexPath: IndexPath, notes: String) throws {
        let item = item(at: indexPath)
        let updatedNotes = notes.isTrimmedEmpty ? nil : notes.trimmed
        item.notes = updatedNotes
        try context.save()
    }
    
    func updateCategory(to category: Category, at indexPath: IndexPath) throws {
        let item = item(at: indexPath)
        item.item?.category = category
        item.quantity = item.quantity // Mark as dirty so fetched results controller notices change
        try context.save()
    }
    
    func rename(at indexPath: IndexPath, newName: String, editType: ItemNameChangeType) throws {
        let newName = newName.trimmed
        guard !newName.isEmpty else { throw InventoryItemError.emptyName }
        
        let listItem = item(at: indexPath)
        let currInvItem = listItem.item!
        let currName = currInvItem.name!.trimmed
        
        // If name is exact same, do nothing
        guard newName != currName else { return }
        
        // Check if name is same ignoring case
        if newName.lowercased() == currName.lowercased() {
            if editType == .global {
                currInvItem.name = newName
                try context.save()
                return
            } else {
                // Cannot create new item since name is taken
                throw InventoryItemError.duplicateName
            }
        }
        
        // Name is different, check uniqueness
        let nameValidator = InventoryItemValidator(context: context)
        guard try nameValidator.isNameUnique(newName) else { throw InventoryItemError.duplicateName }
        if editType == .global {
            currInvItem.name = newName
            listItem.quantity = listItem.quantity
            try context.save()
        } else {
            // Name is unique, create new InventoryItem and update ListItem's reference
            let newInventoryItem = InventoryItem(context: context)
            newInventoryItem.category = currInvItem.category
            newInventoryItem.unit = currInvItem.unit
            newInventoryItem.isFavourite = currInvItem.isFavourite
            newInventoryItem.name = newName
            listItem.item = newInventoryItem
            try context.save()
        }
    }
    
    func deleteItem(at indexPath: IndexPath) throws {
        let item = item(at: indexPath)
        context.delete(item)
        try context.save()
    }
}
