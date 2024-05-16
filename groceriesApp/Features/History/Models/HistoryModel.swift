//
//  HistoryModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import CoreData

class HistoryModel {
    private let context: NSManagedObjectContext
    weak var delegate: NSFetchedResultsControllerDelegate?
    private let fetchedResultsController: NSFetchedResultsController<ShoppingList>
    
    init(context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate) {
        self.context = context
        self.delegate = delegate
        
        // TODO: Separate into sections by day/week?
        let fetchRequest = ShoppingList.fetchRequest()
        let predicate = NSPredicate(format: "isCompleted == YES")
        let sortByDate = NSSortDescriptor(key: #keyPath(ShoppingList.creationDate), ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortByDate]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = delegate
    }
    
    func loadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    var numberOfLists: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func shoppingList(at indexPath: IndexPath) -> ShoppingList {
        fetchedResultsController.object(at: indexPath)
    }
}
