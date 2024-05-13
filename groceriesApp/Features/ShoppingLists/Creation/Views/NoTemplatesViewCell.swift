//
//  NoTemplatesViewCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-03.
//

import UIKit

class NoTemplatesViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        let headerText = UILabel()
        headerText.translatesAutoresizingMaskIntoConstraints = false
        headerText.font = .poppinsFont(varation: .medium, size: 16)
        headerText.text = "No Templates Found"
        headerText.textAlignment = .center
        
        let infoText = UILabel()
        infoText.translatesAutoresizingMaskIntoConstraints = false
        infoText.font = .poppinsFont(varation: .light, size: 14)
        infoText.textColor = .secondaryLabel
        infoText.text = "You do not currently have any templates. Once you create a template, you will be able to select it here to instantly populate a list."
        infoText.numberOfLines = 0
        infoText.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [headerText, infoText])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            infoText.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }

}
