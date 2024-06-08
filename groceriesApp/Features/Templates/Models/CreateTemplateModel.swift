//
//  CreateTemplateModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import Foundation
import CoreData

class CreateTemplateModel {
    private let context: NSManagedObjectContext
    private(set) var creationState = CreateTemplateObject()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var canSave: Bool {
        !creationState.name.trimmed.isEmpty
    }
    
    func setName(_ name: String?) {
        creationState.name = name ?? ""
    }
    
    func setSortOrder(_ order: ListItemsSortOption) {
        creationState.sortOrder = order
    }
    
    private func validateData() throws {
        let name = creationState.name.trimmed
        guard !name.isEmpty else { throw EntityCreationError.emptyName }
        
        // Check for duplicate name
        let fetchRequest = Template.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(Template.name), name])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        let count = try? context.count(for: fetchRequest)
        guard count == 0 else { throw EntityCreationError.duplicateName }
    }
    
    func save() throws {
        try validateData()
        let template = Template(context: context)
        template.name = creationState.name.trimmed
        template.sortOrder = creationState.sortOrder.rawValue
        try? context.save()
    }
}
