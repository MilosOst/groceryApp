//
//  CategorySelectionViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-05.
//

import UIKit
import CoreData

protocol CategorySelectorDelegate: AnyObject {
    func didSelectCategory(_ category: Category)
}

private let emptyCellID = "EmptyResultsCell"
private let categoryCellIdentifier = "CategoryCell"

// TODO: Conform to NSFetchedResultsControllerDelegate, move logic to model
// TODO: Add category deletion/editing?
class CategorySelectionViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    weak var delegate: CategorySelectorDelegate?
    let currentCategory: Category?
    
    private lazy var model: CategorySelectorModel = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return CategorySelectorModel(context: context, controllerDelegate: self, initialCategory: currentCategory)
    }()
    
    init(currentCategory: Category?, delegate: CategorySelectorDelegate?) {
        self.currentCategory = currentCategory
        self.delegate = delegate
        super.init(style: .plain)
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
        tableView.register(NoCategoriesViewCell.self, forCellReuseIdentifier: emptyCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: categoryCellIdentifier)
        title = "Categories"
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        let createCategoryBtn = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(addButtonPressed(_:)))
        createCategoryBtn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .normal)
        navigationItem.rightBarButtonItem = createCategoryBtn
        setPlainBackButton()
    }

    // MARK: - UITableViewDataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfCategories
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If no results, display empty view
        var cell: UITableViewCell
        if model.numberOfCategories == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier, for: indexPath)
            var config = UIListContentConfiguration.cell()
            let category = model.category(at: indexPath)
            config.textProperties.font = .poppinsFont(varation: .light, size: 14)
            config.text = category.name?.capitalized
            cell.contentConfiguration = config
            cell.backgroundColor = (category == currentCategory) ? .systemGreen.withAlphaComponent(0.4) : .systemBackground
            cell.accessoryType = .detailButton
        }
        
        return cell
    }
    
    // MARK: - UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard model.numberOfCategories > 0 else { return }
        let category = model.category(at: indexPath)
        delegate?.didSelectCategory(category)
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard model.numberOfCategories > 0 else { return }
        if editingStyle == .delete {
            do {
                try model.deleteCategory(at: indexPath)
            } catch {
                presentPlainErrorAlert()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // TODO: Present VC to edit category
        let category = model.category(at: indexPath)
        let editVC = EditCategoryViewController(category: category)
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    // MARK: - Actions
    @objc func addButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Create Category", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.font = .poppinsFont(varation: .light, size: 14)
            textField.autocapitalizationType = .sentences
        }
        
        alertController.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self, weak alertController] (_ ) in
            let textField = alertController?.textFields![0]
            self?.handleCategoryCreation(textField?.text)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func handleCategoryCreation(_ name: String?) {
        do {
            try model.createCategory(name: name ?? "")
        } catch {
            switch error {
            case CategoryError.empty:
                presentAlert(title: "Invalid Category", message: "A non-empty category name is required.")
            case CategoryError.duplicateName:
                presentAlert(title: "Invalid Category", message: "This category name is already taken.")
            default:
                presentPlainErrorAlert()
            }
        }
    }
    
    // MARK: - NSFetchedResultsController Delegate Methods
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        default:
            tableView.reloadData()
        }
    }
    
    // MARK: - UISearchResultsUpdating Delegate
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
}
