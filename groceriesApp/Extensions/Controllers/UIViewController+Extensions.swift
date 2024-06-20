//
//  UIViewController+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-06.
//

import UIKit
import CoreData
import StoreKit

@nonobjc extension UIViewController {
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
    
    var isVisible: Bool {
        viewIfLoaded?.window != nil
    }
    
    // MARK: - Container VC Helpers
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)
        if let frame = frame {
            child.view.frame = frame
        }
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    var coreDataContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    /// Requests an app review if the given conditions are met.
    func requestReview() {
        // Verify conditions are met
        let completionCount = UserDefaults.standard.integer(forKey: "completionCount")
        if [1, 10, 50].contains(completionCount) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}
