//
//  EditTemplateItemsViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-26.
//

import UIKit
import CoreData

private let cellID = "ItemCell"

class EditTemplateItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, TemplateItemEditDelegate {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLayout.makeFullScreenHorizontalPagingLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.keyboardDismissMode = .none
        collectionView.register(TemplateItemEditCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        return collectionView
    }()
    
    private var model: EditTemplateItemsModel!
    
    init(template: Template, startItem: TemplateItem) {
        super.init(nibName: nil, bundle: nil)
        self.model = EditTemplateItemsModel(template: template, startItem: startItem, context: coreDataContext, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        do {
            try model.loadData()
            collectionView.reloadData()
        } catch {
            print(error)
        }
        
        if let indexPathForStartItem = model.indexPathForStartItem {
            collectionView.scrollToItem(at: indexPathForStartItem, at: .top, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh in case of category change
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
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeSheet(_:)))
        navigationItem.leftBarButtonItem = closeButton
        let doneButton = DoneBarButtonItem(target: self, selector: #selector(closeSheet(_:)))
        navigationItem.rightBarButtonItem = doneButton
//        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: .normal)
        title = model.startItem.item?.name
        setTitleFont(.poppinsFont(varation: .medium, size: 16))
    }
    
    // MARK: - CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! TemplateItemEditCell
        cell.configure(with: model.item(at: indexPath), delegate: self)
        return cell
    }
    
    // MARK: - CollectionView Delegate
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
    
    // MARK: - Editing Delegate Methods
    func quantityDidChange(in cell: TemplateItemEditCell, to quantity: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let quantity = Float(quantity ?? "") ?? 0
        try? model.updateQuantity(at: indexPath, quantity: quantity)
    }
    
    func unitDidChange(in cell: TemplateItemEditCell, to unit: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        try? model.updateUnit(at: indexPath, unit: unit)
    }
    
    func priceDidChange(in cell: TemplateItemEditCell, to price: String?) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let price = Float(price ?? "") ?? 0
        try? model.updatePrice(at: indexPath, price: price)
    }
    
    func notesDidChange(_ cell: TemplateItemEditCell, to text: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        try? model.updateNotes(at: indexPath, notes: text)
    }
    
    func categoryBtnPressed(_ cell: TemplateItemEditCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let item = model.item(at: indexPath)
        let categorySelectorVC = CategorySelectionViewController(currentCategory: item.item?.category, delegate: self)
        navigationController?.pushViewController(categorySelectorVC, animated: true)
    }
    
    func renamePressed(_ cell: TemplateItemEditCell) {
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
    
    func removePressed(_ cell: TemplateItemEditCell) {
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
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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

extension EditTemplateItemsViewController: CategorySelectorDelegate {
    func didSelectCategory(_ category: Category) {
        guard collectionView.indexPathsForVisibleItems.count > 0 else {
            return
        }
        
        let currIndexPath = collectionView.indexPathsForVisibleItems[0]
        try? model.updateCategory(to: category, at: currIndexPath)
    }
}
