//
//  PersistenceController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-19.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    private let databaseName = "groceriesApp.sqlite"
    
    private var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(databaseName)
    }
    
    private var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.MilosOst.KaufList")!
        return container.appendingPathComponent(databaseName)
    }

    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "groceriesApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            print("Old store doesn't exist, using new store")
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private func migrateStore(for container: NSPersistentContainer) {
        let coordinator = container.persistentStoreCoordinator
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else {
            print("Old store no longer exists")
            return
        }
        
        // Migrate from old store to shared store
        do {
            let _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
        } catch {
            fatalError("Unable to migrate to shared store")
        }
        
        // Delete old store once finished
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch {
            print("Unable to delete old store")
        }
    }
}
