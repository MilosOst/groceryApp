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

// TODO: Implement select no category
class CategorySelectionViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    weak var delegate: CategorySelectorDelegate?
    let currentCategory: Category?
    
    private lazy var model: CategorySelectorModel = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return CategorySelectorModel(context: context, controllerDelegate: self, initialCategory: currentCategory)
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
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
        tableView.delaysContentTouches = false
        title = "Categories"
        
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        let createCategoryBtn = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(addButtonPressed))
        createCategoryBtn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .normal)
        navigationItem.rightBarButtonItem = createCategoryBtn
        setPlainBackButton()
    }

    // MARK: - UITableViewDataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(model.numberOfCategories, 1)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return model.numberOfCategories > 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if model.numberOfCategories == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as! NoCategoriesViewCell
            cell.onTap = { [weak self] in self?.addButtonPressed() }
            tableView.separatorStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier, for: indexPath)
            var config = UIListContentConfiguration.cell()
            let category = model.category(at: indexPath)
            config.textProperties.font = .poppinsFont(varation: .light, size: 14)
            config.text = category.name?.capitalized
            cell.contentConfiguration = config
            cell.backgroundColor = (category == currentCategory) ? .systemGreen.withAlphaComponent(0.4) : .systemBackground
            cell.accessoryType = .detailButton
            tableView.separatorStyle = .singleLine
            return cell
        }
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
        let category = model.category(at: indexPath)
        let editVC = EditCategoryViewController(category: category)
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    // MARK: - Actions
    @objc func addButtonPressed() {
        let alertController = UIAlertController(title: "Create Category", message: nil, preferredStyle: .alert)
        let defaultText = searchController.searchBar.text
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.text = defaultText
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
            if model.numberOfCategories == 0 {
                tableView.reloadRows(at: [indexPath!], with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath!], with: .automatic)
            }
        case .insert:
            if model.numberOfCategories == 1 {
                tableView.reloadRows(at: [newIndexPath!], with: .automatic)
            } else {
                tableView.insertRows(at: [newIndexPath!], with: .automatic)
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
