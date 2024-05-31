//
//  ListDetailMenuView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-15.
//

import UIKit

class EditListMenuView: UIView {
    private weak var delegate: EditListMenuDelegate?
    private lazy var sortNameAction: UIAction = {
        return UIAction(title: "Name", handler: { [weak self] _ in
            self?.delegate?.didSelectSortOption(.name)
        })
    }()
    
    private lazy var sortCategoryAction: UIAction = {
        return UIAction(title: "Category", handler: { [weak self] _ in
            self?.delegate?.didSelectSortOption(.category)
        })
    }()
    
    private lazy var sortMenu: UIMenu = {
        return UIMenu(title: "Sort By", options: [.singleSelection, .displayInline], children: [sortCategoryAction, sortNameAction])
    }()
    
    private lazy var actionsMenu: UIMenu = {
        let markCompleteAction = UIAction(title: "Mark Complete", image: UIImage(systemName: "checkmark.circle"), handler: { [weak self] _ in
            self?.delegate?.didSelectMarkComplete()
        })
        
        let renameAction = UIAction(title: "Rename", image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
            self?.delegate?.didSelectRename()
        })
        
        let deleteAction = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] _ in
            self?.delegate?.didSelectDelete()
        })
        
        let menu = UIMenu(options: .displayInline, children: [markCompleteAction, renameAction, deleteAction])
        return menu
    }()
    
    lazy var menu: UIMenu = {
        return UIMenu(options: .displayInline, children: [sortMenu, actionsMenu])
    }()
    
    init(sortOrder: ListItemsSortOption, delegate: EditListMenuDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        if sortOrder == .category {
            sortCategoryAction.state = .on
        } else {
            sortNameAction.state = .on
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
}
