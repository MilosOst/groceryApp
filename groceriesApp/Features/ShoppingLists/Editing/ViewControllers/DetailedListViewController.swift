//
//  DetailedListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-04.
//

import UIKit
import CoreData

private let cellIdentifier = "ItemCell"

class DetailedListViewController: UITableViewController, NSFetchedResultsControllerDelegate, ListDetailMenuDelegate {
    private let shoppingList: ShoppingList
    private lazy var model: EditListModel = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let model = EditListModel(context: context, list: shoppingList, fetchedResultsControllerDelegate: self)
        return model
    }()
    
    private let middleButton = UIBarButtonItem()
    private lazy var optionsMenu: ListDetailMenuView = {
        return ListDetailMenuView(sortOption: ListItemsSortOption(rawValue: shoppingList.sortOrder) ?? .category, delegate: self)
    }()
    
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
            try model.loadData()
            tableView.reloadData()
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
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
        let optionsButton = UIBarButtonItem()
        optionsButton.image = UIImage(systemName: "ellipsis.circle")
        optionsButton.menu = optionsMenu.menu
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
        let itemCount = model.numberOfItems
        middleButton.title = "\(itemCount) \(itemCount != 1 ? "Items" : "Item")"
    }

    // MARK: - UITableViewDataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        configureMiddleButton()
        return model.numberOfItemsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ShoppingListItemCell
        let item = model.item(at: indexPath)
        cell.configure(with: item, handler: { [weak self] cell in
            self?.checkButtonPressed(cell)
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sectionName(for: section)
    }
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = model.item(at: indexPath)
        
        let destVC = EditListItemsViewController(shoppingList: shoppingList, startItem: selectedItem, delegate: self)
        let navVC = UINavigationController(rootViewController: destVC)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.medium()]
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
                try model.deleteItem(at: indexPath)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard isTopViewController else { return }
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard isTopViewController else { return }
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
        @unknown default:
            tableView.reloadData()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard isTopViewController else { return }
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard isTopViewController else { return }
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Present InventoryItem selection
        let destVC = SelectInventoryItemViewController(delegate: model)
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    private func checkButtonPressed(_ sender: ShoppingListItemCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        do {
            try model.checkedItem(at: indexPath)
        } catch {
            presentPlainErrorAlert()
        }
    }
    
    // MARK: - ListDetailMenuDelegate Methods
    func didSelectSortOption(_ option: ListItemsSortOption) {
        let prevOrder = model.sortOrder
        let updatedOrder = model.changedSortOption(to: option)
        if (prevOrder != updatedOrder) {
            tableView.reloadData()
        }
    }
    
    func didSelectDelete() {
        let alert = UIAlertController.makeDeleteDialog(title: "Delete List?", message: "Are you sure you want to delete this list? This action cannot be undone.", handler: { [self] _ in
            do {
                try self.model.deleteList()
                navigationController?.popViewController(animated: true)
            } catch {
                presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
    
    func didSelectMarkComplete() {
        do {
            try model.markComplete()
            navigationController?.popViewController(animated: true)
        } catch {
            presentPlainErrorAlert()
        }
    }
}

// Add delegate conformance to reload rows when InventoryItem changes
extension DetailedListViewController: ListEditDelegate {
    func didChangeItemUnit(_ item: ListItem) {
        if let indexPath = model.indexPath(forItem: item) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
