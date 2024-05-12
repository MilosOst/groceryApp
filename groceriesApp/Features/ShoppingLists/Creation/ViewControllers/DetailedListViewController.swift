//
//  DetailedListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-04.
//

import UIKit
import CoreData

fileprivate typealias SortOption = ListItemsSortOption

private let cellIdentifier = "ItemCell"

// TODO: Clean up code
class DetailedListViewController: UITableViewController, SelectInventoryItemDelegate, NSFetchedResultsControllerDelegate {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let shoppingList: ShoppingList
    private lazy var fetchedItemsController: NSFetchedResultsController<ListItem> = {
        let controller = createFetchedResultsController(SortOption(rawValue: shoppingList.sortOrder)!)
        controller.delegate = self
        return controller
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
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        tableView.register(ShoppingListItemCell.self, forCellReuseIdentifier: cellIdentifier)
        setupNavbar()
        setupToolbar()
        setPlainBackButton()
    }
    
    private func setupNavbar() {
        title = shoppingList.name
        let optionsButton = UIBarButtonItem()
        optionsButton.image = UIImage(systemName: "ellipsis.circle")
        
        // Set up sort options
        let sortByName = UIAction(title: "Name", handler: { [weak self] _ in self?.setSortOption(.name) })
        let sortByCategory = UIAction(title: "Category", handler: { [weak self] _ in self?.setSortOption(.category)})
        if shoppingList.sortOrder == SortOption.name.rawValue {
            sortByName.state = .on
        } else {
            sortByCategory.state = .on
        }
        
        let sortMenu = UIMenu(options: [.singleSelection, .displayInline], children: [sortByName, sortByCategory])
        
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in })
        let markCompleteAction = UIAction(title: "Mark Complete", image: UIImage(systemName: "checkmark.circle"), handler: { _ in })
        let actionsMenu = UIMenu(options: .displayInline, children: [markCompleteAction, deleteAction])
        
        
        let optionsMenu = UIMenu(options: .displayInline, children: [sortMenu, actionsMenu])
        
        optionsButton.menu = optionsMenu
        navigationItem.rightBarButtonItem = optionsButton

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
    
    // MARK: - Data Initializaiton
    /// Creates a NSFetchedResultsController for the given sort option.
    /// - NOTE: The delegate is set to nil.
    private func createFetchedResultsController(_ sortOption: ListItemsSortOption) -> NSFetchedResultsController<ListItem> {
        let fetchRequest = ListItem.fetchRequest()
        let predicate = NSPredicate(format: "list == %@", shoppingList)
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ListItem.isChecked), ascending: true),
            NSSortDescriptor(key: #keyPath(ListItem.item.name), ascending: true)
        ]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        // If sorting by category, need to add category sort descriptor and section keypath
        var sectionKeyPath: String? = nil
        if sortOption == .category {
            let sortByCategory = NSSortDescriptor(key: #keyPath(ListItem.item.category.name), ascending: true)
            fetchRequest.sortDescriptors?.insert(sortByCategory, at: 0)
            sectionKeyPath = #keyPath(ListItem.item.categoryName)
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        return controller
    }

    // MARK: - UITableViewDataSource Methods
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
        cell.configure(with: item, handler: { [weak self] cell in
            self?.checkButtonPressed(cell)
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedItemsController.sections?[section].name
    }
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = fetchedItemsController.object(at: indexPath)
        
        let destVC = EditListViewController(shoppingList: shoppingList, startItem: selectedItem, delegate: self)
        let navVC = UINavigationController(rootViewController: destVC)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.custom(resolver: {_ in return 280})]
        navVC.sheetPresentationController?.prefersGrabberVisible = true
        navVC.view.backgroundColor = .systemBackground
        present(navVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try service.deleteItem(at: indexPath)
            } catch {
                print(error)
            }
        }
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard self == navigationController?.topViewController else {
            return
        }
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            return
        }
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
    
    private func setSortOption(_ option: ListItemsSortOption) {
        guard option.rawValue != shoppingList.sortOrder else {
            return
        }
        
        do {
            let newFetchedResultsController = createFetchedResultsController(option)
            do {
                try newFetchedResultsController.performFetch()
                newFetchedResultsController.delegate = self
                fetchedItemsController.delegate = nil
                fetchedItemsController = newFetchedResultsController
                
                shoppingList.sortOrder = option.rawValue
                try context.save()
                service.updateFetchedResultsController(newFetchedResultsController)
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
}

extension DetailedListViewController: ListEditDelegate {
    func didChangeItemUnit(_ item: ListItem) {
        if let indexPath = fetchedItemsController.indexPath(forObject: item) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
