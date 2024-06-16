//
//  EditListableItemsModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-15.
//

import CoreData

/// Abstract class for generic editing model for collection of ListableItems
class EditListableItemsModel<T: ListableItem & NSManagedObject> {
    internal var fetchedResultsController: NSFetchedResultsController<T>
    internal let context: NSManagedObjectContext
    internal weak var delegate: NSFetchedResultsControllerDelegate?
    internal let startItem: T
    
    init(fetchedResultsController: NSFetchedResultsController<T>, context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate?, startItem: T) {
        self.fetchedResultsController = fetchedResultsController
        self.context = context
        self.delegate = delegate
        self.startItem = startItem
    }
    
    func loadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    var numberOfItems: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func item(at indexPath: IndexPath) -> T {
        fetchedResultsController.object(at: indexPath)
    }
    
    var indexPathForStartItem: IndexPath? {
        fetchedResultsController.indexPath(forObject: startItem)
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
    
    func updateCategory(to category: Category?, at indexPath: IndexPath) throws {
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
