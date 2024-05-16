//
//  LabelTextFieldView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import UIKit

typealias Callback = ((String?) -> Void)?

/// Custom UITextField with a UILabel that sends focus to the text field.
/// - NOTE: Only supports text validation for .decimalPad UIKeyboardType
class LabelTextFieldView: UIView, UITextFieldDelegate {
    private let label = UILabel()
    private let textField = UITextField()
    
    private var onTextChange: ((String?) -> Void)?
    
    init(label: String, placeholder: String? = nil, keyboardType: UIKeyboardType = .default, onTextChange: ((String?) -> Void)? = nil) {
        super.init(frame: .zero)
        self.label.text = label
        self.textField.placeholder = placeholder
        self.textField.keyboardType = keyboardType
        self.onTextChange = onTextChange
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 10
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 16)
        label.isUserInteractionEnabled = true
        
        // Add gesture recognizer on tap to send focus to text field
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelPressed))
        label.addGestureRecognizer(gestureRecognizer)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.font = .poppinsFont(varation: .light, size: 16)
        textField.backgroundColor = .secondarySystemBackground
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            
        // TODO: Add on change
        stackView.addArrangedSubviews([label, textField])
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
    
        addSubview(stackView)
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: 90),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.keyboardType == .decimalPad else { return true }
        // KeyboardType is decimalPad, perform validation
        if textField.text?.filter({ $0 == "." }).count == 1 && string == "." {
            return false
        }
        
        return string.isNumeric
    }
    
    
    @objc func labelPressed() {
        textField.becomeFirstResponder()
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        onTextChange?(sender.text)
    }
    
    func setText(_ text: String?) {
        textField.text = text
    }
}
