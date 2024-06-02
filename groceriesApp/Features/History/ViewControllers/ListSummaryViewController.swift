//
//  ListSummaryPageController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-02.
//

import UIKit
import CoreData

private let cellID = "ItemCell"

/// History/Summary ViewController for ShoppingList
class ListSummaryViewController: UITableViewController, NSFetchedResultsControllerDelegate, ListSummaryMenuDelegate {
    private var model: ListSummaryModel!
    private lazy var optionsMenu: ListSummaryMenuView = {
        return ListSummaryMenuView(delegate: self)
    }()
    
    private lazy var summaryHeaderView: ListSummaryHeaderView = {
        let summaryView = ListSummaryHeaderView(dateChangeHandler: { [weak self] date in
            try? self?.model.updateCompletionDate(to: date)
        })
        summaryView.configure(cost: model.totalSpent, completionDate: model.completionDate)
        return summaryView
    }()
    
    init(shoppingList: ShoppingList) {
        super.init(style: .grouped)
        self.model = ListSummaryModel(list: shoppingList, context: coreDataContext, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ListItemSummaryCell.self, forCellReuseIdentifier: cellID)
        setupUI()
        do {
            try model.loadData()
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let header = tableView.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            header.frame.size = CGSize(width: tableView.frame.width, height: newSize.height)
        }
    }
    
    private func setupUI() {
        title = model.list.name
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
        
        let menuButton = UIBarButtonItem()
        menuButton.image = UIImage(systemName: "ellipsis")
        menuButton.menu = optionsMenu.menu
        navigationItem.rightBarButtonItem = menuButton
        
        // Create header view with summary
        summaryHeaderView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        tableView.tableHeaderView = summaryHeaderView
    }

    // MARK: - UITableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfItemsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ListItemSummaryCell
        let listItem = model.item(at: indexPath)
        cell.configure(with: listItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let title = model.titleForSection(section) {
            let displayTitle = (title == "1") ? "Checked": "Unchecked"
            return displayTitle
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try model.deleteItem(at: indexPath)
                summaryHeaderView.configure(cost: model.totalSpent, completionDate: model.completionDate)
            } catch {
                
            }
        }
    }
    
    // MARK: - Menu Methods
    func didSelectDelete() {
        let alert = UIAlertController.makeDeleteDialog(title: "Delete List", message: "This will remove the list permanently.", handler: { [self] _ in
            do {
                try model.deleteList()
                navigationController?.popViewController(animated: true)
            } catch {
                presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
    
    func didSelectMakeActive() {
        do {
            try model.makeActive()
            navigationController?.popViewController(animated: true)
        } catch {
            presentPlainErrorAlert()
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == .delete {
            tableView.deleteSections(.init(integer: sectionIndex), with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .delete {
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        summaryHeaderView.configure(cost: model.totalSpent, completionDate: model.completionDate)
    }
}
