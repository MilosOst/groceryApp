//
//  HomeRootViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-15.
//

import UIKit

class HomeRootViewController: UIViewController {
    private let segmentedControl = UISegmentedControl()
    private let listsController = HomeListsViewController()
    private let templatesController = HomeTemplatesViewController()
    
    private var currentTab: HomeTab?
    private var shownViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if currentTab == nil {
            showTab(.lists)
        }
    }
    
    private func setupUI() {
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonPressed(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        // Set up segmented control as tab bar
        let listsAction = UIAction(title: "Lists", handler: { _ in self.showTab(.lists) })
        let templatesAction = UIAction(title: "Templates", handler: { _ in self.showTab(.templates)})
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(action: listsAction, at: 0, animated: true)
        segmentedControl.insertSegment(action: templatesAction, at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        let attr = [NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 14)]
        segmentedControl.setTitleTextAttributes(attr, for: .normal)
        
        navigationItem.titleView = segmentedControl
        title = "Home"
        view.backgroundColor = .systemBackground
    }
    
    // MARK: - Actions
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        let createVC = creationViewController(for: currentTab ?? .lists)
        let navVC = UINavigationController(rootViewController: createVC)
        if currentTab == .templates {
            navVC.modalPresentationStyle = .formSheet
            navVC.sheetPresentationController?.detents = [.custom { _ in 275 }]
        } else {
            navVC.modalPresentationStyle = .fullScreen
        }
        
        present(navVC, animated: true)
    }
    
    private func creationViewController(for tab: HomeTab) -> UIViewController {
        if tab == .lists {
            return CreateListViewController()
        }
        return CreateTemplateViewController()
    }
    
    private func showTab(_ tab: HomeTab) {
        guard tab != currentTab else { return }
        shownViewController?.remove()
        let vc = viewController(for: tab)
        add(vc, frame: view.frame)
        shownViewController = vc
        currentTab = tab
    }
    
    private func viewController(for tab: HomeTab) -> UIViewController {
        if tab == .lists {
            return listsController
        } else {
            return templatesController
        }
    }
}
