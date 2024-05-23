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

// TODO: Implement notifier to previous view on InventoryItemChanged
/// IDEA: Pass delegate into next ViewController, notify on change

class EditListItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ListItemEditDelegate {
    private let startItem: ListItem
    private weak var delegate: ListEditDelegate?
    private let model: EditListItemsModel
    
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

    init(shoppingList: ShoppingList, startItem: ListItem, delegate: ListEditDelegate?) {
        self.startItem = startItem
        self.delegate = delegate
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.model = EditListItemsModel(shoppingList: shoppingList, context: context)
        super.init(nibName: nil, bundle: nil)
        model.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        do {
            try model.loadData()
        } catch {
            print(error)
        }
        
        if let indexPath = model.indexPath(for: startItem) {
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Update current collectionViewCell in case InventoryItem was edited
        if collectionView.indexPathsForVisibleItems.count > 0 {
            let indexPath = collectionView.indexPathsForVisibleItems[0]
            collectionView.reloadItems(at: [indexPath])
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
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
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
        return model.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListItemDetailCell
        let listItem = model.item(at: indexPath)
        cell.configure(with: listItem, delegate: self)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView.indexPathsForVisibleItems.count > 0 else { return }
        if collectionView.indexPathsForVisibleItems.count > 0 {
            let indexPath = collectionView.indexPathsForVisibleItems[0]
            let item = model.item(at: indexPath)
            title = item.item?.name
        }
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
        
        try? model.updateQuantity(at: indexPath, quantityStr: quantity)
    }
    
    func unitDidChange(_ cell: ListItemDetailCell, to unit: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        do {
            try model.updateUnit(at: indexPath, unitStr: unit)
            let item = model.item(at: indexPath)
            delegate?.didChangeItemUnit(item)
        } catch {
            print(error)
        }
    }
    
    func priceDidChange(_ cell: ListItemDetailCell, to price: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        do {
            try model.updatePrice(at: indexPath, priceStr: price)
        } catch {
            print(error)
        }
    }
    
    func notesDidChange(_ cell: ListItemDetailCell, to text: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        try? model.updateNotes(at: indexPath, notes: text)
    }
    
    func removePressed(_ cell: ListItemDetailCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        let alert = UIAlertController.makeDeleteDialog(title: nil, message: nil, handler: { [self] _ in
            do {
                try model.deleteItem(at: indexPath)
            } catch {
                presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
    
    func editPressed(_ cell: ListItemDetailCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let item = model.item(at: indexPath)
        let editVC = EditInventoryItemViewController(item: item.item!)
        navigationController?.pushViewController(editVC, animated: true)
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
