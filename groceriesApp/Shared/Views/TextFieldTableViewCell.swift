//
//  TextFieldTableViewCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-01.
//

import UIKit

protocol TextFieldTableViewCellDelegate: AnyObject {
    func textDidChange(_ text: String)
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    weak var delegate: TextFieldTableViewCellDelegate?
    
    let textField = UITextField()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        selectionStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.poppinsFont(varation: .light, size: 14)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    func configure(placeholder: String?, text: String?) {
        textField.placeholder = placeholder
        textField.text = text
    }
    
    // MARK: - Delegate Handlers
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.textDidChange(textField.text ?? "")
    }
}
