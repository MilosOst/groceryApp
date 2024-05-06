//
//  DetailedListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-04.
//

import UIKit

class DetailedListViewController: UITableViewController {
    let shoppingList: ShoppingList
    
    init(list: ShoppingList) {
        self.shoppingList = list
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let optionsButton = UIBarButtonItem()
        optionsButton.image = UIImage(systemName: "ellipsis.circle")
        navigationItem.rightBarButtonItem = optionsButton
        
        // TODO: Add menu to bar button
        title = shoppingList.name
        
        // TODO: Create toolbar
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
        let middleButton = UIBarButtonItem()
        middleButton.title = "\(shoppingList.itemCount) Items"
        middleButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 12)], for: .normal)
        setToolbarItems([.flexibleSpace(), middleButton, .flexibleSpace(), addButton], animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        setPlainBackButton()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    // MARK: - Actions
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Present InventoryItem selection
        let destVC = SelectInventoryItemViewController(style: .plain)
        navigationController?.pushViewController(destVC, animated: true)
    }
}
