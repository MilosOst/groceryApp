//
//  InventoryItem+CoreDataProperties.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-01.
//
//

import Foundation
import CoreData


extension InventoryItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InventoryItem> {
        return NSFetchRequest<InventoryItem>(entityName: "InventoryItem")
    }

    @NSManaged public var image: Data?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var name: String?
    @NSManaged public var unit: String?
    @NSManaged public var category: Category?
    @NSManaged public var listItems: NSSet?
    @NSManaged public var templateItems: NSSet?

}

// MARK: Generated accessors for listItems
extension InventoryItem {

    @objc(addListItemsObject:)
    @NSManaged public func addToListItems(_ value: ListItem)

    @objc(removeListItemsObject:)
    @NSManaged public func removeFromListItems(_ value: ListItem)

    @objc(addListItems:)
    @NSManaged public func addToListItems(_ values: NSSet)

    @objc(removeListItems:)
    @NSManaged public func removeFromListItems(_ values: NSSet)

}

// MARK: Generated accessors for templateItems
extension InventoryItem {

    @objc(addTemplateItemsObject:)
    @NSManaged public func addToTemplateItems(_ value: TemplateItem)

    @objc(removeTemplateItemsObject:)
    @NSManaged public func removeFromTemplateItems(_ value: TemplateItem)

    @objc(addTemplateItems:)
    @NSManaged public func addToTemplateItems(_ values: NSSet)

    @objc(removeTemplateItems:)
    @NSManaged public func removeFromTemplateItems(_ values: NSSet)

}
