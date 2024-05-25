//
//  HomeTemplatesModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import Foundation
import CoreData

class HomeTemplatesModel {
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<Template>
    private weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate?) {
        self.context = context
        self.delegate = delegate
        
        // TODO: Sort by favourites?
        let fetchRequest = Template.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Template.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sortByName]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = delegate
    }
    
    func loadData() throws {
        try fetchedResultsController.performFetch()
    }
    
    var numberOfTemplates: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func template(at indexPath: IndexPath) -> Template {
        fetchedResultsController.object(at: indexPath)
    }
    
    func deleteTemplate(at indexPath: IndexPath) throws {
        let template = template(at: indexPath)
        context.delete(template)
        try context.save()
    }
}
