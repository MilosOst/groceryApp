//
//  DetailedListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-04.
//

import UIKit
import CoreData

private let cellIdentifier = "ItemCell"

class DetailedListViewController: UITableViewController, SelectInventoryItemDelegate, NSFetchedResultsControllerDelegate {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let shoppingList: ShoppingList
    private lazy var fetchedItemsController: NSFetchedResultsController<ListItem> = {
        let fetchRequest = ListItem.fetchRequest()
        let predicate = NSPredicate(format: "list == %@", shoppingList)
        let sortByChecked = NSSortDescriptor(key: #keyPath(ListItem.isChecked), ascending: true)
        let sortByName = NSSortDescriptor(key: #keyPath(ListItem.item.name), ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortByChecked, sortByName]
        
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        return resultsController
    }()
    
    private lazy var service: ShoppingListService = {
        return ShoppingListService(context: context, fetchedResultsController: fetchedItemsController, list: shoppingList)
    }()
    
    private let middleButton = UIBarButtonItem()
    
    init(list: ShoppingList) {
        self.shoppingList = list
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        do {
            try fetchedItemsController.performFetch()
            print("Success, returned \(fetchedItemsController.fetchedObjects?.count ?? -1)")
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        tableView.register(ShoppingListItemCell.self, forCellReuseIdentifier: cellIdentifier)
            
        // Set up navbar
        title = shoppingList.name
        let optionsButton = UIBarButtonItem()
        optionsButton.image = UIImage(systemName: "ellipsis.circle")
        navigationItem.rightBarButtonItem = optionsButton
        
        setupToolbar()
        setPlainBackButton()
    }
    
    private func setupToolbar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
        let attrs = [NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        middleButton.setTitleTextAttributes(attrs, for: .disabled)
        middleButton.isEnabled = false
        configureMiddleButton()
        setToolbarItems([.flexibleSpace(), middleButton, .flexibleSpace(), addButton], animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    /// Configures the title for the middle buton
    private func configureMiddleButton() {
        let itemCount = fetchedItemsController.fetchedObjects?.count ?? 0
        middleButton.title = "\(itemCount) \(itemCount != 1 ? "Items" : "Item")"
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedItemsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        configureMiddleButton()
        return fetchedItemsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ShoppingListItemCell
        let item = fetchedItemsController.object(at: indexPath)
        cell.configure(with: item, handler: { cell in
            self.checkButtonPressed(cell)
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedItemsController.sections?[section].name
    }
    
    // MARK: - Actions
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Present InventoryItem selection
        let destVC = SelectInventoryItemViewController(delegate: self)
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    private func checkButtonPressed(_ sender: ShoppingListItemCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        service.checkItem(fetchedItemsController.object(at: indexPath))
    }
    
    // MARK: - Item Selection Delegate methods
    func didToggleItem(_ item: InventoryItem) {
        service.toggleItem(item)
    }
    
    func isItemSelected(_ item: InventoryItem) -> Bool {
        return service.isItemSelected(item)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard self == navigationController?.topViewController else {
            return
        }
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // Do not process request if not current viewcontroller
        guard self == navigationController?.topViewController else {
            return
        }
        
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard self == navigationController?.topViewController else {
            return
        }
        self.tableView.endUpdates()
    }
}
