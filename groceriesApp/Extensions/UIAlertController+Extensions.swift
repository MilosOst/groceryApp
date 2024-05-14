//
//  UIAlertController+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-13.
//

import UIKit

extension UIAlertController {
    func addActions(_ actions: [UIAlertAction]) {
        for action in actions {
            addAction(action)
        }
    }
    
    static func makeDeleteDialog(title: String?, message: String?, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handler)
        controller.addActions([deleteAction, cancelAction])
        return controller
    }
}
