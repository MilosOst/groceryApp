//
//  EditTemplateModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import Foundation
import CoreData

class EditTemplateModel: SelectInventoryItemDelegate {
    let template: Template
    private let context: NSManagedObjectContext
    private weak var delegate: NSFetchedResultsControllerDelegate?
    
    private var fetchedResultsController: NSFetchedResultsController<TemplateItem>!
    
    init(template: Template, context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate?) {
        self.template = template
        self.context = context
        self.delegate = delegate
        self.fetchedResultsController = createFetchedResultsController(with: ListItemsSortOption(rawValue: template.sortOrder) ?? .category)
        self.fetchedResultsController.delegate = delegate
    }
    
    private func createFetchedResultsController(with sortOrder: ListItemsSortOption) -> NSFetchedResultsController<TemplateItem> {
        let fetchRequest = TemplateItem.fetchRequest()
        let predicate = NSPredicate(format: "template == %@", template)
        var sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TemplateItem.item.name), ascending: true),
        ]
        
        var sectionKeyPath: String? = nil
        if sortOrder == .category {
            let sortByCategory = NSSortDescriptor(key: #keyPath(TemplateItem.item.category.name), ascending: true)
            sortDescriptors.insert(sortByCategory, at: 0)
            sectionKeyPath = #keyPath(TemplateItem.item.categoryName)
        }
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        return controller
    }
    
    func loadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    var templateName: String {
        template.name!
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func sectionName(for section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
    
    func item(at indexPath: IndexPath) -> TemplateItem {
        fetchedResultsController.object(at: indexPath)
    }
    
    private func matchingItem(for inventoryItem: InventoryItem) -> TemplateItem? {
        fetchedResultsController.fetchedObjects?.first(where: { $0.item == inventoryItem })
    }
    
    func deleteItem(at indexPath: IndexPath) throws {
        let item = item(at: indexPath)
        context.delete(item)
        try context.save()
    }
    
    // MARK: Template Editing Methods
    /// Updates the Template's sort order to the given order and refetches the data.
    /// - Returns: Boolean indicating whether a change was successfully made
    func setSortOrder(_ order: ListItemsSortOption) -> Bool {
        guard order.rawValue != template.sortOrder else { return false }
        let newController = createFetchedResultsController(with: order)
        do {
            try newController.performFetch()
            template.sortOrder = order.rawValue
            try context.save()
        } catch {
            print(error)
            return false
        }
        
        // Remove delegate from previous controller and update to new one
        fetchedResultsController.delegate = nil
        newController.delegate = delegate
        fetchedResultsController = newController
        return true
    }
    
    func setName(to name: String) throws {
        let name = name.trimmed
        guard !name.isEmpty else { throw EntityCreationError.emptyName }
        
        // If name is different (case insensitive), verify uniqueness
        if name.lowercased() != templateName.lowercased() {
            let validator = TemplateValidator(context: context)
            guard try validator.isNameUnique(name) else { throw EntityCreationError.duplicateName }
        }
        
        template.name = name
        try context.save()
    }
    
    /// Attempts to create a ShoppingList from the current template.
    func createList() throws -> ShoppingList {
        let list = ShoppingList(context: context)
        list.name = templateName
        list.creationDate = .now
        list.sortOrder = template.sortOrder
        for templateItem in fetchedResultsController.fetchedObjects ?? [] {
            let listItem = ListItem(context: context)
            listItem.item = templateItem.item
            listItem.quantity = templateItem.quantity
            listItem.notes = templateItem.notes
            listItem.price = templateItem.price
            list.addToItems(listItem)
        }
        
        try context.save()
        return list
    }
    
    func deleteTemplate() throws {
        context.delete(template)
        try context.save()
    }
    
    // MARK: - InventoryItem Selection
    func isItemSelected(_ item: InventoryItem) -> Bool {
        return matchingItem(for: item) != nil
    }
    
    func didToggleItem(_ item: InventoryItem) {
        do {
            if let matchingItem = matchingItem(for: item) {
                context.delete(matchingItem)
                try context.save()
            } else {
                let templateItem = TemplateItem(context: context)
                templateItem.template = template
                templateItem.quantity = 1
                templateItem.unit = item.unit
                templateItem.item = item
                try context.save()
            }
        } catch {
            print(error)
        }
    }
}
