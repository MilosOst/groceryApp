//
//  ListSummaryModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-02.
//

import Foundation
import CoreData

class ListSummaryModel {
    let list: ShoppingList
    private let context: NSManagedObjectContext
    private weak var delegate: NSFetchedResultsControllerDelegate?
    private var fetchedResultsController: NSFetchedResultsController<ListItem>
    
    init(list: ShoppingList, context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate? = nil) {
        self.list = list
        self.context = context
        self.delegate = delegate
        
        let fetchRequest = ListItem.fetchRequest()
        let predicate = NSPredicate(format: "list == %@", list)
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ListItem.isChecked), ascending: false),
            NSSortDescriptor(key: #keyPath(ListItem.item.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        ]
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: #keyPath(ListItem.isChecked), cacheName: nil)
        fetchedResultsController.delegate = delegate
    }
    
    func loadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    // MARK: - Accessors
    var totalSpent: Double {
        list.totalCost
    }
    
    var completionDate: Date {
        list.completionDate ?? .now
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func titleForSection(_ section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    
    func item(at indexPath: IndexPath) -> ListItem {
        fetchedResultsController.object(at: indexPath)
    }
    
    func updateCompletionDate(to date: Date) throws {
        list.completionDate = date
        try context.save()
    }
    
    func deleteItem(at indexPath: IndexPath) throws {
        let item = item(at: indexPath)
        context.delete(item)
        try context.save()
    }
    
    func makeActive() throws {
        list.completionDate = nil
        try context.save()
    }
    
    func deleteList() throws {
        context.delete(list)
        try context.save()
    }
}
