//
//  ListDetailMenuView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-15.
//

import UIKit

class ListDetailMenuView: UIView {
    private weak var delegate: ListDetailMenuDelegate?
    var menu: UIMenu!
    
    init(sortOption: ListItemsSortOption, delegate: ListDetailMenuDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupMenu(sortOption)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupMenu(_ sortOrder: ListItemsSortOption) {
        let sortNameAction = UIAction(title: "Name", handler: { [weak self] _ in
            self?.delegate?.didSelectSortOption(.name)
        })
        let sortCategoryAction = UIAction(title: "Category", handler: { [weak self] _ in
            self?.delegate?.didSelectSortOption(.category)
        })
        if sortOrder == .category {
            sortCategoryAction.state = .on
        } else {
            sortNameAction.state = .on
        }
        
        let sortMenu = UIMenu(options: [.singleSelection, .displayInline], children: [sortCategoryAction, sortNameAction])
        
        // Define general list actions
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
            self?.delegate?.didSelectDelete()
        })
        let markCompleteAction = UIAction(title: "Mark Complete", image: UIImage(systemName: "checkmark.circle"), handler: { [weak self] _ in
            self?.delegate?.didSelectMarkComplete()
        })
        let actionsMenu = UIMenu(options: .displayInline, children: [markCompleteAction, deleteAction])
        
        menu = UIMenu(options: .displayInline, children: [sortMenu, actionsMenu])
    }
}
