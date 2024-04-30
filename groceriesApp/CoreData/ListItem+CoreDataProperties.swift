//
//  ListItem+CoreDataProperties.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-04-30.
//
//

import Foundation
import CoreData


extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var quantity: Float
    @NSManaged public var item: InventoryItem?
    @NSManaged public var list: ShoppingList?

}
