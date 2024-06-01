//
//  ShoppingListHistoryCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-01.
//

import UIKit

class ShoppingListHistoryCell: UITableViewCell {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 16)
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .poppinsFont(varation: .light, size: 14)
        return label
    }()
    
    private lazy var itemCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 14)
        label.textColor = .systemGreen
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.spacing = 4
        
        // Header view with Name and Completion Date
        let headerStack = UIStackView(arrangedSubviews: [nameLabel, UIView(), priceLabel])
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.distribution = .fill
        
        let infoStack = UIStackView(arrangedSubviews: [itemCountLabel, UIView(), dateLabel])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .horizontal
        infoStack.distribution = .fill
        
        containerView.addArrangedSubviews([headerStack, infoStack])
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    
    func configure(with list: ShoppingList) {
        nameLabel.text = list.name
        if let completionDate = list.completionDate {
            let dateFormatter = DateFormatter()
            let dateFormat: String
            if Calendar.current.isDate(completionDate, equalTo: Date(), toGranularity: .year) {
                dateFormat = "MM/dd"
            } else {
                dateFormat = "MM/dd/yyyy"
            }
            dateFormatter.dateFormat = dateFormat
            dateLabel.text = dateFormatter.string(from: completionDate)
        }
        
        let itemCountStr = "\(list.checkedItemsCount) \(list.checkedItemsCount != 1 ? "Items" : "Item")"
        itemCountLabel.text = itemCountStr
        priceLabel.text = list.totalCost.currencyStr
    }
}
