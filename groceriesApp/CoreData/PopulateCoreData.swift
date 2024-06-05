//
//  PopulateCoreData.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-05.
//

import CoreData

/// Function to prepopulate
func populateCoreData(context: NSManagedObjectContext) throws {
    let categoryNames = ["Produce", "Dairy & Eggs", "Meat", "Seafood", "Bakery", "Grains", "Frozen", "Beverages", "Spices"]
    
    var categories: [String: Category] = [:]
    for name in categoryNames {
        let category = Category(context: context)
        category.name = name
        categories[name] = category
    }
    
    // Initialize InventoryItems
    let categoryItems: [String: Set<String>] = [
        "Produce": [
            "Apples", "Bananas", "Carrots", "Lettuce", "Tomatoes", "Potatoes", "Onions", "Blueberries",
            "Strawberries", "Lemons", "Broccoli", "Garlic", "Bell Peppers", "Oranges"
        ],
        "Dairy & Eggs": [
            "Milk", "Yogurt", "Cheese", "Butter", "Sour Cream", "Coffee Creamer", "Eggs"
        ],
        "Meat": [
            "Beef", "Ground Beef", "Ham", "Chicken", "Chicken Breast", "Steak", "Sausage"
        ],
        "Seafood": [
            "Salmon", "Shrimp", "Tilapia", "Cod", "Tuna", "Crab", "Lobster"
        ],
        "Bakery": [
            "Bread", "Baguette", "Croissants", "Bagels", "Donuts", "Muffins"
        ],
        "Grains": [
            "Rice", "Pasta", "Bulgur", "Oats", "Macaroni", "Quinoa", "Barley", "Spaghetti"
        ],
        "Frozen": [
            "Frozen Vegetables", "Ice", "Ice Cream", "Waffles", "French Fries", "Frozen Peas", "Frozen Pizza"
        ],
        "Beverages": [
            "Water", "Lemonade", "Soda", "Coffee", "Juice"
        ],
        "Spices": [
            "Salt", "Black Pepper", "Cumin", "Oregano", "Paprika", "Cinammon", "Chili Powder", "Ginger"
        ]
    ]
    
    // Define starter list and its items
    let starterList = ShoppingList(context: context)
    starterList.name = "Starter List"
    starterList.creationDate = Date()
    let starterListItems: Set<String> = ["Apples", "Milk", "Oranges", "Eggs", "Lettuce", "Tomatoes", "Bananas", "Rice", "Chicken Breast"]
    
    // Also define starter template
    
    for categoryName in categoryNames {
        let category: Category = categories[categoryName]!
        for itemName in categoryItems[categoryName]! {
            let item = InventoryItem(context: context)
            item.name = itemName
            item.category = category
            
            if starterListItems.contains(itemName) {
                let shoppingListItem = ListItem(context: context)
                shoppingListItem.item = item
                starterList.addToItems(shoppingListItem)
            }
        }
    }
    
    try context.save()
    context.refresh(starterList, mergeChanges: true)
}
