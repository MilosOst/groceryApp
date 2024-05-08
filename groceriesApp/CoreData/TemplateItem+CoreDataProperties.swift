//
//  TemplateItem+CoreDataProperties.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-08.
//
//

import Foundation
import CoreData


extension TemplateItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplateItem> {
        return NSFetchRequest<TemplateItem>(entityName: "TemplateItem")
    }

    @NSManaged public var quantity: Float
    @NSManaged public var item: InventoryItem?
    @NSManaged public var template: Template?

}
