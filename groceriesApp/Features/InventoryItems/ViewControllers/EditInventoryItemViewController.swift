//
//  EditInventoryItemViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import UIKit

private let labelTextFieldCellID = "NameCell"
private let toggleCellID = "ToggleCell"
private let categoryCellID = "CategoryCell"

class EditInventoryItemViewController: UITableViewController, ToggleCellDelegate, LabelTextFieldCellDelegate, CategorySelectorDelegate {
    private let model: EditInventoryItemModel
    private lazy var doneButton: DoneBarButtonItem = {
        return DoneBarButtonItem(target: self, selector: #selector(donePressed(_:)))
    }()
    
    init(item: InventoryItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        model = EditInventoryItemModel(item: item, context: context)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LabelTextFieldTableViewCell.self, forCellReuseIdentifier: labelTextFieldCellID)
        tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: toggleCellID)
        tableView.register(SelectedCategoryCell.self, forCellReuseIdentifier: categoryCellID)
        setupUI()
    }
    
    private func setupUI() {
        title = "Edit Item"
        navigationItem.rightBarButtonItem = doneButton
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        var cell: UITableViewCell
        switch row {
        case 0, 1:
            let textFieldCell = tableView.dequeueReusableCell(withIdentifier: labelTextFieldCellID, for: indexPath) as! LabelTextFieldTableViewCell
            textFieldCell.delegate = self
            if row == 0 {
                textFieldCell.configure(label: "Name", placeholder: "Name", text: model.itemName)
            } else {
                textFieldCell.configure(label: "Unit", placeholder: "Unit", text: model.itemUnit)
            }
            cell = textFieldCell
        case 2:
            let categoryCell = tableView.dequeueReusableCell(withIdentifier: categoryCellID, for: indexPath) as! SelectedCategoryCell
            categoryCell.configure(categoryName: model.category?.name)
            cell = categoryCell
        case 3:
            let toggleCell = tableView.dequeueReusableCell(withIdentifier: toggleCellID, for: indexPath) as! ToggleTableViewCell
            toggleCell.delegate = self
            toggleCell.configure(label: "Favourite", isActive: model.isFavourite)
            cell = toggleCell
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 2 else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let categorySelectVC = CategorySelectionViewController(currentCategory: model.category, delegate: self)
        navigationController?.pushViewController(categorySelectVC, animated: true)
    }
    
    // MARK: - Actions
    @objc func donePressed(_ sender: UIBarButtonItem) {
        do {
            try model.saveChanges()
            navigationController?.popViewController(animated: true)
        } catch {
            presentPlainErrorAlert()
        }
    }
    
    // MARK: - Editing Delegates
    func textDidChange(inCell cell: LabelTextFieldTableViewCell, to text: String?) {
        guard let row = tableView.indexPath(for: cell)?.row else {
            return
        }
        
        if row == 0 {
            model.setName(to: text)
        } else {
            model.setUnit(to: text)
        }
        doneButton.isEnabled = model.canSave
    }
    
    func toggleDidChange(_ newValue: Bool) {
        model.setIsFavourite(to: newValue)
    }
    
    func didSelectCategory(_ category: Category) {
        model.setCategory(category)
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
    }
}
