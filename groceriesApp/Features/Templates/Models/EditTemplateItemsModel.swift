//
//  EditTemplateItemsModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-26.
//

import Foundation
import CoreData

class EditTemplateItemsModel: EditListableItemsModel<TemplateItem> {
    private let template: Template
    
    init(template: Template, startItem: TemplateItem, context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate?) {
        self.template = template
        
        let fetchRequest = TemplateItem.fetchRequest()
        let predicate = NSPredicate(format: "template == %@", template)
        var sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TemplateItem.item.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        ]
        fetchRequest.predicate = predicate
        // If sorted by category, add category sort descriptor
        if template.sortOrder == ListItemsSortOption.category.rawValue {
            let sortByCategory = NSSortDescriptor(key: #keyPath(TemplateItem.item.category.name), ascending: true)
            sortDescriptors.insert(sortByCategory, at: 0)
        }
        
        fetchRequest.sortDescriptors = sortDescriptors
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = delegate
        super.init(fetchedResultsController: fetchedResultsController, context: context, delegate: delegate, startItem: startItem)
    }
}
