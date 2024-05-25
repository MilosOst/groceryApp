//
//  TemplateCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-25.
//

import UIKit

class TemplateCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let itemCountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }

    private func setupUI() {
        // TODO: Show name, itemCount, isFavourite
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.spacing = 6
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .poppinsFont(varation: .light, size: 16)
        
        itemCountLabel.translatesAutoresizingMaskIntoConstraints = false
        itemCountLabel.font = .poppinsFont(varation: .light, size: 14)
        itemCountLabel.textColor = .secondaryLabel
        
        containerView.addArrangedSubviews([nameLabel, itemCountLabel])
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
        
        accessoryType = .detailDisclosureButton
    }
    
    func configure(with template: Template) {
        nameLabel.text = template.name
        itemCountLabel.text = "\(template.itemCount) Items"
    }
}
