//
//  InventoryItemValidator.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-06.
//

import CoreData

enum InventoryItemCreationError: Error {
    case emptyName
    case duplicateName
}

class InventoryItemValidator {
    private let coreDataContext: NSManagedObjectContext
    
    init(coreDataContext: NSManagedObjectContext) {
        self.coreDataContext = coreDataContext
    }
    
    func validateItem(_ item: InventoryItemCreationState) throws {
        let name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw InventoryItemCreationError.emptyName
        }
        
        // Verify name is not already taken
        let fetchRequest = InventoryItem.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(InventoryItem.name), name])
        fetchRequest.predicate = predicate
        
        let count = try coreDataContext.count(for: fetchRequest)
        guard count == 0 else { throw InventoryItemCreationError.duplicateName }
    }
}
