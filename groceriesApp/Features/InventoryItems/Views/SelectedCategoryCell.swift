//
//  SelectedCategoryCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-05.
//

import UIKit

class SelectedCategoryCell: UITableViewCell {
    private let fieldLabel = UILabel()
    private let selectedLabel = UILabel()
    
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
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        fieldLabel.translatesAutoresizingMaskIntoConstraints = false
        fieldLabel.text = "Category"
        fieldLabel.font = .poppinsFont(varation: .medium, size: 15)
        
        selectedLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedLabel.font = .poppinsFont(varation: .light, size: 15)
        selectedLabel.textAlignment = .right
        
        stackView.addArrangedSubviews([fieldLabel, selectedLabel])
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        accessoryType = .disclosureIndicator
    }
    
    func configure(categoryName: String?) {
        selectedLabel.text = categoryName?.capitalized
    }
}
