//
//  TemplateItemCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-24.
//

import UIKit

class TemplateItemCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let quantityLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        // TODO: Make top HStack display name, quantity ,price | Bottom HStack -> Notes (if exist)
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.spacing = 10
        
        let infoStack = UIStackView()
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .horizontal
        infoStack.distribution = .fill
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Test"
        nameLabel.font = .poppinsFont(varation: .light, size: 16)
        infoStack.addArrangedSubviews([nameLabel])
        
        containerView.addArrangedSubviews([infoStack])
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    func configure(price: Float, quantity: Float, notes: String?, inventoryItem: InventoryItem) {
        // TODO: Configure with TemplateItem using background context?
        nameLabel.text = inventoryItem.name
    }
}
