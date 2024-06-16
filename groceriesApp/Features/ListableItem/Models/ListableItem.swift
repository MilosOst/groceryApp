//
//  ListableItem.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-15.
//

import CoreData

@objc protocol ListableItem: AnyObject {
    var notes: String? { get set }
    var price: Float { get set }
    var quantity: Float { get set }
    var unit: String? { get set }
    var item: InventoryItem? { get set }
}
