//
//  EditListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-08.
//

import UIKit
import CoreData

private let cellId = "ItemCell"

// Use delegate to inform previous view controller of Unit changes
protocol ListEditDelegate: AnyObject {
    func didChangeItemUnit(_ item: ListItem)
}

class EditListItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ListItemEditDelegate {
    private let shoppingList: ShoppingList
    private let startItem: ListItem
    private weak var delegate: ListEditDelegate?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var collectionView: UICollectionView = {
        let layout = self.makeLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.keyboardDismissMode = .none
        collectionView.register(ListItemDetailCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        return collectionView
    }()
    
    // TODO: Refactor to use own fetched results controller
    private lazy var fetchedResultsController: NSFetchedResultsController<ListItem> = {
        let fetchRequest = ListItem.fetchRequest()
        let predicate = NSPredicate(format: "list == %@", shoppingList)
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ListItem.isChecked), ascending: true),
            NSSortDescriptor(key: #keyPath(ListItem.item.name), ascending: true)
        ]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        // If sorted by category, add Category NSSortDescriptor
        if shoppingList.sortOrder == ListItemsSortOption.category.rawValue {
            let sortByCategory = NSSortDescriptor(key: #keyPath(ListItem.item.category.name), ascending: true)
            fetchRequest.sortDescriptors?.insert(sortByCategory, at: 0)
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    init(shoppingList: ShoppingList, startItem: ListItem, delegate: ListEditDelegate?) {
        self.shoppingList = shoppingList
        self.startItem = startItem
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        if let indexPath = fetchedResultsController.indexPath(forObject: startItem) {
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.frame = view.frame
        edgesForExtendedLayout = .bottom
        view.backgroundColor = .systemBackground
        
        // Set up navbar items
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeSheet(_:)))
        navigationItem.leftBarButtonItem = closeButton
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeSheet(_:)))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .normal)
        title = startItem.item?.name
    }
    
    // MARK: - Collection View Setup
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration.scrollDirection = .horizontal
        return layout
    }
    
    // MARK: - UICollectionViewDataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListItemDetailCell
        let listItem = fetchedResultsController.object(at: indexPath)
        cell.configure(with: listItem, delegate: self)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView.indexPathsForVisibleItems.count > 0 else { return }
        title = fetchedResultsController.object(at: collectionView.indexPathsForVisibleItems[0]).item?.name
    }
    
    // MARK: - Actions
    @objc func closeSheet(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: ListItemEditDelegate Methods
    func quantityDidChange(_ cell: ListItemDetailCell, to quantity: String?) {
        // TODO: Move logic to model
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let listItem = fetchedResultsController.object(at: indexPath)
        // Verify string can be formed and is non-negative
        let updatedQuantity = max(Float(quantity ?? "") ?? 0, 0)
        
        // Update core data entity
        do {
            listItem.quantity = updatedQuantity
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func unitDidChange(_ cell: ListItemDetailCell, to unit: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        // TODO: Fix unit not updating in previous view OR remove unit change ability
        let listItem = fetchedResultsController.object(at: indexPath)
        do {
            listItem.item?.unit = unit
            try context.save()
            delegate?.didChangeItemUnit(listItem)
        } catch {
            print(error)
        }
    }
    
    func notesDidChange(_ cell: ListItemDetailCell, to text: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let listItem = fetchedResultsController.object(at: indexPath)
        do {
            listItem.notes = text.isEmpty ? nil : text
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func removePressed(_ cell: ListItemDetailCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        // Present confirmation alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Remove Item", style: .destructive) { [self] _ in
            let item = fetchedResultsController.object(at: indexPath)
            do {
                context.delete(item)
                try context.save()
            } catch {
                print(error)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension EditListItemsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                collectionView.deleteItems(at: [indexPath])
            }
        case .update:
            break
        default:
            collectionView.reloadData()
        }
    }
}
