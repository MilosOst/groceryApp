//
//  TemplateCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import UIKit

class TemplateCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 16)
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

    private func setupUI() {
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .horizontal
        containerView.distribution = .fill
        
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, itemCountLabel])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.distribution = .fill
        
        containerView.addArrangedSubviews([infoStack, UIView(), priceLabel])
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    func configure(with template: Template) {
        nameLabel.text = template.name
        itemCountLabel.text = "\(template.itemCount) \(template.itemCount != 1 ? "Items": "Item")"
        priceLabel.text = template.totalCost.currencyStr
    }
}
