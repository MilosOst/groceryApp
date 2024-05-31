//
//  ListCreationViewControllerTableViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-01.
//

import UIKit
import CoreData

private let nameFieldCellIdentifier = "NameFieldCell"
private let templateCellIdentifier = "TemplateCell"
private let noTemplatesCellIdentifier = "NoTemplatesCell"

class CreateListViewController: UITableViewController {
    private let doneButton = UIBarButtonItem()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var templates = [Template]()
    
    private var selectedIndex: IndexPath?
    private var selectedTemplate: Template?
    private var listName = "" {
        didSet {
            doneButton.isEnabled = !listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        Task {
            do {
                try await self.fetchTemplates()
            } catch {
                print(error)
            }
        }
    }
    
    private func setupUI() {
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: nameFieldCellIdentifier)
        tableView.register(TemplateSelectionCellView.self, forCellReuseIdentifier: templateCellIdentifier)
        tableView.register(NoTemplatesViewCell.self, forCellReuseIdentifier: noTemplatesCellIdentifier)

        title = "New List"
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeForm))
        doneButton.title = "Done"
        doneButton.style = .done
        doneButton.target = self
        doneButton.action = #selector(donePressed)
        doneButton.isEnabled = false
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
    }

    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : max(templates.count, 1) // Indicator View if no templates
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: nameFieldCellIdentifier, for: indexPath) as! TextFieldTableViewCell
            cell.configure(placeholder: "List Name", text: listName)
            cell.delegate = self
            return cell
        } else {
            if templates.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: noTemplatesCellIdentifier, for: indexPath) as! NoTemplatesViewCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: templateCellIdentifier, for: indexPath) as! TemplateSelectionCellView
            let template = templates[indexPath.row]
            cell.configure(name: template.name!, itemCount: template.itemCount)
            cell.backgroundColor = (indexPath == selectedIndex) ? .systemYellow.withAlphaComponent(0.8) : .systemBackground
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 && templates.count > 0 else { return }
        view.endEditing(true)
        
        var refreshIndicies = [indexPath]
        // Check for deselection of template
        if indexPath == selectedIndex {
            selectedTemplate = nil
            selectedIndex = nil
        } else {
            // Check if some template was previously selected and row now needs to be deselected
            if let selectedIndex = selectedIndex {
                refreshIndicies.append(selectedIndex)
            }
            let template = templates[indexPath.row]
            selectedTemplate = template
            selectedIndex = indexPath
            
            // If list name is empty, update with template name
            if listName.isEmpty {
                listName = template.name!
                refreshIndicies.append(IndexPath(row: 0, section: 0))
            }
        }
        
        tableView.reloadRows(at: refreshIndicies, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "Name" : "Template (Optional)"
    }
    
    // MARK: - Actions
    @objc func closeForm() {
        self.dismiss(animated: true)
    }
    
    @objc func donePressed() {
        // Verify name is non-empty
        guard !listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        context.performAndWait {
            let list = ShoppingList(context: context)
            list.name = listName
            list.creationDate = Date.now
            
            // TODO: Need to verify this works
            if let selectedTemplate = selectedTemplate, let templateItems = selectedTemplate.items as? Set<TemplateItem> {
                for templateItem in templateItems {
                    let listItem = ListItem(context: context)
                    listItem.item = templateItem.item
                    listItem.unit = templateItem.unit
                    listItem.list = list
                    list.addToItems(listItem)
                }
            }
        }
        
        do {
            try context.save()
            dismiss(animated: true)
        } catch {
            print(error)
        }
    }
    
    // MARK: - CoreData Methods
    private func fetchTemplates() async throws {
        let fetchRequest: NSFetchRequest = Template.fetchRequest()
        let sortByFavourite = NSSortDescriptor(key: #keyPath(Template.isFavourite), ascending: false)
        let sortByName = NSSortDescriptor(key: #keyPath(Template.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByFavourite, sortByName]
        
        try await context.perform {
            let results = try fetchRequest.execute()
            self.templates = results
        }
        
        tableView.reloadSections(IndexSet([1]), with: .automatic)
    }
}

extension CreateListViewController: TextFieldCellDelegate {
    func textDidChange(_ text: String) {
        listName = text
    }
}
