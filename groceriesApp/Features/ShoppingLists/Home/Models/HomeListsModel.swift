//
//  HomeListsModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-15.
//

import CoreData

class HomeListsModel {
    private let fetchedResultsController: NSFetchedResultsController<ShoppingList>
    private let context: NSManagedObjectContext
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate? = nil) {
        self.context = context
        self.delegate = delegate
        
        let fetchRequest = ShoppingList.fetchRequest()
        let predicate = NSPredicate(format: "isCompleted == NO")
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
    
    func deleteObject(at indexPath: IndexPath) throws {
        let object = fetchedResultsController.object(at: indexPath)
        context.delete(object)
        try context.save()
    }
}
