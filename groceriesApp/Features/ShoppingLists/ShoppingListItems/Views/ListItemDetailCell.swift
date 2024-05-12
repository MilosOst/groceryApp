//
//  ListItemDetailCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-09.
//

import UIKit

protocol ListItemEditDelegate: AnyObject {
    func quantityDidChange(_ cell: ListItemDetailCell, to quantity: String?)
    func unitDidChange(_ cell: ListItemDetailCell, to unit: String?)
    func notesDidChange(_ cell: ListItemDetailCell, to text: String)
    func removePressed(_ cell: ListItemDetailCell)
}

class ListItemDetailCell: UICollectionViewCell, UITextFieldDelegate, UITextViewDelegate {
    private let notesField = UITextView()
    private let quantityTextField = UITextField()
    private let unitField = UITextField()
    
    weak var delegate: ListItemEditDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.distribution = .fill
        
        let quantityRow = makeQuantityRow()
        let unitRow = makeUnitRow()
        setupNotesField()
        
        let deleteButton = setupDeleteButton()
        
        stackView.addArrangedSubviews([quantityRow, unitRow, notesField, deleteButton, UIView()])
        stackView.setCustomSpacing(20, after: notesField)
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    private func makeQuantityRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 10
        
        let quantityLabel = UILabel()
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.text = "Quantity"
        quantityLabel.font = .poppinsFont(varation: .light, size: 16)
        quantityLabel.isUserInteractionEnabled = true
        
        // Add gesture recognizer for label to send focus to textfield
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(quantityLabelPressed(_:)))
        quantityLabel.addGestureRecognizer(gestureRecognizer)
        
        quantityTextField.translatesAutoresizingMaskIntoConstraints = false
        quantityTextField.keyboardType = .decimalPad
        quantityTextField.placeholder = "Quantity"
        quantityTextField.textAlignment = .center
        quantityTextField.font = .poppinsFont(varation: .light, size: 16)
        quantityTextField.borderStyle = .roundedRect
        quantityTextField.clearButtonMode = .whileEditing
        quantityTextField.backgroundColor = .secondarySystemBackground
        quantityTextField.addTarget(self, action: #selector(quantityDidChange(_:)), for: .editingChanged)
        quantityTextField.delegate = self
        
        stackView.addArrangedSubviews([quantityLabel, quantityTextField])
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            quantityTextField.widthAnchor.constraint(equalToConstant: 90),
        ])
        return stackView
    }
    
    private func makeUnitRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 10
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Unit"
        label.font = .poppinsFont(varation: .light, size: 16)
        label.isUserInteractionEnabled = true
        
        // Add gesture recognizer for label to send focus to textfield
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(unitLabelPressed(_:)))
        label.addGestureRecognizer(gestureRecognizer)
        
        unitField.translatesAutoresizingMaskIntoConstraints = false
        unitField.placeholder = "Unit"
        unitField.textAlignment = .center
        unitField.delegate = self
        unitField.borderStyle = .roundedRect
        unitField.clearButtonMode = .whileEditing
        unitField.autocapitalizationType = .none
        unitField.font = .poppinsFont(varation: .light, size: 16)
        unitField.backgroundColor = .secondarySystemBackground
        unitField.addTarget(self, action: #selector(unitDidChange(_:)), for: .editingChanged)
        
        stackView.addArrangedSubviews([label, unitField])
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            unitField.widthAnchor.constraint(equalToConstant: 90)
        ])
        return stackView
    }
    
    private func setupNotesField() {
        notesField.translatesAutoresizingMaskIntoConstraints = false
        notesField.isEditable = true
        notesField.isScrollEnabled = false
        notesField.text = "Notes"
        notesField.textColor = .lightGray
        notesField.textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        notesField.layer.borderColor = UIColor.secondaryLabel.cgColor
        notesField.layer.borderWidth = 1
        notesField.layer.cornerRadius = 8
        notesField.font = UIFont.poppinsFont(varation: .light, size: 14)
        notesField.textContainer.heightTracksTextView = true
        notesField.textContainer.lineFragmentPadding = 8
        notesField.delegate = self
    }
    
    private func setupDeleteButton() -> UIButton {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .systemRed
        config.image = UIImage(systemName: "trash")
        config.imagePadding = 12
        
        let deleteButton = UIButton(configuration: config)
//        let deleteButton = UIButton(type: .system)
//        deleteButton.configuration = config
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deletePressed(_:)), for: .touchUpInside)
        deleteButton.role = .destructive
        let title = NSMutableAttributedString(string: "Remove Item")
        title.addAttribute(NSAttributedString.Key.font, value: UIFont.poppinsFont(varation: .medium, size: 16), range: NSRange(location: 0, length: title.length))
        deleteButton.setAttributedTitle(title, for: .normal)
        deleteButton.setTitleColor(.systemRed.withAlphaComponent(0.5), for: .highlighted)
        
        return deleteButton
    }
    
    func configure(with item: ListItem, delegate: ListItemEditDelegate?) {
        self.delegate = delegate
        quantityTextField.text = "\(item.quantity.formatted())"
        unitField.text = item.item?.unit
        
        if let notes = item.notes, !notes.isEmpty {
            notesField.text = notes
            notesField.textColor = .label
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // All characters allowed in Unit field, only number in quantity
        guard textField == quantityTextField else { return true }
        if textField.text?.filter({ $0 == "." }).count == 1 && string == "." {
            return false
        }
        
        return string.isNumeric
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Remove placeholder if no current text
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Notes"
            textView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.notesDidChange(self, to: textView.text)
    }
    
    // MARK: - Actions
    @objc func quantityLabelPressed(_ sender: UILabel) {
        quantityTextField.becomeFirstResponder()
    }
    
    @objc func unitLabelPressed(_ sender: UILabel) {
        unitField.becomeFirstResponder()
    }
    
    @objc func quantityDidChange(_ sender: UITextField) {
        delegate?.quantityDidChange(self, to: sender.text)
    }
    
    @objc func unitDidChange(_ sender: UITextField) {
        delegate?.unitDidChange(self, to: sender.text)
    }
    
    @objc func deletePressed(_ sender: UIButton) {
        delegate?.removePressed(self)
    }
}
