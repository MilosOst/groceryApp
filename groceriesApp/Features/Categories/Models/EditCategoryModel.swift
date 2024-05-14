//
//  EditCategoryModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-14.
//

import Foundation
import CoreData

class EditCategoryModel {
    private let category: Category
    private let context: NSManagedObjectContext
    private(set) var newName: String
    
    init(category: Category, context: NSManagedObjectContext) {
        self.category = category
        self.context = context
        self.newName = category.name ?? ""
    }
    
    var canSave: Bool {
        !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func nameChangedTo(_ name: String) {
        self.newName = name
    }
    
    func saveName() throws {
        guard canSave else { throw CategoryError.empty }
        // Verify name is changed
        let newName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard newName.lowercased() != category.name!.lowercased() else {
            return
        }
        
        // Verify name is unique
        let fetchRequest = Category.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(Category.name), newName])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        let count = try context.count(for: fetchRequest)
        guard count == 0 else {
            throw CategoryError.duplicateName
        }
        
        // Name is valid, update it
        category.name = newName
        try context.save()
    }
}
