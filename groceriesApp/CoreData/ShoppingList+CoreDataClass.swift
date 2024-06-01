//
//  ShoppingList+CoreDataClass.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-01.
//
//

import Foundation
import CoreData

@objc(ShoppingList)
public class ShoppingList: NSManagedObject {
    @objc var completionDateSection: String {
        guard let completionDate = completionDate else {
            return ""
        }
        
        let calendar = Calendar.current
        if calendar.isDate(completionDate, equalTo: Date(), toGranularity: .weekOfYear) {
            return "This Week"
        } else if calendar.isDate(completionDate, equalTo: Date(), toGranularity: .month) {
            return "This Month"
        } else {
            return "Older"
        }
    }
}
