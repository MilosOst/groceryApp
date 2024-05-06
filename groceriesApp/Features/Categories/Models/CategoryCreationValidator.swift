//
//  CategoryCreationValidator.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-06.
//

import CoreData

enum CategoryCreationError: Error {
    case empty
    case duplicateName
}

class CategoryCreationValidator {
    private let coreDataContext: NSManagedObjectContext
    
    init(coreDataContext: NSManagedObjectContext) {
        self.coreDataContext = coreDataContext
    }
    
    func validate(_ categoryName: String) throws {
        let name = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw CategoryCreationError.empty
        }
        
        // Verify uniqueness
        let fetchRequest = Category.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(Category.name), name])
        fetchRequest.predicate = predicate
        
        let count = try coreDataContext.count(for: fetchRequest)
        guard count == 0 else {
            throw CategoryCreationError.duplicateName
        }
    }
}
