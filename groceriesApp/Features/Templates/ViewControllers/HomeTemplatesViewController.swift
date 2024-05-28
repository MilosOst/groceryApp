//
//  HomeTemplatesViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import UIKit
import CoreData

private let cellID = "TemplateCell"

class HomeTemplatesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private lazy var model: HomeTemplatesModel = {
        return .init(context: coreDataContext, delegate: self)
    }()
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TemplateCell.self, forCellReuseIdentifier: cellID)
        setupUI()
        
        do {
            try model.loadData()
            tableView.reloadData()
        } catch {
            presentPlainErrorAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    private func setupUI() {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfTemplates
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TemplateCell
        cell.configure(with: model.template(at: indexPath))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let template = model.template(at: indexPath)
        let editVC = EditTemplateViewController(template: template)
        editVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try model.deleteTemplate(at: indexPath)
            } catch {
                presentPlainErrorAlert()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // TODO: Present sheet with options for (rename, favourite, delete)?
    }
    
    // MARK: - NSFetchedResultsController Delegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // Prevent reloading of item counts when not in view
        if type == .update && !isTopViewController { return }
        
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        @unknown default:
            tableView.reloadData()
        }
    }
}
