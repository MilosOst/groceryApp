//
//  ListSummaryMenuView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-02.
//

import UIKit

protocol ListSummaryMenuDelegate: AnyObject {
    func didSelectMakeActive()
    func didSelectDelete()
}

class ListSummaryMenuView: UIView {
    weak var delegate: ListSummaryMenuDelegate?
    
    private lazy var makeActiveAction: UIAction = {
        return UIAction(title: "Make Active", image: UIImage(systemName: "checkmark.gobackward"), handler: { [weak self] _ in
            self?.delegate?.didSelectMakeActive()
        })
    }()
    
    private lazy var deleteAction: UIAction = {
        return UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
            self?.delegate?.didSelectDelete()
        })
    }()
    
    lazy var menu: UIMenu = {
        return UIMenu(options: .displayInline, children: [makeActiveAction, deleteAction])
    }()
    
    init(delegate: ListSummaryMenuDelegate? = nil) {
        self.delegate = delegate
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
}
