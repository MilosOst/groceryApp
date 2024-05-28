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
        // TODO: Fields: Name, Price, Quantity + Unit, Notes
        // TODO: Alternate: VStack of Name, Quantity, Notes, -> Price on right
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
        nameLabel.font = .poppinsFont(varation: .light, size: 16)
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.font = .poppinsFont(varation: .light, size: 14)
        quantityLabel.textColor = .secondaryLabel
        
        infoStack.addArrangedSubviews([nameLabel, quantityLabel])
        
        containerView.addArrangedSubviews([infoStack])
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    func configure(with item: TemplateItem) {
        nameLabel.text = item.item?.name
        if item.quantity != 0 {
            var quantityStr = "\(item.quantity.formatted())"
            if let unit = item.unit {
                quantityStr += " " + unit
            }
            quantityLabel.text = quantityStr
        }
    }
}
