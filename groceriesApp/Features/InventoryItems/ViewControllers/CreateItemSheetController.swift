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
fileprivate class CreateItemViewController: UITableViewController, LabelTextFieldCellDelegate, ToggleCellDelegate, CategorySelectorDelegate {
    private let textFieldCellIdentifier = "TextFieldCell"
    private let toggleCellIdentifier = "ToggleCell"
    private let categoryCellIdentifier = "CategoryCell"
    
    // Creation State Variables
    private var itemState = InventoryItemCreationState()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let doneButton = UIBarButtonItem()
    
    init() {
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
        setupNavbar()
        tableView.register(LabelTextFieldTableViewCell.self, forCellReuseIdentifier: textFieldCellIdentifier)
        tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: toggleCellIdentifier)
        tableView.register(SelectedCategoryCell.self, forCellReuseIdentifier: categoryCellIdentifier)
    }
    
    private func setupNavbar() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closePressed))
        doneButton.title = "Done"
        doneButton.target = self
        doneButton.action = #selector(donePressed)
        doneButton.isEnabled = false
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .normal)
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .disabled)
        
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
            categoryCell.configure(categoryName: itemState.category?.name)
            cell = categoryCell
        case 3:
            let toggleCell = tableView.dequeueReusableCell(withIdentifier: toggleCellIdentifier, for: indexPath) as! ToggleTableViewCell
            toggleCell.configure(label: "Favourite", isActive: itemState.isFavourite)
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
        let categorySelectVC = CategorySelectionViewController(currentCategory: itemState.category, delegate: self)
        navigationController?.pushViewController(categorySelectVC, animated: true)
    }
    
    private func configureTextFieldCell(_ tableView: UITableView, indexPath: IndexPath) -> LabelTextFieldTableViewCell {
        // Cell 0 is for Name, Cell 2 for Unit
        let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellIdentifier, for: indexPath) as! LabelTextFieldTableViewCell
        let label = (indexPath.row == 0) ? "Name": "Unit"
        let placeholder = (indexPath.row == 0) ? "Groceries": "kg"
        let text = (indexPath.row == 0) ? itemState.name: itemState.unit
        
        cell.configure(label: label, placeholder: placeholder, text: text)
        cell.delegate = self
        
        // Turn off autocapitalization for unit
        if indexPath.row == 2 { cell.textField.autocapitalizationType = .none }
        return cell
    }
    
    // MARK: - Actions
    @objc func closePressed() {
        dismiss(animated: true)
    }
    
    @objc func donePressed() {
        let validator = InventoryItemValidator(coreDataContext: context)
        do {
            try validator.validateItem(itemState)
        } catch {
            switch error {
            case InventoryItemCreationError.emptyName:
                presentAlert(title: "Invalid Item", message: "You must provide a non-empty name.")
            case InventoryItemCreationError.duplicateName:
                presentAlert(title: "Invalid Item", message: "This name is already taken.")
            default:
                presentPlainErrorAlert()
            }
            
            return
        }
        
        // Item is valid
        do {
            let item = InventoryItem(context: context)
            item.name = itemState.name
            item.category = itemState.category
            item.unit = itemState.unit
            item.isFavourite = itemState.isFavourite

            try context.save()
            dismiss(animated: true)
        } catch {
            presentPlainErrorAlert()
        }
    }
    
    // MARK: - TextField Delegate Methods
    func textDidChange(inCell cell: LabelTextFieldTableViewCell, to text: String?) {
        if cell == tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            itemState.name = text ?? ""
        } else if cell == tableView.cellForRow(at: IndexPath(row: 2, section: 0)) {
            itemState.unit = text ?? ""
        }
        
        doneButton.isEnabled = !itemState.name.isTrimmedEmpty
    }
    
    func toggleDidChange(_ newValue: Bool) {
        itemState.isFavourite = newValue
    }
    
    // MARK: - Category Methods
    func didSelectCategory(_ category: Category) {
        itemState.category = category
    }
}
