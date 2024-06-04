//
//  InventoryItemValidator.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-04.
//

import CoreData

class InventoryItemValidator {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func isNameUnique(_ name: String) throws -> Bool {
        let fetchRequest = InventoryItem.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(InventoryItem.name), name])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        let count = try? context.count(for: fetchRequest)
        return count == 0
    }
}
