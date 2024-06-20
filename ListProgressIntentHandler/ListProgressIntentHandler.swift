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
    private var container: NSPersistentContainer {
        PersistenceController.shared.container
    }
    
    private func fetchActiveLists() -> [IntentShoppingList] {
        let context = container.viewContext
        let fetchRequest = ShoppingList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "completionDate == nil")
        var results = [IntentShoppingList]()
        
        // Perform fetch and map to intent entity
        do {
            let lists = try context.fetch(fetchRequest)
            results = lists.map { IntentShoppingList(identifier: $0.objectID.uriRepresentation().absoluteString, display: $0.name!) }
        } catch {
            
        }
        
        return results
    }
    
    func provideShoppingListOptionsCollection(for intent: ListProgressConfigurationIntent) async throws -> INObjectCollection<IntentShoppingList> {
        let context = container.viewContext
        let fetchRequest = ShoppingList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "completionDate == nil")
        var results: [IntentShoppingList] = fetchActiveLists()
        let collection = INObjectCollection(items: results)
        return collection
    }
    
    func defaultShoppingList(for intent: ListProgressConfigurationIntent) -> IntentShoppingList? {
        return fetchActiveLists().first
    }
}
