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

private let emptyCellIdentifier = "EmptyResultsCell"
private let categoryCellIdentifier = "CategoryCell"

// TODO: Add category deletion/editing?
class CategorySelectionViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    weak var delegate: CategorySelectorDelegate?
    let currentCategory: Category?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private lazy var fetchedCategoriesController: NSFetchedResultsController<Category> = {
        let fetchRequest = Category.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Category.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sortByName]
        
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        return resultsController
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
        
        do {
            try fetchedCategoriesController.performFetch()
            tableView.reloadData()
        } catch {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupUI() {
        tableView.register(NoCategoriesViewCell.self, forCellReuseIdentifier: emptyCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: categoryCellIdentifier)
        title = "Categories"
        
        // TODO: Add search bar functionality
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        let createCategoryBtn = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(addButtonPressed(_:)))
        createCategoryBtn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .normal)
        navigationItem.rightBarButtonItem = createCategoryBtn
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return max(fetchedCategoriesController.sections?[0].numberOfObjects ?? 1, 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If no results, display empty view
        if fetchedCategoriesController.sections == nil || fetchedCategoriesController.sections![0].numberOfObjects == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
            cell.contentView.isUserInteractionEnabled = false
            return cell
        }
        
        // Otherwise, show category cell
        let category = fetchedCategoriesController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier, for: indexPath)
        
        var config = UIListContentConfiguration.cell()
        config.textProperties.font = .poppinsFont(varation: .light, size: 14)
        config.text = category.name?.capitalized
        cell.contentConfiguration = config
        cell.accessoryType = (category == currentCategory) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard fetchedCategoriesController.sections?[0].numberOfObjects ?? 0 > 0 else { return }
        
        let category = fetchedCategoriesController.object(at: indexPath)
        delegate?.didSelectCategory(category)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - NSFetchedResultsController Delegate Methods
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
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
    
    func handleCategoryCreation(_ name: String?) {
        let validator = CategoryCreationValidator(coreDataContext: context)
        do {
            try validator.validate(name ?? "")
        } catch {
            switch error {
            case CategoryCreationError.empty:
                presentAlert(title: "Invalid Category", message: "A non-empty category name is required.")
            case CategoryCreationError.duplicateName:
                presentAlert(title: "Invalid Category", message: "This category name is already taken.")
            default:
                presentPlainErrorAlert()
            }
            
            return
        }
        
        do {
            // Name is unique, create category
            let category = Category(context: context)
            category.name = name
            try context.save()
        } catch {
            presentPlainErrorAlert()
        }
    }
}
