//
//  ShoppingListCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-12.
//

import UIKit

class ShoppingListCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let creationDateLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()
    
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
        stackView.axis = .vertical
        stackView.spacing = 8
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .poppinsFont(varation: .medium, size: 16)
        
        creationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        creationDateLabel.font = .poppinsFont(varation: .light, size: 14)
        creationDateLabel.textColor = .secondaryLabel
        
        let progressStackView = UIStackView()
        progressStackView.translatesAutoresizingMaskIntoConstraints = false
        progressStackView.axis = .horizontal
        progressStackView.alignment = .center
        progressStackView.spacing = 8
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        progressView.tintColor = .systemGreen
        progressView.trackTintColor = .lightGray
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "0/0"
        progressLabel.textColor = .secondaryLabel
        progressLabel.font = .poppinsFont(varation: .light, size: 14)
        
        progressStackView.addArrangedSubviews([progressView, progressLabel])
        stackView.addArrangedSubviews([nameLabel, creationDateLabel, progressStackView])
        contentView.addSubview(stackView)
        let guide = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8),
        ])
        
        // Configure accessory
        accessoryType = .detailButton
    }
    
    func configure(with list: ShoppingList) {
        nameLabel.text = list.name
        if let creationDate = list.creationDate {
            creationDateLabel.text = creationDate.formatted(date: .abbreviated, time: .omitted)
        }
        
        let progress: Float = (list.itemCount > 0) ? (Float(list.checkedItemsCount) / Float(list.itemCount)) : 0
        progressLabel.text = "\(list.checkedItemsCount)/\(list.itemCount)"
        progressView.progress = progress
    }
}
