//
//  IntentHandler.swift
//  ListProgressIntentHandler
//
//  Created by Milos Abcd on 2024-06-19.
//

import Intents
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}


extension IntentHandler: ListProgressConfigurationIntentHandling {
    func provideShoppingListOptionsCollection(for intent: ListProgressConfigurationIntent) async throws -> INObjectCollection<IntentShoppingList> {
        let container = PersistenceController.shared.container
        
        let context = container.viewContext
        let fetchRequest = ShoppingList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "completionDate == nil")
        var results = [IntentShoppingList]()
        do {
            let lists = try context.fetch(fetchRequest)
            results = lists.map {
                let list = IntentShoppingList(identifier: $0.objectID.uriRepresentation().absoluteString, display: $0.name!)
                list.totalCost = $0.totalCost as NSNumber
                list.totalItems = $0.itemCount as NSNumber
                list.checkedItems = $0.checkedItemsCount as NSNumber
                return list
            }
        } catch {
            
        }
        
        let collection = INObjectCollection(items: results)
        return collection
    }
    
    func defaultShoppingList(for intent: ListProgressConfigurationIntent) -> IntentShoppingList? {
        // TODO: Show first list by default
        return nil
    }
}
