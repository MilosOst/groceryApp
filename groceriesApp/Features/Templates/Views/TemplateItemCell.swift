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
    private let notesLabel = UILabel()
    
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
        containerView.spacing = 6
        
        // Create horizontal stack to center vertically
        let innerStack = UIStackView()
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        innerStack.axis = .horizontal
        innerStack.alignment = .center
        innerStack.spacing = 16
        
        let nameNotesStack = UIStackView(arrangedSubviews: [nameLabel, notesLabel])
        nameNotesStack.translatesAutoresizingMaskIntoConstraints = false
        nameNotesStack.axis = .vertical
        nameNotesStack.spacing = 4
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .poppinsFont(varation: .light, size: 16)
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.font = .poppinsFont(varation: .light, size: 13)
        notesLabel.textColor = .secondaryLabel
        
        let priceQuantityStack = UIStackView(arrangedSubviews: [quantityLabel, priceLabel])
        priceQuantityStack.translatesAutoresizingMaskIntoConstraints = false
        priceQuantityStack.axis = .vertical
        priceQuantityStack.alignment = .trailing
        priceQuantityStack.spacing = 4
        
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.font = .poppinsFont(varation: .light, size: 14)
        quantityLabel.textColor = .secondaryLabel
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .poppinsFont(varation: .light, size: 14)
        priceLabel.textColor = .systemGreen
        
        innerStack.addArrangedSubviews([nameNotesStack, priceQuantityStack])
        containerView.addArrangedSubview(innerStack)
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
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
            quantityLabel.isHidden = false
        } else {
            quantityLabel.text = nil
            quantityLabel.isHidden = true
        }
        
        if item.price != 0 {
            let price = Decimal(floatLiteral: Double(item.price))
            let currencyCode = Locale.current.currency?.identifier
            let formatStyle = Decimal.FormatStyle.Currency(code: currencyCode ?? "", locale: .current)
            priceLabel.text = formatStyle.format(price)
            priceLabel.isHidden = false
        } else {
            priceLabel.text = nil
            priceLabel.isHidden = true
        }
        
        notesLabel.text = item.notes
        notesLabel.isHidden = item.notes == nil
    }
}
