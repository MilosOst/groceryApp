//
//  EditListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-08.
//

import UIKit
import CoreData

private let cellId = "ItemCell"

class EditListItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, EditListItemDelegate, NSFetchedResultsControllerDelegate {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLayout.makeFullScreenHorizontalPagingLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.keyboardDismissMode = .none
        collectionView.register(EditListItemCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        return collectionView
    }()
    
    private var model: EditListItemsModel!

    init(shoppingList: ShoppingList, startItem: ListItem) {
        super.init(nibName: nil, bundle: nil)
        self.model = EditListItemsModel(list: shoppingList, startItem: startItem, context: coreDataContext, delegate: self)
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
        
        if let indexPath = model.indexPathForStartItem {
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
        let doneButton = DoneBarButtonItem(target: self, selector: #selector(closeSheet(_:)))
        navigationItem.rightBarButtonItem = doneButton
        title = model.startItem.item?.name
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
    }
    
    // MARK: - UICollectionViewDataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EditListItemCell
        let listItem = model.item(at: indexPath)
        cell.configure(with: listItem, delegate: self)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
    func quantityDidChange(in cell: EditListItemCell, to quantity: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let quantity = Float(quantity ?? "") ?? 0
        try? model.updateQuantity(at: indexPath, quantity: quantity)
    }
    
    func unitDidChange(in cell: EditListItemCell, to unit: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        try? model.updateUnit(at: indexPath, unit: unit)
    }
    
    func priceDidChange(in cell: EditListItemCell, to price: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let price = Float(price ?? "") ?? 0
        try? model.updatePrice(at: indexPath, price: price)
    }
    
    func notesDidChange(in cell: EditListItemCell, to text: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        try? model.updateNotes(at: indexPath, notes: text)
    }
    
    func categoryBtnPressed(_ cell: EditListItemCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let item = model.item(at: indexPath)
        let categorySelectorVC = CategorySelectionViewController(currentCategory: item.item?.category, delegate: self)
        navigationController?.pushViewController(categorySelectorVC, animated: true)
    }
    
    func removePressed(_ cell: EditListItemCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let alert = UIAlertController.makeDeleteDialog(title: nil, message: nil, handler: { [self] _ in
            do {
                try model.deleteItem(at: indexPath)
            } catch {
                presentPlainErrorAlert()
            }
        })
        present(alert, animated: true)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            break
        default:
            collectionView.reloadData()
        }
    }
}

extension EditListItemsViewController: CategorySelectorDelegate {
    func didSelectCategory(_ category: Category) {
        guard collectionView.indexPathsForVisibleItems.count > 0 else {
            return
        }
        
        let currIndexPath = collectionView.indexPathsForVisibleItems[0]
        try? model.updateCategory(to: category, at: currIndexPath)
    }
}
