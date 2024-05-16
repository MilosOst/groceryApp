//
//  HistoryViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import UIKit
import CoreData

private let cellID = "HistoryCell"

class HistoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private lazy var model: HistoryModel = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return HistoryModel(context: context, delegate: self)
    }()
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ShoppingListCell.self, forCellReuseIdentifier: cellID)
        setupUI()
        
        do {
            try model.loadData()
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    private func setupUI() {
        title = "History"
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
        let settingsBtn = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = settingsBtn
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
}
