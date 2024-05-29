//
//  TemplateValidator.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-29.
//

import Foundation
import CoreData

/// Class that deals with validation of Template items such as checking uniqueness of a name.
class TemplateValidator {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func isNameUnique(_ name: String) throws -> Bool {
        let fetchRequest = Template.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(Template.name), name])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        let count = try? context.count(for: fetchRequest)
        return count == 0
    }
}
