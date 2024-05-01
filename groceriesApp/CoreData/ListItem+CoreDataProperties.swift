//
//  ListItem+CoreDataProperties.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-01.
//
//

import Foundation
import CoreData


extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var quantity: Float
    @NSManaged public var isChecked: Bool
    @NSManaged public var item: InventoryItem?
    @NSManaged public var list: ShoppingList?

}
