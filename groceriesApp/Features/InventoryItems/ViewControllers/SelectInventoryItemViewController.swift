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

private let itemCellID = "ItemCell"
private let emptyCellID = "EmptyCell"

class SelectInventoryItemViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    weak var delegate: SelectInventoryItemDelegate?
    private lazy var model: SelectInventoryItemModel = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return SelectInventoryItemModel(context: context, delegate: self)
    }()
    
    private let searchController = UISearchController()
    private var query: String? {
        searchController.searchBar.text
    }
    
    private var queryIsEmpty: Bool {
        if let query = query, !query.isTrimmedEmpty {
            return false
        }
        return true
    }
    
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
        // Set up search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        let createItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createButtonPressed))
        setToolbarItems([.flexibleSpace(), .flexibleSpace(), createItemButton], animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        navigationItem.titleView = searchController.searchBar
        
        tableView.delaysContentTouches = false
        tableView.register(InventoryItemSelectionCell.self, forCellReuseIdentifier: itemCellID)
        tableView.register(NoInventoryItemsViewCell.self, forCellReuseIdentifier: emptyCellID)
        
    }

    // MARK: - UITableViewDataSource Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(model.numberOfItems, 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Show empty results if no results and no query
        if model.numberOfItems == 0 && (query == nil || query!.isTrimmedEmpty) {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as! NoInventoryItemsViewCell
            cell.onButtonTap = { [weak self] in
                self?.createButtonPressed()
            }
            tableView.separatorStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: itemCellID, for: indexPath) as! InventoryItemSelectionCell
            if model.numberOfItems == 0 {
                cell.configure(name: query ?? "", isFavourite: false, isSelected: false)
            } else {
                let item = model.item(at: indexPath)
                cell.configure(name: item.name!, isFavourite: item.isFavourite, isSelected: delegate?.isItemSelected(item) ?? false)
            }
            
            tableView.separatorStyle = .singleLine
            return cell
        }
    }
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard model.numberOfItems > 1 || !queryIsEmpty else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        var item: InventoryItem
        if model.numberOfItems > 0 {
            item = model.item(at: indexPath)
        } else {
            do {
                let query = searchController.searchBar.text ?? ""
                item = try model.createItem(with: query)
            } catch {
                presentPlainErrorAlert()
                return
            }
        }
        
        delegate?.didToggleItem(item)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return model.numberOfItems > 0
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
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = model.item(at: indexPath)
        let editVC = EditInventoryItemViewController(item: item)
        let navVC = UINavigationController(rootViewController: editVC)
        navVC.modalPresentationStyle = .pageSheet
        navVC.sheetPresentationController?.detents = [.medium()]
        present(navVC, animated: true)
    }
    
    // MARK: - NSFetchedResultsController Delgate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .insert:
            // If previously no results, reload row to use actual item
            if model.numberOfItems == 1 {
                tableView.reloadRows(at: [newIndexPath!], with: .automatic)
            } else {
                tableView.insertRows(at: [newIndexPath!], with: .automatic)
                tableView.scrollToRow(at: newIndexPath!, at: .middle, animated: true)
            }
        case .delete:
            // If no results after deletion, reload to show empty/search view
            if model.numberOfItems == 0 {
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath!], with: .automatic)
            }
        case .move:
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            tableView.endUpdates()
        default:
            tableView.reloadData()
        }
    }
    
    // MARK: - Searching Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true)
    }
    
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
    @objc func createButtonPressed() {
        let createItemVC = CreateItemSheetController()
        createItemVC.modalPresentationStyle = .pageSheet
        if let sheetPresentationController = createItemVC.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
        }
        
        present(createItemVC, animated: true)
    }
}
