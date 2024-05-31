//
//  ShoppingListItemCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-07.
//

import UIKit

class ShoppingListItemCell: UITableViewCell {
    var checkBoxHandler: ((ShoppingListItemCell) -> Void)?
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = .secondaryLabel
        button.removeTarget(self, action: nil, for: .allEvents)
        button.addTarget(self, action: #selector(checkBoxPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 16)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 14)
        label.textColor = .systemGreen
        return label
    }()
    
    private lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 14)
        label.textColor = .secondaryLabel
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
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 14
        
        let nameNotesStack = UIStackView(arrangedSubviews: [nameLabel, notesLabel])
        nameNotesStack.translatesAutoresizingMaskIntoConstraints = false
        nameNotesStack.axis = .vertical
        nameNotesStack.distribution = .fill
        nameNotesStack.spacing = 0
        
        stackView.addArrangedSubviews([checkButton, nameNotesStack, UIView(), priceLabel])
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            checkButton.widthAnchor.constraint(equalToConstant: 28),
            checkButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configure(with item: ListItem, handler: ((ShoppingListItemCell) -> Void)?) {
        checkBoxHandler = handler
        nameLabel.text = item.item?.name
        notesLabel.text = item.notes
        notesLabel.isHidden = item.notes == nil
        
        // Configure checkbox, background color and text based on if checked
        if item.isChecked {
            let attributedName = NSMutableAttributedString(string: item.item!.name!)
            attributedName.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributedName.length))
            nameLabel.attributedText = attributedName
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkButton.imageView?.tintColor = .systemGreen
            backgroundColor = .systemGreen.withAlphaComponent(0.4)
        } else {
            let attributedName = NSAttributedString(string: item.item!.name!)
            nameLabel.attributedText = attributedName
            checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            checkButton.imageView?.tintColor = .secondaryLabel
            backgroundColor = .systemBackground
        }
        
        // Configure price if exists
        if item.price == 0 {
            priceLabel.text = nil
            priceLabel.isHidden = true
        } else {
            let price = Decimal(floatLiteral: Double(item.price))
            let currencyCode = Locale.current.currency?.identifier
            let formatStyle = Decimal.FormatStyle.Currency(code: currencyCode ?? "", locale: .current)
            priceLabel.text = formatStyle.format(price)
            priceLabel.isHidden = false
        }
        
        // Configure quantity badge
        if item.quantity != 0 {
            var quantityStr: String
            if let unit = item.unit {
                quantityStr = "\(item.quantity.formatted()) \(unit)"
            } else {
                quantityStr = "\(item.quantity.formatted())"
            }
            
            let badge = BadgeViewFactory.makeBadge(text: quantityStr)
            accessoryView = badge
            accessoryType = .none
        } else {
            accessoryView = nil
        }
    }
    
    // MARK: - Actions
    @objc func checkBoxPressed(_ sender: UIButton) {
        checkBoxHandler?(self)
    }
}
