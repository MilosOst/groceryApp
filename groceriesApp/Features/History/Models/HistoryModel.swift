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
        
        let fetchRequest = ShoppingList.fetchRequest()
        let predicate = NSPredicate(format: "completionDate != nil")
        let sortByDate = NSSortDescriptor(key: #keyPath(ShoppingList.completionDate), ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortByDate]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: #keyPath(ShoppingList.completionDateSection), cacheName: nil)
        fetchedResultsController.delegate = delegate
    }
    
    func loadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func titleForSection(_ section: Int) -> String? {
        fetchedResultsController.sections?[section].name ?? ""
    }
    
    func shoppingList(at indexPath: IndexPath) -> ShoppingList {
        fetchedResultsController.object(at: indexPath)
    }
    
    func deleteList(at indexPath: IndexPath) throws {
        let item = shoppingList(at: indexPath)
        context.delete(item)
        try context.save()
    }
}
