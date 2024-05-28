//
//  EditTemplateViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import UIKit
import CoreData

private let cellID = "TemplateItemCell"

class EditTemplateViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private var model: EditTemplateModel!
    
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
        
        do {
            try model.loadData()
            tableView.reloadData()
        } catch {
            print(error)
            presentPlainErrorAlert()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: nil)
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
        // TODO: Add options menu
        navigationItem.rightBarButtonItem = optionsButton
        navigationItem.backBarButtonItem = .createEmptyButton()
    }
    
    private func setupToolbar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed(_:)))
        setToolbarItems([.flexibleSpace(), addButton], animated: true)
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
        var categoriesDidChange = false
        if let changes = notification.userInfo?["updated"] as? Set<NSManagedObject> {
            for object in changes {
                if let object = object as? Category {
                    categoriesDidChange = true
                }
            }
        }
        
        // If categories changed, reload data
        // TODO: What if deleting item? Do not trigger change
        if categoriesDidChange {
            do {
                try model.loadData()
                tableView.reloadData()
                print("Reloading")
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
}
