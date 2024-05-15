//
//  EditListModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-14.
//

import Foundation
import CoreData

class EditListModel: SelectInventoryItemDelegate {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<ListItem>!
    private let list: ShoppingList
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext, list: ShoppingList, fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? = nil) {
        self.context = context
        self.list = list
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        let controller = createFetchedResultsController(ListItemsSortOption(rawValue: list.sortOrder) ?? .category)
        controller.delegate = fetchedResultsControllerDelegate
        self.fetchedResultsController = controller
    }
    
    private func createFetchedResultsController(_ sortOption: ListItemsSortOption) -> NSFetchedResultsController<ListItem> {
        let fetchRequest = ListItem.fetchRequest()
        let predicate = NSPredicate(format: "list == %@", list)
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ListItem.isChecked), ascending: true),
            NSSortDescriptor(key: #keyPath(ListItem.item.name), ascending: true)
        ]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        // If sorting by category, need to add category sort descriptor and section keypath
        var sectionKeyPath: String? = nil
        if sortOption == .category {
            let sortByCategory = NSSortDescriptor(key: #keyPath(ListItem.item.category.name), ascending: true)
            fetchRequest.sortDescriptors?.insert(sortByCategory, at: 0)
            sectionKeyPath = #keyPath(ListItem.item.categoryName)
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        return controller
    }
    
    // MARK: - Accessors
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    var numberOfItems: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    var sortOrder: ListItemsSortOption {
        ListItemsSortOption(rawValue: list.sortOrder) ?? .category
    }
    
    func item(at indexPath: IndexPath) -> ListItem {
        fetchedResultsController.object(at: indexPath)
    }
    
    func indexPath(forItem: ListItem) -> IndexPath? {
        fetchedResultsController.indexPath(forObject: forItem)
    }
    
    func sectionName(for section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    /// Searches the ListItems to see if there is one using the provided inventory item.
    private func matchingListItem(with item: InventoryItem) -> ListItem? {
        fetchedResultsController.fetchedObjects?.first(where: { $0.item == item })
    }
    
    // MARK: - Methods
    func loadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    func checkedItem(at indexPath: IndexPath) throws {
        let item = fetchedResultsController.object(at: indexPath)
        item.isChecked.toggle()
        try context.save()
    }
    
    func deleteItem(at indexPath: IndexPath) throws {
        let object = fetchedResultsController.object(at: indexPath)
        context.delete(object)
        try context.save()
    }
    
    func deleteList() throws {
        context.delete(list)
        try context.save()
    }
    
    /// Handles the changes to the sort order of the list items.
    /// - Returns: The sort option after the operation was performed.
    func changedSortOption(to option: ListItemsSortOption) -> ListItemsSortOption {
        guard option.rawValue != list.sortOrder else { return option }
        let newController = createFetchedResultsController(option)
        do {
            try newController.performFetch()
            list.sortOrder = option.rawValue
            try context.save()
        } catch {
            print(error)
            return ListItemsSortOption(rawValue: list.sortOrder) ?? .category
        }
        
        // Update delegates upon succcess
        fetchedResultsController.delegate = nil
        newController.delegate = fetchedResultsControllerDelegate
        fetchedResultsController = newController
        return option
    }
    
    // MARK: - SelectInventoryItemDelegate Methods
    func didToggleItem(_ item: InventoryItem) {
        // Check if item already exists
        do {
            if let existingItem = matchingListItem(with: item) {
                context.delete(existingItem)
                try context.save()
            } else {
                // Item does not exist, create new ListItem
                let listItem = ListItem(context: context)
                listItem.item = item
                listItem.quantity = 1
                list.addToItems(listItem)
                try context.save()
            }
        } catch {
            print(error)
        }
    }
    
    func isItemSelected(_ item: InventoryItem) -> Bool {
        return matchingListItem(with: item) != nil
    }
    
}
