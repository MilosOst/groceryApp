//
//  UITableViewController+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-11.
//

import UIKit

extension UITableView {
    func setEmptyBackgroundView(_ title: String, message: String, imageName: String) {
        let emptyView = EmptyResultsView(title, message: message, imageName: imageName)
        emptyView.frame = self.frame
        backgroundView = emptyView
        separatorStyle = .none
    }
    
    /// Restores the table view to it's regular state, undoing the changes of any background views.
    func restore() {
        backgroundView = .none
        separatorStyle = .singleLine
    }
}
