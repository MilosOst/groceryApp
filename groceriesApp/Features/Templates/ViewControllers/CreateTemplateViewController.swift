//
//  CreateTemplateViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import UIKit

private let nameCellID = "NameCell"
private let favouriteCellID = "FavouriteCell"
private let sortOrderCellID = "SortOrderCell"

class CreateTemplateViewController: UITableViewController, LabelTextFieldCellDelegate {
    private lazy var doneButton: DoneBarButtonItem = {
        let button = DoneBarButtonItem(target: self, selector: #selector(donePressed(_:)))
        button.isEnabled = false
        return button
    }()
    
    private let model: CreateTemplateModel
    private var sortOptions: [ListItemsSortOption] = [.category, .name]
    
    init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        model = CreateTemplateModel(context: context)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LabelTextFieldTableViewCell.self, forCellReuseIdentifier: nameCellID)
        tableView.register(LabeledPickerViewCell.self, forCellReuseIdentifier: sortOrderCellID)
        setupUI()
    }
    
    private func setupUI() {
        title = "New Template"
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closePressed(_:)))
        navigationItem.rightBarButtonItem = doneButton
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: nameCellID, for: indexPath) as! LabelTextFieldTableViewCell
            cell.configure(label: "Name", placeholder: "Name", text: model.creationState.name)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: sortOrderCellID, for: indexPath) as! LabeledPickerViewCell
            cell.configure(label: "Sort Order", options: sortOptions, selectedObject: model.creationState.sortOrder, onSelect: { [weak self] index in
                self?.model.setSortOrder(self?.sortOptions[index] ?? .category)
            })
            return cell
        }
    }
    
    // MARK: - Actions
    @objc func closePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        do {
            try model.save()
            dismiss(animated: true)
        } catch EntityCreationError.emptyName {
            presentAlert(title: "Empty Name", message: "You must provide a non-empty name.")
        } catch EntityCreationError.duplicateName {
            presentAlert(title: "Name is taken", message: "Please choose another name.")
        } catch {
            presentPlainErrorAlert()
        }
    }
    
    // MARK: - Delegate Methods for input handling
    func textDidChange(inCell cell: LabelTextFieldTableViewCell, to text: String?) {
        model.setName(text)
        doneButton.isEnabled = model.canSave
    }
}
