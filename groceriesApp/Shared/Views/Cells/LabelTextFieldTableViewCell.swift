//
//  LabelTextFieldTableViewCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-05.
//

import UIKit


protocol LabelTextFieldCellDelegate: AnyObject {
    func textDidChange(inCell cell: LabelTextFieldTableViewCell, to text: String?)
}

/// TableViewCell that contains a UILabel and a UITextfield
class LabelTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    let label = UILabel()
    let textField = UITextField()
    
    weak var delegate: LabelTextFieldCellDelegate?
    
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
        
        // Add tap gesture recogniser to stackview to put focus on TextField
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stackViewTapped(_:)))
        stackView.addGestureRecognizer(tapGesture)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 15)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.textAlignment = .right
        textField.clearButtonMode = .whileEditing
        textField.font = .poppinsFont(varation: .light, size: 15)
        
        stackView.addArrangedSubviews([label, textField])
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(label: String, placeholder: String?, text: String?) {
        self.label.text = label
        self.textField.placeholder = placeholder
        self.textField.text = text
    }
    
    // MARK: - Property Change Delegate Handlers
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.textDidChange(inCell: self, to: textField.text)
    }
    
    @objc func stackViewTapped(_ sender: UIStackView) {
        textField.becomeFirstResponder()
    }
}
