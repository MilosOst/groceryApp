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

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfTemplates = model.numberOfTemplates
        if numberOfTemplates == 0 {
            tableView.setEmptyBackgroundView("No Templates Found", message: "Create a Template using the button in the top right corner.", imageName: "list.clipboard")
        } else {
            tableView.restore()
        }
        
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
    
    // MARK: - NSFetchedResultsController Delegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // Prevent updates when not visible
        guard viewIfLoaded?.window != nil else { return }
        
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
