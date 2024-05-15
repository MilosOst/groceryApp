//
//  CreateInventoryItemViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-04.
//

import UIKit

class CreateItemSheetController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let rootVC = CreateItemViewController()
        setViewControllers([rootVC], animated: true)
    }
}

// TODO: Change some delegates to callbacks?
fileprivate class CreateItemViewController: UITableViewController, LabelTextFieldCellDelegate, ToggleCellDelegate {
    private let textFieldCellIdentifier = "TextFieldCell"
    private let toggleCellIdentifier = "ToggleCell"
    private let categoryCellIdentifier = "CategoryCell"
    
    private lazy var doneButton: DoneBarButtonItem = {
        let button = DoneBarButtonItem(target: self, selector: #selector(donePressed))
        button.isEnabled = false
        return button
    }()
    
    private let model: CreateInventoryItemModel
    
    init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.model = CreateInventoryItemModel(context: context)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh in case Category changed
        tableView.reloadData()
    }
    
    private func setupUI() {
        tableView.register(LabelTextFieldTableViewCell.self, forCellReuseIdentifier: textFieldCellIdentifier)
        tableView.register(SelectedCategoryCell.self, forCellReuseIdentifier: categoryCellIdentifier)
        tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: toggleCellIdentifier)
        
        // Set up navbar
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closePressed))
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = doneButton
        title = "Create Item"
        setPlainBackButton()
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
    }
    
    // MARK: - UITableViewDelegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch indexPath.row {
        case 0, 2:
            cell = configureTextFieldCell(tableView, indexPath: indexPath)
        case 1:
            let categoryCell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier, for: indexPath) as! SelectedCategoryCell
            categoryCell.configure(categoryName: model.categoryName)
            cell = categoryCell
        case 3:
            let toggleCell = tableView.dequeueReusableCell(withIdentifier: toggleCellIdentifier, for: indexPath) as! ToggleTableViewCell
            toggleCell.configure(label: "Favourite", isActive: model.itemState.isFavourite)
            toggleCell.delegate = self
            cell = toggleCell
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Only handle interaction with category cell
        guard indexPath.row == 1 else { return }
        
        // Deselect row and display category selection
        tableView.deselectRow(at: indexPath, animated: true)
        let categorySelectVC = CategorySelectionViewController(currentCategory: model.itemState.category, delegate: model)
        navigationController?.pushViewController(categorySelectVC, animated: true)
    }
    
    private func configureTextFieldCell(_ tableView: UITableView, indexPath: IndexPath) -> LabelTextFieldTableViewCell {
        // Cell 0 is for Name, Cell 2 for Unit
        let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellIdentifier, for: indexPath) as! LabelTextFieldTableViewCell
        cell.delegate = self
        if indexPath.row == 0 {
            // Configure name field
            cell.configure(label: "Name", placeholder: "Groceries", text: model.itemState.name)
        } else {
            cell.configure(label: "Unit", placeholder: "kg", text: model.itemState.unit)
            cell.textField.autocapitalizationType = .none
        }
        
        return cell
    }
    
    // MARK: - Actions
    @objc func closePressed() {
        dismiss(animated: true)
    }
    
    @objc func donePressed() {
        do {
            try model.createItem()
            dismiss(animated: true)
        } catch InventoryItemCreationError.emptyName {
            presentAlert(title: "Invalid Item", message: "You must provide a non-empty name.")
        } catch InventoryItemCreationError.duplicateName {
            presentAlert(title: "Invalid Item", message: "This name is already taken.")
        } catch {
            presentPlainErrorAlert()
        }
    }
    
    // MARK: - TextField Delegate Methods
    func textDidChange(inCell cell: LabelTextFieldTableViewCell, to text: String?) {
        if cell == tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            model.setName(text)
        } else if cell == tableView.cellForRow(at: IndexPath(row: 2, section: 0)) {
            model.setUnit(text)
        }
        doneButton.isEnabled = model.canSave
    }
    
    func toggleDidChange(_ newValue: Bool) {
        model.setFavourite(newValue)
    }
}
