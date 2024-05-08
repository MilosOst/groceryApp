//
//  ShoppingListItemCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-07.
//

import UIKit

class ShoppingListItemCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let checkButton = UIButton()
    
    private var checkboxHandler: ((ShoppingListItemCell) -> Void)? = nil
    
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
        
        // Add text label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .poppinsFont(varation: .light, size: 16)
        
        // Configure button
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkButton.contentVerticalAlignment = .fill
        checkButton.contentHorizontalAlignment = .fill
        checkButton.imageView?.contentMode = .scaleAspectFit
        checkButton.imageView?.tintColor = .secondaryLabel
        checkButton.removeTarget(self, action: nil, for: .allEvents)
        checkButton.addTarget(self, action: #selector(checkBoxPressed(_:)), for: .touchUpInside)
        
        stackView.addArrangedSubviews([checkButton, nameLabel])
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

    func configure(with item: ListItem, handler: @escaping ((ShoppingListItemCell) -> Void)) {
        checkboxHandler = handler
        if item.isChecked {
            let attributedName = NSMutableAttributedString(string: item.item!.name!)
            attributedName.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributedName.length))
            nameLabel.attributedText = attributedName
            
            // Set checkbox as checked
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkButton.imageView?.tintColor = .systemGreen
        } else {
            let attributedName = NSAttributedString(string: item.item!.name!)
            nameLabel.attributedText = attributedName
            checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            checkButton.imageView?.tintColor = .secondaryLabel
        }
        
        // Configure quantity badge
        var quantityText: String
        if let unit = item.item?.unit {
            quantityText = "\(item.quantity.formatted()) \(unit)"
        } else {
            quantityText = "\(item.quantity.formatted())"
        }
        
        let size: CGFloat = 24
        let digits = CGFloat(quantityText.count)
        let width = max(size, 0.55 * size * digits)
        
        let badge = UILabel(frame: .init(x: 0, y: 0, width: width, height: size))
        badge.text = quantityText
        badge.layer.cornerRadius = size / 2
        badge.layer.masksToBounds = true
        badge.textAlignment = .center
        badge.backgroundColor = .systemBlue
        badge.textColor = .white
        badge.font = .poppinsFont(varation: .light, size: 14)
        accessoryView = badge
        self.accessoryType = .none
    }
    
    @objc func checkBoxPressed(_ sender: UIButton) {
        checkboxHandler?(self)
    }
}
