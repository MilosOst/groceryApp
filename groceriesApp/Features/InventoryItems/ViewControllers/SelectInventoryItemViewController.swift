//
//  SelectInventoryItemViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-04.
//

import UIKit
import CoreData

protocol SelectInventoryItemDelegate: AnyObject {
    func didToggleItem(_ item: InventoryItem)
    
    func isItemSelected(_ item: InventoryItem) -> Bool
}

private let cellIdentifier = "ItemCell"

class SelectInventoryItemViewController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    
    weak var delegate: SelectInventoryItemDelegate?
    private lazy var model: SelectInventoryItemModel = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return SelectInventoryItemModel(context: context, delegate: self)
    }()
    
    private let searchController = UISearchController()
    
    init(delegate: SelectInventoryItemDelegate? = nil) {
        super.init(style: .grouped)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.reloadData()
    }
    
    private func setupUI() {
        let filterButton = UIBarButtonItem()
        filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
        navigationItem.rightBarButtonItem = filterButton
        
        // Set up search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        let createItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createButtonPressed(_:)))
        setToolbarItems([.flexibleSpace(), .flexibleSpace(), createItemButton], animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        navigationItem.titleView = searchController.searchBar
        
        tableView.register(InventoryItemSelectionCell.self, forCellReuseIdentifier: cellIdentifier)
        
    }

    // MARK: - UITableViewDataSource Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfItems
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InventoryItemSelectionCell
        let item = model.item(at: indexPath)
        cell.configure(name: item.name ?? "", isFavourite: item.isFavourite, isSelected: delegate?.isItemSelected(item) ?? false)
        return cell
    }
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = model.item(at: indexPath)
        delegate?.didToggleItem(item)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard model.numberOfItems > 0 else { return }
        if editingStyle == .delete {
            let alert = UIAlertController.makeDeleteDialog(title: "Delete Item?", message: "This will also remove all list/template items associated with this item. This action cannot be undone.", handler: { [self] _ in
                do {
                    try self.model.deleteItem(at: indexPath)
                } catch {
                    self.presentPlainErrorAlert()
                }
            })
            present(alert, animated: true)
        }
    }
    
    // MARK: - NSFetchedResultsController Delgate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            tableView.reloadData()
        }
    }
    
    // MARK: - UISearchResultsUpdating Methods
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        do {
            if (try model.processSearch(text)) {
                tableView.reloadData()
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Actions
    @objc func createButtonPressed(_ sender: UIBarButtonItem) {
        let createItemVC = CreateItemSheetController()
        createItemVC.modalPresentationStyle = .pageSheet
        if let sheetPresentationController = createItemVC.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
        }
        
        present(createItemVC, animated: true)
    }
}
