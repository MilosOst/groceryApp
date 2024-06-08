//
//  ListSummaryMenuView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-02.
//

import UIKit

protocol ListSummaryMenuDelegate: AnyObject {
    func didSelectMakeActive()
    func removeUnchecked()
    func checkAll()
    func didSelectDelete()
}

class ListSummaryMenuView: UIView {
    weak var delegate: ListSummaryMenuDelegate?
    
    private lazy var makeActiveAction: UIAction = {
        return UIAction(title: "Make Active", image: UIImage(systemName: "checkmark.gobackward"), handler: { [weak self] _ in
            self?.delegate?.didSelectMakeActive()
        })
    }()
    
    private lazy var removeUncheckedAction: UIAction = {
        return UIAction(
            title: "Remove Unchecked",
            image: UIImage(systemName: "checklist.unchecked"),
            attributes: .destructive,
            handler: { [weak self] _ in
            self?.delegate?.removeUnchecked()
        })
    }()
    
    private lazy var checkAllAction: UIAction = {
        return UIAction(
            title: "Check All",
            image: UIImage(systemName: "checklist.checked"),
            handler: { [weak self] _ in
                self?.delegate?.checkAll()
            }
        )
    }()
    
    private lazy var deleteAction: UIAction = {
        return UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
            self?.delegate?.didSelectDelete()
        })
    }()
    
    lazy var menu: UIMenu = {
        return UIMenu(options: .displayInline, children: [makeActiveAction, checkAllAction, removeUncheckedAction, deleteAction])
    }()
    
    init(delegate: ListSummaryMenuDelegate? = nil) {
        self.delegate = delegate
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
}
