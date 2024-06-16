//
//  EditListableItemsViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-15.
//

import CoreData
import UIKit

private let cellId = "ItemCell"


class EditListableItemsViewController<T: ListableItem & NSManagedObject>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, EditListableItemCellDelegate {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLayout.makeFullScreenHorizontalPagingLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.keyboardDismissMode = .none
        collectionView.register(EditListableItemCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        return collectionView
    }()
    
    internal var model: EditListableItemsModel<T>!
    
    init(model: EditListableItemsModel<T>) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let indexPath = collectionView.indexPathsForVisibleItems.first {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    // Fix access level
    func setupUI() {
        view.addSubview(collectionView)
        collectionView.frame = view.frame
        edgesForExtendedLayout = .bottom
        view.backgroundColor = .systemBackground
        
        // Navbar setup
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeSheet))
        navigationItem.leftBarButtonItem = closeButton
        let doneButton = DoneBarButtonItem(target: self, selector: #selector(closeSheet))
        navigationItem.rightBarButtonItem = doneButton
        title = model.startItem.item?.name
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
    }
    
    // MARK: - CollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EditListableItemCell
        let item = model.item(at: indexPath)
        cell.configure(with: item, delegate: self)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let indexPath = collectionView.indexPathsForVisibleItems.first {
            let item = model.item(at: indexPath)
            title = item.item?.name
        }
    }
    
    // MARK: - EditListableItemCell Delegate
    func quantityDidChange(in cell: EditListableItemCell, to quantity: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let quantity = Float(quantity ?? "") ?? 0
        try? model.updateQuantity(at: indexPath, quantity: quantity)
    }
    
    func unitDidChange(in cell: EditListableItemCell, to unit: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        try? model.updateUnit(at: indexPath, unit: unit)
    }
    
    func priceDidChange(in cell: EditListableItemCell, to price: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let price = Float(price ?? "") ?? 0
        try? model.updatePrice(at: indexPath, price: price)
    }
    
    func notesDidChange(in cell: EditListableItemCell, to text: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        try? model.updateNotes(at: indexPath, notes: text)
    }
    
    func categoryBtnPressed(_ cell: EditListableItemCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let item = model.item(at: indexPath)
        let categorySelectorVC = CategorySelectionViewController(currentCategory: item.item?.category, delegate: self)
        navigationController?.pushViewController(categorySelectorVC, animated: true)
    }
    
    func removePressed(_ cell: EditListableItemCell) {
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
    
    func renamePressed(_ cell: EditListableItemCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let item = model.item(at: indexPath)
        let name = item.item?.name ?? ""
        let alert = UIAlertController.editItemNameAlert(name: name, handler: { [weak self] (newName, editType) in
            do {
                try self?.model.rename(at: indexPath, newName: newName, editType: editType)
                if editType == .global {
                    self?.title = newName
                    
                }
            } catch InventoryItemError.emptyName {
                self?.presentAlert(title: "Empty Name", message: "You must provide a non-empty name.")
            } catch InventoryItemError.duplicateName {
                self?.presentAlert(title: "Duplicate Name", message: "This item name is already taken. Please choose another.")
            } catch {
                self?.presentPlainErrorAlert()
            }
        })
        
        present(alert, animated: true)
    }
    
    
    // MARK: - Actions
    @objc func closeSheet() {
        dismiss(animated: true)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // TODO: Try using .reconfigureItems() func
        switch type {
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .move:
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [indexPath!])
                collectionView.insertItems(at: [newIndexPath!])
                collectionView.reloadData()
                collectionView.isPagingEnabled = false // Needs to be disabled to fix bug causing empty view
                collectionView.scrollToItem(at: newIndexPath!, at: .left, animated: false)
                collectionView.isPagingEnabled = true
            }
        case .update:
            return
        default:
            collectionView.reloadData()
        }
    }
}

extension EditListableItemsViewController: CategorySelectorDelegate {
    func didSelectCategory(_ category: Category?) {
        guard collectionView.indexPathsForVisibleItems.count > 0 else {
            return
        }
        
        let currIndexPath = collectionView.indexPathsForVisibleItems[0]
        try? model.updateCategory(to: category, at: currIndexPath)
    }
}
