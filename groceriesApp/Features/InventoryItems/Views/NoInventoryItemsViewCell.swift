//
//  NoInventoryItemsViewCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-07.
//

import UIKit

class NoInventoryItemsViewCell: UITableViewCell {
    var onButtonTap: (() -> Void)?
    
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
        containerView.alignment = .center
        containerView.distribution = .fill
        containerView.spacing = 12
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Items Found"
        label.font = .poppinsFont(varation: .medium, size: 16)
        label.textAlignment = .center
        
        // Set up create button
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.title = "Create Item"
        config.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.poppinsFont(varation: .medium, size: 16)
            return outgoing
        }
        
        let createButton = UIButton(configuration: config)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createButtonPressed(_:)), for: .touchUpInside)
        
        containerView.addArrangedSubviews([label, createButton])
        contentView.addSubview(containerView)
        containerView.constrainToEdgesOf(view: contentView, insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
    }
    
    @objc func createButtonPressed(_ sender: UIButton) {
        onButtonTap?()
    }
}
