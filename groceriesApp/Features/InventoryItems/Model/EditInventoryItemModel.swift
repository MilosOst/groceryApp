//
//  EditInventoryItemModel.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import Foundation
import CoreData

class EditInventoryItemModel {
    private var editState: InventoryItemCreationState
    private var item: InventoryItem
    private let context: NSManagedObjectContext
    
    init(item: InventoryItem, context: NSManagedObjectContext) {
        self.editState = InventoryItemCreationState(name: item.name ?? "", category: item.category, unit: item.unit, isFavourite: item.isFavourite)
        self.item = item
        self.context = context
    }
    
    var itemName: String {
        editState.name
    }
    
    var itemUnit: String? {
        editState.unit
    }
    
    var category: Category? {
        editState.category
    }
    
    var isFavourite: Bool {
        editState.isFavourite
    }
    
    var canSave: Bool {
        !editState.name.isTrimmedEmpty
    }
    
    // MARK: - Editing Methods
    func setName(to name: String?) {
        editState.name = name ?? ""
    }
    
    func setCategory(_ category: Category?) {
        editState.category = category
    }
    
    func setUnit(to unit: String?) {
        editState.unit = unit ?? ""
    }
    
    func setIsFavourite(to newVal: Bool) {
        editState.isFavourite = newVal
    }
    
    private func validateName() throws {
        let name = editState.name.trimmed
        guard !name.isEmpty else { throw InventoryItemError.emptyName }
        
        // Verify uniqueness
        guard name != item.name else { return }
        // If name is same (except for case), simply change
        guard name.lowercased() != item.name!.lowercased() else {
            item.name = name
            return
        }
        
        let fetchRequest = InventoryItem.fetchRequest()
        let predicate = NSPredicate(format: "%K =[c] %a", argumentArray: [#keyPath(InventoryItem.name), name])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        let count = try context.count(for: fetchRequest)
        if count != 0 {
            throw InventoryItemError.duplicateName
        }
    }
    
    func saveChanges() throws {
        try validateName()
        
        item.name = editState.name.trimmed
        item.unit = editState.unit
        item.category = editState.category
        item.isFavourite = editState.isFavourite
        try context.save()
    }
}
