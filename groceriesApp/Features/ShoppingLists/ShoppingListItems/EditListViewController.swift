//
//  EditListViewController.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-08.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class EditListViewController: UICollectionViewController {
    private let fetchedResultsController: NSFetchedResultsController<ListItem>
    private lazy var dataSource = makeDataSource()
    private let initialItem: ListItem
    
    init(fetchedResultsController: NSFetchedResultsController<ListItem>, startItem: ListItem) {
        self.fetchedResultsController = fetchedResultsController
        self.initialItem = startItem
        super.init(collectionViewLayout: Self.makeLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = dataSource
        collectionView.isPagingEnabled = true
        
        self.loadData()
        collectionView.scrollToItem(at: fetchedResultsController.indexPath(forObject: initialItem)!, at: .top, animated: true)
    }
    
    private static func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, ListItem> {
        return UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, listItem) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
                var config = UIListContentConfiguration.cell()
                config.text = listItem.item?.name
                cell.contentConfiguration = config
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

    // MARK: UICollectionViewDelegate

}
