//
//  EditCategoryViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-14.
//

import UIKit

private let cellID = "nameCell"

class EditCategoryViewController: UITableViewController, TextFieldCellDelegate {
    private let model: EditCategoryModel

    private let saveButton = UIBarButtonItem(title: "Save", image: nil, target: nil, action: nil)
    
    init(category: Category) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        model = EditCategoryModel(category: category, context: context)
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
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: cellID)
        title = "Edit Category"
        
        saveButton.target = self
        saveButton.action = #selector(saveButtonPressed(_:))
        saveButton.setTitleTextAttributes([.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .normal)
        saveButton.setTitleTextAttributes([.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .disabled)
        navigationItem.rightBarButtonItem = saveButton
        
        // Remove spacing at top of table view
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TextFieldTableViewCell
        cell.configure(placeholder: "Name", text: model.newName)
        cell.delegate = self
        return cell
    }
    
    // MARK: - Actions
    @objc func saveButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try model.saveName()
        } catch {
            switch error {
            case CategoryError.duplicateName:
                presentAlert(title: "Invalid Category", message: "This category name is already taken.")
            default:
                presentPlainErrorAlert()
            }
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TextFieldCellDelegate
    func textDidChange(_ text: String) {
        model.nameChangedTo(text)
        saveButton.isEnabled = model.canSave
    }
}
