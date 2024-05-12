//
//  EditListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-08.
//

import UIKit
import CoreData

private let cellId = "ItemCell"

class EditListViewController: UIViewController, UICollectionViewDelegate, ListItemEditDelegate {
    private let fetchedResultsController: NSFetchedResultsController<ListItem>
    private lazy var dataSource = makeDataSource()
    private let initialItem: ListItem
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var collectionView: UICollectionView = {
        let layout = self.makeLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.keyboardDismissMode = .none
        collectionView.register(ListItemDetailCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        return collectionView
    }()
    
    init(fetchedResultsController: NSFetchedResultsController<ListItem>, startItem: ListItem) {
        self.fetchedResultsController = fetchedResultsController
        self.initialItem = startItem
        super.init(nibName: nil, bundle: nil)
        fetchedResultsController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.loadData()
        
        // Go to selected item position
        if let indexPath = fetchedResultsController.indexPath(forObject: initialItem) {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Dissapearing")
        super.viewWillDisappear(animated)
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.frame = view.frame
        self.edgesForExtendedLayout = .bottom
        self.view.backgroundColor = .systemBackground
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeSheet(_:)))
        navigationItem.leftBarButtonItem = closeButton
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeSheet(_:)))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .normal)
        title = initialItem.item?.name
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
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, ListItem> {
        return UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, listItem) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListItemDetailCell
                let listItem = self.fetchedResultsController.object(at: indexPath)
                cell.configure(with: listItem, delegate: self)
                return cell
            }
        
        )
    }
    
    private func loadData() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Int, ListItem>()
        snapshot.appendSections([1])
        snapshot.appendItems(fetchedObjects, toSection: 1)
        dataSource.applySnapshotUsingReloadData(snapshot)
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
        
        // TODO: Present alert for confirmation
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Remove Item", style: .destructive) { [self] _ in
            let item = fetchedResultsController.object(at: indexPath)
            do {
                context.delete(item)
//                var snapshot = dataSource.snapshot()
//                snapshot.deleteItems([item])
//                dataSource.apply(snapshot, animatingDifferences: true)
//                try context.save()
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

extension EditListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionView.reloadData()
    }
}
