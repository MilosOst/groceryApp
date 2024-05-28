//
//  EditTemplateItemsModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-26.
//

import Foundation
import CoreData

class EditTemplateItemsModel {
    private let template: Template
    private let context: NSManagedObjectContext
    let startItem: TemplateItem
    private weak var delegate: NSFetchedResultsControllerDelegate?
    private let fetchedResultsController: NSFetchedResultsController<TemplateItem>
    
    init(template: Template, startItem: TemplateItem, context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate?) {
        self.template = template
        self.startItem = startItem
        self.context = context
        self.delegate = delegate
        
        let fetchRequest = TemplateItem.fetchRequest()
        let predicate = NSPredicate(format: "template == %@", template)
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TemplateItem.item.name), ascending: true)
        ]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        // If sorted by category, add Category NSSortDescriptor
        if template.sortOrder == ListItemsSortOption.category.rawValue {
            let sortByCategory = NSSortDescriptor(key: #keyPath(TemplateItem.item.category.name), ascending: true)
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
    
    func item(at indexPath: IndexPath) -> TemplateItem {
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
    
    func updateCategory(to category: Category, at indexPath: IndexPath) throws {
        let item = item(at: indexPath)
        item.item?.category = category
        item.quantity = item.quantity // Mark as dirty so fetched results controller notices change
        try context.save()
    }
    
    func deleteItem(at indexPath: IndexPath) throws {
        let item = item(at: indexPath)
        context.delete(item)
        try context.save()
    }
    
}
