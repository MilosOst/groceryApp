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
    
    /// Creates and returns a UIAlertController with an embedded UITextField.
    /// - Parameters:
    ///   - title: Title for the alert
    ///   - message: Message to display
    ///   - placeholder: Placeholder text to display in text field
    ///   - text: Initial text for text field
    ///   - handler: Submission handler
    /// - Returns: UIAlertController with embedded text field.
    static func makeTextFieldAlert(
        title: String?,
        message: String? = nil,
        placeholder: String? = nil,
        text: String? = nil,
        handler: ((String) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.font = .poppinsFont(varation: .light, size: 14)
            textField.placeholder = placeholder
            textField.autocapitalizationType = .sentences
            textField.text = text
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            handler?(alert.textFields![0].text ?? "")
        })
        
        alert.addActions([cancelAction, confirmAction])
        return alert
    }
    
    /// Creates an alert for editing the name of some item.
    /// - Parameters:
    ///   - name: Current name of the itme
    ///   - handler: Handler for submission.
    /// - Returns: The initialized UIAlertController
    static func editItemNameAlert(name: String, handler: ((String, ItemNameChangeType) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "Rename Item", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.font = .poppinsFont(varation: .light, size: 14)
            textField.placeholder = "Name"
            textField.autocapitalizationType = .sentences
            textField.text = name
            textField.clearButtonMode = .whileEditing
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let changeGloballyAction = UIAlertAction(title: "Rename Everywhere", style: .default, handler: { _ in
            let text = alert.textFields![0].text ?? ""
            handler?(text, .global)
        })
        let changeLocallyAction = UIAlertAction(title: "Rename Here", style: .default, handler: { _ in
            let text = alert.textFields![0].text ?? ""
            handler?(text, .local)
        })
        
        alert.addActions([cancelAction, changeLocallyAction, changeGloballyAction])
        return alert
    }
}
