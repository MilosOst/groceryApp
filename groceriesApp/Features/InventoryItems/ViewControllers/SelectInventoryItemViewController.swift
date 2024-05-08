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

// TODO: Add search contrlller functionality
class SelectInventoryItemViewController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    weak var delegate: SelectInventoryItemDelegate?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<InventoryItem> = {
        let fetchRequest = InventoryItem.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(InventoryItem.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        return resultsController
    }()
    
    let searchController = UISearchController()
    
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
        
        // Load data
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print(error)
        }
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
//        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.titleView = searchController.searchBar
        
        let createItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createButtonPressed(_:)))
        setToolbarItems([.flexibleSpace(), .flexibleSpace(), createItemButton], animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        
        tableView.register(InventoryItemSelectionCell.self, forCellReuseIdentifier: cellIdentifier)
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![0].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InventoryItemSelectionCell
        let item = fetchedResultsController.object(at: indexPath)
        cell.configure(name: item.name!, isFavourite: item.isFavourite, isSelected: delegate?.isItemSelected(item) ?? false)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = fetchedResultsController.object(at: indexPath)
        delegate?.didToggleItem(item)
    }
    
    // MARK: - NSFetchedResultsController Delgate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        default:
            tableView.reloadData()
        }
    }
    
    // MARK: - UISearchResultsUpdating Methods
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Implement
    }
    
    // MARK: - Actions
    @objc func createButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Show creation
        let createItemVC = CreateItemSheetController()
        createItemVC.modalPresentationStyle = .pageSheet
        if let sheetPresentationController = createItemVC.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
        }
        
        present(createItemVC, animated: true)
    }
}
