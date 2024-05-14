//
//  SelectInventoryItemModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-13.
//

import Foundation
import CoreData

// TODO: Add sort order ??
class SelectInventoryItemModel {
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<InventoryItem>
    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    private var prevQuery: String = ""
    
    init(context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate) {
        self.context = context
        self.fetchedResultsControllerDelegate = delegate
        
        let fetchRequest = InventoryItem.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(InventoryItem.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sortByName]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = delegate
        
        // TODO: Handle errors with variable
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Accessors and Methods
    var numberOfItems: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func item(at indexPath: IndexPath) -> InventoryItem {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func deleteItem(at indexPath: IndexPath) throws {
        let object = fetchedResultsController.object(at: indexPath)
        context.delete(object)
        try context.save()
    }
    
    /// Filters inventory items for ones that include the query string.
    /// - Returns: Bool indicating whether a new query was performed.
    func processSearch(_ query: String) throws -> Bool {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query != prevQuery else { return false }
        
        if query.isEmpty {
            fetchedResultsController.fetchRequest.predicate = nil
        } else {
            let newPredicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
            fetchedResultsController.fetchRequest.predicate = newPredicate
        }
        
        try fetchedResultsController.performFetch()
        prevQuery = query
        return true
    }
}
