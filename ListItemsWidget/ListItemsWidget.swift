//
//  ListItemsWidget.swift
//  ListItemsWidget
//
//  Created by Milos Abcd on 2024-06-20.
//

import WidgetKit
import SwiftUI
import CoreData

struct ListItemsWidgetEntry: TimelineEntry {
    let date: Date
    let name: String
    let items: [ListItemsWidgetItem]
    let listID: String?
}

struct ListItemsWidgetItem: Identifiable {
    let id: String
    let name: String
    let price: Double
    let quantity: Float
    let unit: String?
}

struct ListItemsWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: ListItemsIntentProvider.Entry
    
    private var deepLink: URL {
        URL(string: "kaufList://shoppingList/\(entry.listID ?? "")")!
    }
    
    private var maxCount: Int {
        return (family == .systemMedium) ? 4 : 12
    }

    var body: some View {
        Link(destination: deepLink) {
            VStack {
                HStack {
                    Text(entry.name)
                        .font(.system(size: 16).bold())
                    
                    Spacer()
                    
                    Text("\(entry.items.count)")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .padding(6)
                        .clipShape(.circle)
                        .background(
                            Color.blue
                                .clipShape(.circle)
                        )
                }
                
                Divider()
                
                VStack(spacing: 6) {
                    ForEach(entry.items.prefix(maxCount)) { item in
                        ListItemWidgetView(item: item)
                    }
                }
                
                Spacer()
            }
        }
    }
}

fileprivate struct ListItemWidgetView: View {
    let item: ListItemsWidgetItem
    
    private var quantityStr: String {
        if let unit = item.unit {
            return "(\(item.quantity.formatted()) \(unit))"
        }
        return item.quantity.formatted()
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Text(item.name)
                    .font(.system(size: 15))
                
                if item.quantity != 0 {
                    Text(quantityStr)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if item.price != 0 {
                Text(item.price.currencyStr)
                    .font(.system(size: 14).bold())
                    .foregroundStyle(.green)
            }
        }
    }
}

struct ListItemsIntentProvider: IntentTimelineProvider {
    typealias Entry = ListItemsWidgetEntry
    
    typealias Intent = ListProgressConfigurationIntent
    
    private var container: NSPersistentContainer {
        PersistenceController.shared.container
    }
    
    private var emptyEntry: Entry {
        Entry(date: Date(), name: "Placeholder", items: [], listID: nil)
    }
    
    func placeholder(in context: Context) -> Entry {
        ListItemsWidgetEntry(date: Date(), name: "Essentials2", items: [
            ListItemsWidgetItem(id: "0", name: "Milk", price: 2.99, quantity: 1, unit: "L"),
            ListItemsWidgetItem(id: "1", name: "Eggs", price: 4.99, quantity: 0, unit: nil),
            ListItemsWidgetItem(id: "2", name: "Rice", price: 2.09, quantity: 1, unit: "kg")
        ], listID: nil)
    }
    
    private func fetchData(for configuration: ListProgressConfigurationIntent) -> Entry {
        guard let identifier = configuration.shoppingList?.identifier, let objectIDURL = URL(string: identifier) else {
            return emptyEntry
        }
        
        guard let objectID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: objectIDURL) else {
            return emptyEntry
        }
        
        guard let list = try? container.viewContext.existingObject(with: objectID) as? ShoppingList, list.completionDate == nil else {
            return emptyEntry
        }
        
        // Create fetch request for non-checked items using current sort order
        let fetchRequest = ListItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "list == %@ AND isChecked == NO", list)
        var sortDescriptors = [NSSortDescriptor(key: #keyPath(ListItem.item.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        if list.sortOrder == ListItemsSortOption.category.rawValue {
            let sortByCategory = NSSortDescriptor(key: #keyPath(ListItem.item.category.name), ascending: true)
            sortDescriptors.insert(sortByCategory, at: 0)
        }
        
        // Perform fetch
        let viewContext = container.viewContext
        do {
            let items = try viewContext.fetch(fetchRequest).map {
                ListItemsWidgetItem(id: "\($0.id)", name: $0.item?.name ?? "", price: Double($0.price), quantity: $0.quantity, unit: $0.unit)
            }
            return Entry(date: Date(), name: list.name!, items: items, listID: list.objectID.uriRepresentation().absoluteString)
        } catch {
            return emptyEntry
        }
    }
    
    func getSnapshot(for configuration: ListProgressConfigurationIntent, in context: Context, completion: @escaping (ListItemsWidgetEntry) -> Void) {
        let entry = fetchData(for: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ListProgressConfigurationIntent, in context: Context, completion: @escaping (Timeline<ListItemsWidgetEntry>) -> Void) {
        let data = fetchData(for: configuration)
        let timeline = Timeline(entries: [data], policy: .atEnd)
        completion(timeline)
    }
    
}

struct ListItemsWidget: Widget {
    let kind: String = "com.MilosOst.KaufList.ListItemsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ListProgressConfigurationIntent.self,
                            provider: ListItemsIntentProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                ListItemsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ListItemsWidgetEntryView(entry: entry)
                    .padding()
            }
        }
        .configurationDisplayName("List Items")
        .description("View outstanding items in a selected list.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
