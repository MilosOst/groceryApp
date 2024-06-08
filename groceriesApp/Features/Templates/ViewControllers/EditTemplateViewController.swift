//
//  EditTemplateViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import UIKit
import CoreData

private let cellID = "TemplateItemCell"

class EditTemplateViewController: UITableViewController, NSFetchedResultsControllerDelegate, EditTemplateMenuDelegate {
    private var model: EditTemplateModel!
    private lazy var optionsMenu: EditTemplateMenuView = {
        let sortOrder = ListItemsSortOption(rawValue: model.template.sortOrder) ?? .category
        return EditTemplateMenuView(sortOrder: sortOrder, delegate: self)
    }()
    
    private lazy var costLabel: UIBarButtonItem = {
        let button = UIBarButtonItem()
        let attrs = [NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        button.setTitleTextAttributes(attrs, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    init(template: Template) {
        super.init(style: .grouped)
        self.model = EditTemplateModel(template: template, context: coreDataContext, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TemplateItemCell.self, forCellReuseIdentifier: cellID)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: nil)
        
        do {
            try model.loadData()
            tableView.reloadData()
        } catch {
            print(error)
            presentPlainErrorAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        setupNavbar()
        setupToolbar()
    }
    
    private func setupNavbar() {
        title = model.templateName
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
        let optionsButton = UIBarButtonItem()
        optionsButton.image = UIImage(systemName: "ellipsis.circle")
        optionsButton.menu = optionsMenu.menu
        navigationItem.rightBarButtonItem = optionsButton
        navigationItem.backBarButtonItem = .createEmptyButton()
    }
    
    private func setupToolbar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed(_:)))
        setToolbarItems([.flexibleSpace(), costLabel, .flexibleSpace(), addButton], animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }

    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfItemsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TemplateItemCell
        cell.configure(with: model.item(at: indexPath))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sectionName(for: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 40 : 25
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try? model.deleteItem(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = model.item(at: indexPath)
        let editVC = EditTemplateItemsViewController(template: model.template, startItem: item)
        let navVC = UINavigationController(rootViewController: editVC)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.medium()]
        navVC.sheetPresentationController?.prefersGrabberVisible = true
        navVC.view.backgroundColor = .systemBackground
        present(navVC, animated: true)
    }
    
    // MARK: - Actions
    @objc func addPressed(_ sender: UIBarButtonItem) {
        let destVC = SelectInventoryItemViewController(delegate: model)
        navigationController?.pushViewController(destVC, animated: true)
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
        tableView.endUpdates()
    }
    
    // MARK: - Options Menu Delegate
    func didSelectSortOption(_ option: ListItemsSortOption) {
        if (model.setSortOrder(option)) {
            tableView.reloadData()
        }
    }
    
    func didSelectCreateList() {
        do {
            let newList = try model.createList()
            navigationController?.pushViewController(EditShoppingListViewController(list: newList), animated: true)
        } catch {
            print(error)
            presentPlainErrorAlert()
        }
    }
    
    func didSelectRename() {
        let alert = UIAlertController.makeTextFieldAlert(title: "Rename Template", message: "Enter the new name for the template below.", placeholder: "Name", text: model.templateName, handler: { [self] newName in
            do {
                try model.setName(to: newName)
                title = model.templateName
            } catch EntityCreationError.emptyName {
                presentAlert(title: "Invalid Name", message: "Template name must not be empty.")
            } catch EntityCreationError.duplicateName {
                presentAlert(title: "Duplicate Name", message: "This name is already taken.")
            } catch {
                presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
    
    func didSelectDelete() {
        let alert = UIAlertController.makeDeleteDialog(title: "Delete List", message: "This action cannot be undone.", handler: { [self] _ in
            do {
                try model.deleteTemplate()
                navigationController?.popViewController(animated: true)
            } catch {
                presentPlainErrorAlert()
            }
        })
        
        present(alert, animated: true)
    }
}
