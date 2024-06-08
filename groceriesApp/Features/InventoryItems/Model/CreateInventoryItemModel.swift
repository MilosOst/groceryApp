//
//  CreateInventoryItemModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-14.
//

import Foundation
import CoreData

enum InventoryItemError: Error {
    case emptyName
    case duplicateName
}

class CreateInventoryItemModel: CategorySelectorDelegate {
    private(set) var itemState = InventoryItemCreationState()
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var canSave: Bool {
        !itemState.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var categoryName: String? {
        itemState.category?.name
    }
    
    func setName(_ name: String?) {
        itemState.name = name ?? ""
    }
    
    func setUnit(_ unit: String?) {
        itemState.unit = unit ?? ""
    }
    
    func setCategory(_ category: Category?) {
        itemState.category = category
    }
    
    func setFavourite(_ isFavourite: Bool) {
        itemState.isFavourite = isFavourite
    }
    
    func createItem() throws {
        // Verify name is non-empty
        let name = itemState.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw InventoryItemError.emptyName }
        
        // Verify name is unique
        let fetchRequest = InventoryItem.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(InventoryItem.name), name])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        let count = try context.count(for: fetchRequest)
        guard count == 0 else { throw InventoryItemError.duplicateName }
        
        // Item is validate, create it
        let item = InventoryItem(context: context)
        item.name = name
        item.category = itemState.category
        item.unit = itemState.unit
        item.isFavourite = itemState.isFavourite
        try context.save()
    }
    
    func didSelectCategory(_ category: Category?) {
        setCategory(category)
    }
}
