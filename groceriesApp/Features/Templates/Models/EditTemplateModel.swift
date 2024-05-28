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
        template.name ?? ""
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
