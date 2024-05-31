//
//  HomeListsViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-15.
//

import UIKit
import CoreData

private let cellID = "ListCell"

class HomeListsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private lazy var model: HomeListsModel = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return HomeListsModel(context: context, delegate: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ShoppingListCell.self, forCellReuseIdentifier: cellID)
        do {
            try model.loadData()
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfLists
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ShoppingListCell
        let list = model.shoppingList(at: indexPath)
        cell.configure(with: list)
        return cell
    }
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = model.shoppingList(at: indexPath)
        let detailVC = EditShoppingListViewController(list: list)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentDeleteConfirmation(for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // TODO: Present confirmation alert
        let dialog = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { _ in })
        let markCompleteAction = UIAlertAction(title: "Mark Complete", style: .default)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        dialog.addActions([markCompleteAction, renameAction, cancelAction])
        present(dialog, animated: true)
    }
    
    // MARK: - Actions
    private func presentDeleteConfirmation(for indexPath: IndexPath) {
        let alert = UIAlertController.makeDeleteDialog(title: "Delete List?", message: "This action cannot be undone.", handler: { [self] _ in
            do {
                try self.model.deleteObject(at: indexPath)
            } catch {
                self.presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard tableView.window != nil else { return }
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            tableView.reloadData()
        }
    }
}
