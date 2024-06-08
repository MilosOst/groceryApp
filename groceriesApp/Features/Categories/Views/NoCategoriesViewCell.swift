//
//  NoCategoriesViewCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-05.
//

import UIKit

// TODO: Remove? Not needed?
class NoCategoriesViewCell: UITableViewCell {
    var onTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Categories Found"
        label.font = .poppinsFont(varation: .medium, size: 16)
        label.textAlignment = .center
        
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.title = "New Category"
        config.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.poppinsFont(varation: .medium, size: 16)
            return outgoing
        }
        
        
        let createButton = UIButton(configuration: config)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.removeTarget(self, action: nil, for: .allEvents)
        createButton.addTarget(self, action: #selector(createBtnPressed(_:)), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [label, createButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        
        selectionStyle = .none
    }
    
    @objc func createBtnPressed(_ sender: UIButton) {
        onTap?()
    }
}
