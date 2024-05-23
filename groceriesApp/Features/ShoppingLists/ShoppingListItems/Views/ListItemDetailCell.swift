//
//  ListItemDetailCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-09.
//

import UIKit

// TODO: Add edit function
protocol ListItemEditDelegate: AnyObject {
    func quantityDidChange(_ cell: ListItemDetailCell, to quantity: String?)
    func unitDidChange(_ cell: ListItemDetailCell, to unit: String?)
    func priceDidChange(_ cell: ListItemDetailCell, to price: String?)
    func notesDidChange(_ cell: ListItemDetailCell, to text: String)
    func editPressed(_ cell: ListItemDetailCell)
    func removePressed(_ cell: ListItemDetailCell)
}

class ListItemDetailCell: UICollectionViewCell, ExpandingTextViewDelegate {
    private lazy var notesField: ExpandingTextView = {
        return ExpandingTextView(placeholder: "Notes", returnStyle: .onNewline, delegate: self)
    }()
    
    private lazy var quantityField: LabelTextFieldView = {
        return LabelTextFieldView(label: "Quantity", placeholder: "Quantity", keyboardType: .decimalPad, onTextChange: { [self] text in
            self.delegate?.quantityDidChange(self, to: text)
        })
    }()
    
    private lazy var unitField: LabelTextFieldView = {
        return LabelTextFieldView(label: "Unit", placeholder: "Unit", onTextChange: { [self] text in
            self.delegate?.unitDidChange(self, to: text)
        })
    }()
    
    private lazy var priceField: LabelTextFieldView = {
        return LabelTextFieldView(label: "Price", placeholder: "Price", keyboardType: .decimalPad, onTextChange: { [self] price in
            delegate?.priceDidChange(self, to: price)
        })
    }()
    
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
        
        let editButton = setupEditButton()
        let deleteButton = setupDeleteButton()
        
        stackView.addArrangedSubviews([quantityField, unitField, priceField, notesField, editButton, deleteButton, UIView()])
        stackView.setCustomSpacing(20, after: notesField)
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    private func setupEditButton() -> UIButton {
        var config = UIButton.Configuration.bordered()
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "pencil")
        config.imagePadding = 12
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        let title = NSMutableAttributedString(string: "Edit Item")
        title.addAttribute(.font, value: UIFont.poppinsFont(varation: .medium, size: 16), range: NSRange(location: 0, length: title.length))
        button.setAttributedTitle(title, for: .normal)
        button.setTitleColor(.systemBlue.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(editPressed(_:)), for: .touchUpInside)
        return button
    }
    
    private func setupDeleteButton() -> UIButton {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .systemRed
        config.image = UIImage(systemName: "trash")
        config.imagePadding = 12
        
        let deleteButton = UIButton(configuration: config)
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
        quantityField.setText(item.quantity.formatted())
        unitField.setText(item.item?.unit)
        let priceStr = item.price == 0 ? nil : item.price.formatted()
        priceField.setText(priceStr)
        notesField.setText(text: item.notes)
    }
    
    // MARK: - ExpandingTextView Delegate
    func expandingTextViewDidChange(_ text: String) {
        delegate?.notesDidChange(self, to: text)
    }
    
    @objc func editPressed(_ sender: UIButton) {
        delegate?.editPressed(self)
    }
    
    // MARK: - Actions
    @objc func deletePressed(_ sender: UIButton) {
        delegate?.removePressed(self)
    }
}
