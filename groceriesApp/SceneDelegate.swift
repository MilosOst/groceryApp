//
//  SceneDelegate.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-04-30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        let tabBar = UITabBarController()
        let homeVC = HomeRootViewController()
        let homeNavVC = UINavigationController(rootViewController: homeVC)
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let historyVC = HistoryViewController()
        let historyNavVC = UINavigationController(rootViewController: historyVC)
        historyVC.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 1)
        
        tabBar.viewControllers = [homeNavVC, historyNavVC]
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else { return }
        handleDeepLink(context: context)
    }

    private func handleDeepLink(context: UIOpenURLContext) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Currently only allows widget ShoppingList deep links
        let string = context.url.relativeString
        guard string.starts(with: "kaufList://shoppingList/") else { return }
        
        // Verify existing active ShoppingList with given id exists
        let parts = string.split(separator: "shoppingList/")
        guard parts.count == 2 else { return }
        let objectURI = String(parts[1])
        guard let objectIDURL = URL(string: objectURI) else { return }
        
        // Search in CoreData for corresponding object id
        let container = appDelegate.persistentContainer
        let coordinator = container.persistentStoreCoordinator
        
        // FIXME: Crash here on invalid URI
        guard let objectID = coordinator.managedObjectID(forURIRepresentation: objectIDURL) else {
            return
        }
        
        // Fetch list
        guard let list = try? container.viewContext.existingObject(with: objectID) as? ShoppingList, list.completionDate == nil else {
            return
        }

        
        // TODO: Handle tab bar controller
        guard let tabBarController = window?.rootViewController as? UITabBarController, let rootVC = tabBarController.selectedViewController as? UINavigationController else {
            return
        }
        
        // Close current EditVC if exists
        if let currentEditVC = rootVC.topViewController as? EditShoppingListViewController {
            // If showing current list, do nothing, else dismiss
            if currentEditVC.model.list == list {
                return
            } else {
                rootVC.popViewController(animated: true)
            }
        }
        
        let editVC = EditShoppingListViewController(list: list)
        rootVC.pushViewController(editVC, animated: true)
    }
}

