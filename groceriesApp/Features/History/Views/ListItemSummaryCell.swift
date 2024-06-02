//
//  ListItemSummaryCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-02.
//

import UIKit

/// Cell used to display the summary of a ListItem within a summary/history page
class ListItemSummaryCell: UITableViewCell {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 16)
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 14)
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
        selectionStyle = .none
        
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.distribution = .fill
        
        let nameQuantityStack = UIStackView(arrangedSubviews: [nameLabel, quantityLabel])
        nameQuantityStack.translatesAutoresizingMaskIntoConstraints = false
        nameQuantityStack.axis = .vertical
        nameQuantityStack.spacing = 4
        
        containerView.addArrangedSubviews([nameQuantityStack, UIView(), priceLabel])
        contentView.addSubview(containerView)
        containerView.constrainToEdgesOf(view: contentView, insets: .init(top: 8, left: 16, bottom: 8, right: 16))
    }
    
    func configure(with item: ListItem) {
        nameLabel.text = item.item?.name
        priceLabel.text = (item.price != 0) ? Double(item.price).currencyStr : nil
        if item.quantity != 0 {
            var quantityStr: String
            if let unit = item.unit {
                quantityStr = "\(item.quantity.formatted()) \(unit)"
            } else {
                quantityStr = item.quantity.formatted()
            }
            quantityLabel.text = quantityStr
        } else {
            quantityLabel.text = nil
        }
    }
}
