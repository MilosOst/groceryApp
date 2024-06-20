//
//  EditListModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-14.
//

import Foundation
import CoreData
import WidgetKit

class EditListModel: SelectInventoryItemDelegate {
    let list: ShoppingList
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<ListItem>!
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(list: ShoppingList, context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate?) {
        self.list = list
        self.context = context
        self.fetchedResultsControllerDelegate = delegate
        self.fetchedResultsController = createFetchedResultsController(with: ListItemsSortOption(rawValue: list.sortOrder) ?? .category)
        self.fetchedResultsController.delegate = delegate
    }
    
    private func createFetchedResultsController(with sortOrder: ListItemsSortOption) -> NSFetchedResultsController<ListItem> {
        let fetchRequest = ListItem.fetchRequest()
        let predicate = NSPredicate(format: "list == %@", list)
        var sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ListItem.isChecked), ascending: true),
            NSSortDescriptor(key: #keyPath(ListItem.item.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        ]
        
        
        // If sorting by category, need to add category sort descriptor and section keypath
        var sectionKeyPath: String? = nil
        if sortOrder == .category {
            let sortByCategory = NSSortDescriptor(key: #keyPath(ListItem.item.category.name), ascending: true)
            sortDescriptors.insert(sortByCategory, at: 0)
            sectionKeyPath = #keyPath(ListItem.item.categoryName)
        }
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        return controller
    }
    
    func loadData(forceReload: Bool = false) throws {
        // If force reload, need to dirty item to notice changes
        if forceReload, let item = fetchedResultsController.fetchedObjects?.first {
            item.quantity = item.quantity
        }
        
        try fetchedResultsController.performFetch()
    }
    
    var listName: String {
        list.name!
    }
    
    var numberOfItems: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    var sortOrder: ListItemsSortOption {
        ListItemsSortOption(rawValue: list.sortOrder) ?? .category
    }
    
    func sectionName(for section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
    
    func item(at indexPath: IndexPath) -> ListItem {
        fetchedResultsController.object(at: indexPath)
    }
    
    /// Searches the ListItems to see if there is one using the provided inventory item.
    private func matchingListItem(with item: InventoryItem) -> ListItem? {
        fetchedResultsController.fetchedObjects?.first(where: { $0.item == item })
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
    
    // MARK: - ShoppingList Editing Methods
    func setSortOrder(_ order: ListItemsSortOption) -> Bool {
        guard order.rawValue != list.sortOrder else { return false }
        let newController = createFetchedResultsController(with: order)
        do {
            try newController.performFetch()
            list.sortOrder = order.rawValue
            try context.save()
        } catch {
            print(error)
            return false
        }
        
        // Remove delegate from previous controller and update to new one
        fetchedResultsController.delegate = nil
        newController.delegate = fetchedResultsControllerDelegate
        fetchedResultsController = newController
        return true
    }
    
    func setName(to name: String) throws {
        let name = name.trimmed
        guard !name.isEmpty else { throw EntityCreationError.emptyName }
        list.name = name
        try context.save()
    }
    
    func deleteList() throws {
        context.delete(list)
        try context.save()
    }
    
    func markComplete() throws {
        list.completionDate = .now
        try context.save()
    }
    
    func createTemplate(name: String) throws -> Template {
        let name = name.trimmed
        guard !name.isEmpty else { throw EntityCreationError.emptyName }
        
        // Verify name uniqueness
        let validator = TemplateValidator(context: context)
        guard try validator.isNameUnique(name) else { throw EntityCreationError.duplicateName }
        
        let template = Template(context: context)
        template.name = name
        template.sortOrder = list.sortOrder
        for listItem in fetchedResultsController.fetchedObjects ?? [] {
            let templateItem = TemplateItem(context: context)
            templateItem.item = listItem.item
            templateItem.quantity = listItem.quantity
            templateItem.price = listItem.price
            templateItem.notes = listItem.notes
            templateItem.unit = listItem.unit
            template.addToItems(templateItem)
        }
        try context.save()
        return template
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
                listItem.unit = item.unit
                list.addToItems(listItem)
                try context.save()
            }
        } catch {
            print(error)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func isItemSelected(_ item: InventoryItem) -> Bool {
        return matchingListItem(with: item) != nil
    }
    
}
