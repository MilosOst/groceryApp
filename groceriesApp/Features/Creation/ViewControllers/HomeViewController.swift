//
//  ViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-04-30.
//

import UIKit

class HomeViewController: UITableViewController {
    private let segmentedControl = UISegmentedControl()
    
    private var tabSelection: HomeTab = .lists

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupNavBar()
    }
    
    private func setupNavBar() {
        let addButton = UIBarButtonItem()
        addButton.image = UIImage(systemName: "plus")
        addButton.target = self
        addButton.action = #selector(addButtonPressed)
        
        navigationItem.rightBarButtonItem = addButton
        
        // Create segmented control actions
        let listsAction = UIAction(title: "Lists", handler: { _ in self.selectTab(.lists)})
        let templatesAction = UIAction(title: "Templates", handler: { _ in self.selectTab(.templates)})
        
        // Insert actions and set up control attributes
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(action: listsAction, at: 0, animated: true)
        segmentedControl.insertSegment(action: templatesAction, at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        let attr = [NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 14)]
        segmentedControl.setTitleTextAttributes(attr, for: .normal)
        
        navigationItem.titleView = segmentedControl
    }
    
    // MARK: - Actions
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Show appropriate creation page depending on current tab selection
        if tabSelection == .lists {
            print("Showing list creation")
        } else {
            print("Showing Template creation")
        }
    }
    
    private func selectTab(_ tab: HomeTab) {
        self.tabSelection = tab
    }
}

