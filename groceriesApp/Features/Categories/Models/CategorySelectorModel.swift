//
//  CategorySelectorModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-13.
//

import UIKit
import CoreData

class CategorySelectorModel {
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<Category>
    private(set) var currentCategory: Category?
    weak var controllerDelegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext, controllerDelegate: NSFetchedResultsControllerDelegate, initialCategory: Category?) {
        self.context = context
        self.currentCategory = initialCategory
        self.controllerDelegate = controllerDelegate
        
        // Initialise NSFetchedResultsController
        let fetchRequest = Category.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Category.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sortByName]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = controllerDelegate
        // TODO: Refactor to show indicate error if fetch failed
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    // MARK - Accessor Methods/Properties
    var numberOfCategories: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func category(at indexPath: IndexPath) -> Category {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func createCategory(name: String) throws {
        // Verify that name is non-empty
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw CategoryError.empty }
        
        // Verify name is unique
        let fetchRequest = Category.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(Category.name), name])
        fetchRequest.predicate = predicate
        let count = try context.count(for: fetchRequest)
        guard count == 0 else {
            throw CategoryError.duplicateName
        }
        
        // Name is valid, create Category
        let category = Category(context: context)
        category.name = name
        try context.save()
    }
    
    func deleteCategory(at indexPath: IndexPath) throws {
        let category = fetchedResultsController.object(at: indexPath)
        context.delete(category)
        try context.save()
    }
}
