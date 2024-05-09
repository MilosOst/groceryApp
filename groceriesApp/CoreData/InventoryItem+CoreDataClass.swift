//
//  InventoryItem+CoreDataClass.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-09.
//
//

import Foundation
import CoreData

@objc(InventoryItem)
public class InventoryItem: NSManagedObject {
    @objc var categoryName: String {
        if let name = category?.name {
            return name
        }
        return "Uncategorized"
    }
}
