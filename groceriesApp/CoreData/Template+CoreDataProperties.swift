//
//  Template+CoreDataProperties.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-08.
//
//

import Foundation
import CoreData


extension Template {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Template> {
        return NSFetchRequest<Template>(entityName: "Template")
    }

    @NSManaged public var isFavourite: Bool
    @NSManaged public var itemCount: Int16
    @NSManaged public var name: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension Template {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: TemplateItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: TemplateItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
