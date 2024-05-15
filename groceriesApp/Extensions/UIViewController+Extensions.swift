//
//  UIViewController+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-06.
//

import UIKit

extension UIViewController {
    func setTitleFont(_ font: UIFont) {
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: font
        ]
    }
    
    func setPlainBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func presentAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    /// Presents a plain error alert indicating that something went wrong.
    func presentPlainErrorAlert() {
        presentAlert(title: "Error", message: "Sorry, something went wrong.")
    }
    
    var isTopViewController: Bool {
        navigationController?.topViewController == self
    }
}
