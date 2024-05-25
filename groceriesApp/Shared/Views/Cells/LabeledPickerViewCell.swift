//
//  LabeledPickerViewCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-24.
//

import UIKit

class LabeledPickerViewCell: UITableViewCell {
    let label = UILabel()
    let picker = UISegmentedControl()
    
    var onSelect: ((Int) -> Void)? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 15)
        label.text = "Hello"
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.selectedSegmentTintColor = .systemBlue
        picker.setTitleTextAttributes([.font: UIFont.poppinsFont(varation: .light, size: 14)], for: .normal)
        picker.setTitleTextAttributes([.font: UIFont.poppinsFont(varation: .light, size: 14)], for: .selected)
        picker.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        stackView.addArrangedSubviews([label, picker])
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure<T: Equatable & CustomStringConvertible>(label: String, options: [T], selectedObject: T, onSelect: ((Int) -> Void)? = nil) {
        picker.removeAllSegments()
        
        self.label.text = label
        self.onSelect = onSelect
        
        for (index, option) in options.enumerated() {
            let action = UIAction(title: option.description, handler: { _ in
                onSelect?(index)
            })
            picker.insertSegment(action: action, at: index, animated: true)
        }
        let selectedIndex = options.firstIndex(of: selectedObject)
        if let selectedIndex = selectedIndex {
            picker.selectedSegmentIndex = selectedIndex
        }
    }
}
