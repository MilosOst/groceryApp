//
//  HistoryViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import UIKit
import CoreData

private let cellID = "HistoryCell"
 
class HistoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private lazy var model: HistoryModel = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return HistoryModel(context: context, delegate: self)
    }()
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ShoppingListHistoryCell.self, forCellReuseIdentifier: cellID)
        setupUI()
        
        do {
            try model.loadData()
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    private func setupUI() {
        title = "History"
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfItemsInSection(section)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ShoppingListHistoryCell
        let list = model.shoppingList(at: indexPath)
        cell.configure(with: list)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        model.titleForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = model.shoppingList(at: indexPath)
        let summaryVC = ListSummaryViewController(shoppingList: list)
        navigationController?.pushViewController(summaryVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try? model.deleteList(at: indexPath)
        }
    }
    
    // MARK: NSFetchedResultsController Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard isVisible else { return }
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard isVisible else { return }
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            tableView.reloadData()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard isVisible else { return }
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [indexPath!], with: .automatic)
        default:
            tableView.reloadData()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard isVisible else { return }
        tableView.endUpdates()
    }
}
