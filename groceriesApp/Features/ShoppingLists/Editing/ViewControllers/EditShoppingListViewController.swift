//
//  DetailedListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-04.
//

import UIKit
import CoreData
import WidgetKit
import StoreKit

private let cellIdentifier = "ItemCell"

// TODO: Refactor to make smaller?
class EditShoppingListViewController: UITableViewController, NSFetchedResultsControllerDelegate, EditListMenuDelegate {
    public private(set) var model: EditListModel!
    private lazy var optionsMenu: EditListMenuView = {
        return EditListMenuView(sortOrder: ListItemsSortOption(rawValue: model.list.sortOrder) ?? .category, delegate: self)
    }()
    private let middleButton = UIBarButtonItem()
    
    init(list: ShoppingList) {
        super.init(style: .grouped)
        self.model = EditListModel(list: list, context: coreDataContext, delegate: self)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: nil)
        
        do {
            try model.loadData()
            tableView.reloadData()
        } catch {
            presentPlainErrorAlert()
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
    }
    
    private func setupNavbar() {
        title = model.listName
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
        let optionsButton = UIBarButtonItem()
        optionsButton.image = UIImage(systemName: "ellipsis.circle")
        optionsButton.menu = optionsMenu.menu
        navigationItem.rightBarButtonItem = optionsButton
        navigationItem.backBarButtonItem = .createEmptyButton()
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 40 : 25
    }
    
    
    // MARK: - UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = model.item(at: indexPath)
        let editVC = EditShoppingListItemsViewController(shoppingList: model.list, startItem: item)
        let navVC = UINavigationController(rootViewController: editVC)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.medium()]
        navVC.sheetPresentationController?.prefersGrabberVisible = true
        navVC.view.backgroundColor = .systemBackground
        present(navVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try? model.deleteItem(at: indexPath)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - Actions
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        let destVC = SelectInventoryItemViewController(delegate: model)
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    private func checkButtonPressed(_ sender: ShoppingListItemCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        do {
            try model.checkedItem(at: indexPath)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            presentPlainErrorAlert()
        }
    }
    
    @objc func contextDidChange(_ notification: Notification) {
        // Observe updates to existing Categories or InventoryItems
        // that are not detected by fetched results controller
        guard notification.userInfo?.keys.count == 2 else { return }
        var toRefetch = false
        if let changes = notification.userInfo?["updated"] as? Set<NSManagedObject> {
            for object in changes {
                if object is Category || object is InventoryItem {
                    toRefetch = true
                    break
                }
            }
        }
        
        if toRefetch {
            do {
                try model.loadData(forceReload: true)
                tableView.reloadData()
            } catch {
                
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard isTopViewController else { return }
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            tableView.reloadData()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard isTopViewController else { return }
        self.tableView.endUpdates()
    }
    
    // MARK: - ListDetailMenuDelegate Methods
    func didSelectSortOption(_ option: ListItemsSortOption) {
        if (model.setSortOrder(option)) {
            tableView.reloadData()
        }
    }
    
    func didSelectDelete() {
        let alert = UIAlertController.makeDeleteDialog(title: "Delete List?", message: "Are you sure you want to delete this list? This action cannot be undone.", handler: { [self] _ in
            do {
                try self.model.deleteList()
                WidgetCenter.shared.reloadAllTimelines()
                navigationController?.popViewController(animated: true)
            } catch {
                presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
    
    func didSelectMakeList() {
        let alert = UIAlertController.makeTextFieldAlert(
            title: "Create Template",
            message: "Enter the name for your template below.",
            placeholder: "Name",
            text: model.listName,
            handler: { [self] name in
                do {
                    let template = try model.createTemplate(name: name)
                    let editTemplateVC = EditTemplateViewController(template: template)
                    navigationController?.pushViewController(editTemplateVC, animated: true)
                } catch EntityCreationError.emptyName {
                    presentAlert(title: "Invalid Name", message: "Template name must not be empty.")
                } catch EntityCreationError.duplicateName {
                    presentAlert(title: "Duplicate Name", message: "This template name is already in use.")
                } catch {
                    presentPlainErrorAlert()
                }
            })
        present(alert, animated: true)
    }
    
    func didSelectRename() {
        let alert = UIAlertController.makeTextFieldAlert(title: "Rename List", message: "Enter the new name for the list below.", placeholder: "Name", text: model.listName, handler: { [self] newName in
            do {
                try model.setName(to: newName)
                title = model.listName
            } catch EntityCreationError.emptyName {
                presentAlert(title: "Invalid Name", message: "List name must not be empty.")
            } catch {
                presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
    
    func didSelectMarkComplete() {
        do {
            try model.markComplete()
            WidgetCenter.shared.reloadAllTimelines()
            
            // Ask for review if conditions are met
            let completionCount = UserDefaults.standard.integer(forKey: "completionCount")
            UserDefaults.standard.setValue(completionCount + 1, forKey: "completionCount")
            requestReview()
            
            navigationController?.popViewController(animated: true)
        } catch {
            presentPlainErrorAlert()
        }
    }
}
