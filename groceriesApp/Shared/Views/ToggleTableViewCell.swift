//
//  ToggleTableViewCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-05.
//

import UIKit

protocol ToggleCellDelegate: AnyObject {
    func toggleDidChange(_ newValue: Bool)
}

class ToggleTableViewCell: UITableViewCell {
    let label = UILabel()
    let toggle = UISwitch()
    
    weak var delegate: ToggleCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // Set up horizontal StackView
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 15)
        
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(toggleDidChange(_:)), for: .valueChanged)
        
        stackView.addArrangedSubviews([label, toggle])
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(label: String, isActive: Bool) {
        self.label.text = label
        toggle.isOn = isActive
    }
    
    @objc func toggleDidChange(_ sender: UISwitch) {
        delegate?.toggleDidChange(sender.isOn)
    }
}
