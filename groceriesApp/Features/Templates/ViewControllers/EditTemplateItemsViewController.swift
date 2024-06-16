//
//  EditTemplateItemsViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-26.
//

import UIKit
import CoreData

private let cellID = "ItemCell"

class EditTemplateItemsViewController: EditListableItemsViewController<TemplateItem> {
    init(template: Template, startItem: TemplateItem) {
        super.init()
        self.model = EditTemplateItemsModel(template: template, startItem: startItem, context: coreDataContext, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
}
