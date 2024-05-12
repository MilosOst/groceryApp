//
//  ViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-04-30.
//

import UIKit
import CoreData

private let listCellIdentifier = "ListCell"

class HomeViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let segmentedControl = UISegmentedControl()
    
    private var tabSelection: HomeTab = .lists
    private var lists = [ShoppingList]()
    
    private lazy var fetchedListsController: NSFetchedResultsController<ShoppingList> = {
        let fetchRequest = ShoppingList.fetchRequest()
        let predicate = NSPredicate(format: "completionDate == nil")
        let sortByDate = NSSortDescriptor(key: #keyPath(ShoppingList.creationDate), ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortByDate]
        
        let resultsController = NSFetchedResultsController<ShoppingList>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        return resultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        do {
            try fetchedListsController.performFetch()
            print("Success, returned \(fetchedListsController.sections![0].numberOfObjects)")
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        setupNavBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: listCellIdentifier)
    }
    
    private func setupNavBar() {
        let addButton = UIBarButtonItem()
        addButton.image = UIImage(systemName: "plus")
        addButton.target = self
        addButton.action = #selector(addButtonPressed)
        
        navigationItem.rightBarButtonItem = addButton
        
        // Create segmented control actions
        let listsAction = UIAction(title: "Lists", handler: { _ in self.selectTab(.lists)})
        let templatesAction = UIAction(title: "Templates", handler: { _ in self.selectTab(.templates)})
        
        // Insert actions and set up control attributes
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(action: listsAction, at: 0, animated: true)
        segmentedControl.insertSegment(action: templatesAction, at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        let attr = [NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 14)]
        segmentedControl.setTitleTextAttributes(attr, for: .normal)
        
        navigationItem.titleView = segmentedControl
        title = "Home"
    }
    
    // MARK: - Actions
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Show appropriate creation page depending on current tab selection
        if tabSelection == .lists {
            let navVC = UINavigationController(rootViewController: CreateListViewController())
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        } else {
            print("Showing Template creation")
        }
    }
    
    private func selectTab(_ tab: HomeTab) {
        self.tabSelection = tab
    }
    
    // MARK: - TableView Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedListsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedListsController.sections![0].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath)
        cell.textLabel?.text = fetchedListsController.object(at: indexPath).name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: May need to differentiate based on which view is shown
        let shoppingList = fetchedListsController.object(at: indexPath)
        let detailVC = DetailedListViewController(list: shoppingList)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
        // TODO: Fix jumpy animation from toolbar showing up
    }
    
    // MARK: NSFetchedResultsController Delegate Methods
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard self == navigationController?.topViewController else {
            return
        }
        
        // TODO: Implement
    }
}

