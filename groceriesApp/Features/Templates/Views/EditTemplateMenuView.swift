//
//  EditTemplateMenuView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-29.
//

import UIKit

protocol EditTemplateMenuDelegate: AnyObject {
    func didSelectSortOption(_ option: ListItemsSortOption)
    func didSelectCreateList()
    func didSelectRename()
    func didSelectDelete()
}

class EditTemplateMenuView: UIView {
    private weak var delegate: EditTemplateMenuDelegate?
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
        let createListAction = UIAction(title: "Create List", image: UIImage(systemName: "list.bullet.rectangle.portrait"), handler: { [weak self] _ in
            self?.delegate?.didSelectCreateList()
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
        
        let menu = UIMenu(options: .displayInline, children: [createListAction, renameAction, deleteAction])
        return menu
    }()
    
    lazy var menu: UIMenu = {
        return UIMenu(options: .displayInline, children: [sortMenu, actionsMenu])
    }()
    
    init(sortOrder: ListItemsSortOption, delegate: EditTemplateMenuDelegate) {
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
