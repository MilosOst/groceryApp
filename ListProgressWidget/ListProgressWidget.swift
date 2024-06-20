//
//  ListProgressWidget.swift
//  ListProgressWidget
//
//  Created by Milos Abcd on 2024-06-18.
//

import WidgetKit
import SwiftUI
import CoreData
import Intents

struct ListProgressEntry: TimelineEntry {
    var date: Date
    var name: String
    var checkedItems: Int16
    var totalItems: Int16
    var totalCost: Double
    var identifier: String?
}

struct ListProgressWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: ListProgressIntentProvider.Entry
    
    private var progress: Float {
        Float(entry.checkedItems) / Float(entry.totalItems)
    }
    
    private var deepLink: URL {
        URL(string: "kaufList://shoppingList/\(entry.identifier ?? "")")!
    }
    
    var body: some View {
        switch family {
        case .systemSmall:
            VStack(spacing: 8) {
                ProgressView(value: progress) {
                    Text("\(entry.checkedItems)/\(entry.totalItems)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                }
                .progressViewStyle(.circular)
                .tint(.blue)
                
                Text(entry.name)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .widgetURL(deepLink)
        case .systemMedium:
            Link(destination: deepLink) {
                HStack(spacing: 24) {
                    ProgressView(value: progress)
                        .progressViewStyle(.circular)
                        .tint(.blue)
                        .scaleEffect(0.9)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.name)
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bought")
                                .font(.system(size: 14).bold())
                                .foregroundStyle(.secondary)
                            
                            Text("\(entry.checkedItems)/\(entry.totalItems)")
                                .font(.system(size: 16).bold())
                                .foregroundStyle(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cost")
                                .font(.system(size: 14).bold())
                                .foregroundStyle(.secondary)
                            
                            Text(entry.totalCost.currencyStr)
                                .font(.system(size: 16).bold())
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Spacer()
                }
            }
        default:
            Text("Not Available")
        }
    }
}

struct ListProgressIntentProvider: IntentTimelineProvider {
    private var container: NSPersistentContainer {
        PersistenceController.shared.container
    }
    
    func placeholder(in context: Context) -> ListProgressEntry {
        ListProgressEntry(date: Date(), name: "Shopping List", checkedItems: 0, totalItems: 10, totalCost: 19.99)
    }
    
    private func fetchShoppingList(for configuration: ListProgressConfigurationIntent) -> ShoppingList? {
        // Return entry instead of shopping list
        guard let identifier = configuration.shoppingList?.identifier, let objectIDURL = URL(string: identifier) else {
            return nil
        }
        
        guard let objectID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: objectIDURL) else {
            return nil
        }
        
        
        if let list = try? container.viewContext.existingObject(with: objectID) as? ShoppingList, list.completionDate == nil {
            return list
        }
        return nil
    }
    
    private func progressEntry(for configuration: ListProgressConfigurationIntent) -> ListProgressEntry {
        if let shoppingList = fetchShoppingList(for: configuration) {
            return ListProgressEntry(date: Date(), name: shoppingList.name!, checkedItems: shoppingList.checkedItemsCount, totalItems: shoppingList.itemCount, totalCost: shoppingList.totalCost)
        }
        return ListProgressEntry(date: Date(), name: "Placeholder", checkedItems: 0, totalItems: 0, totalCost: 0)
    }

    func getSnapshot(for configuration: ListProgressConfigurationIntent, in context: Context, completion: @escaping (ListProgressEntry) -> Void) {
        let entry = progressEntry(for: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ListProgressConfigurationIntent, in context: Context, completion: @escaping (Timeline<ListProgressEntry>) -> Void) {
        var entry = ListProgressEntry(date: Date(), name: "Snapshot", checkedItems: 0, totalItems: 0, totalCost: 0)
        if let shoppingList = fetchShoppingList(for: configuration) {
            entry = ListProgressEntry(date: Date(), name: shoppingList.name!, checkedItems: shoppingList.checkedItemsCount, totalItems: shoppingList.itemCount, totalCost: shoppingList.totalCost, identifier: shoppingList.objectID.uriRepresentation().absoluteString)
        }
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct ListProgressWidget: Widget {
    let kind: String = "com.MilosOst.KaufList.ListProgressWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ListProgressConfigurationIntent.self,
            provider: ListProgressIntentProvider()) { entry in
                if #available(iOS 17.0, *) {
                    ListProgressWidgetEntryView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    ListProgressWidgetEntryView(entry: entry)
                        .background()
                }
            }
            .configurationDisplayName("Progress")
            .description("Quickly view progess for a given shopping list.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}
