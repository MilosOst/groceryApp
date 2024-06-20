//
//  EditListableItemCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-15.
//

import UIKit

protocol EditListableItemCellDelegate: AnyObject {
    func quantityDidChange(in cell: EditListableItemCell, to quantity: String?)
    func unitDidChange(in cell: EditListableItemCell, to unit: String?)
    func priceDidChange(in cell: EditListableItemCell, to price: String?)
    func notesDidChange(in cell: EditListableItemCell, to text: String)
    func categoryBtnPressed(_ cell: EditListableItemCell)
    func removePressed(_ cell: EditListableItemCell)
    func renamePressed(_ cell: EditListableItemCell)
}

class EditListableItemCell: UICollectionViewCell, ExpandingTextViewDelegate {
    weak var delegate: EditListableItemCellDelegate?
    
    private lazy var quantityField: LabelTextFieldView = {
        return LabelTextFieldView(label: "Quantity", placeholder: "Quantity", keyboardType: .decimalPad, onTextChange: { [self] text in
            delegate?.quantityDidChange(in: self, to: text)
        })
    }()
    
    private lazy var unitField: LabelTextFieldView = {
        return LabelTextFieldView(label: "Unit", placeholder: "Unit", onTextChange: { [self] text in
            delegate?.unitDidChange(in: self, to: text)
        })
    }()
    
    private lazy var priceField: LabelTextFieldView = {
        return LabelTextFieldView(label: "Price", placeholder: "Price", keyboardType: .decimalPad, onTextChange: { [self] text in
            delegate?.priceDidChange(in: self, to: text)
        })
    }()
    
    private lazy var notesField: ExpandingTextView = {
        return ExpandingTextView(placeholder: "Notes", returnStyle: .onNewline, delegate: self)
    }()
    
    private lazy var categoryBtn: UIButton = {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .systemBlue
        config.title = "Category"
        config.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.poppinsFont(varation: .medium, size: 16)
            return outgoing
        }
        
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(categoryBtnPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var renameBtn: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .label
        config.title = "Rename"
        config.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.poppinsFont(varation: .medium, size: 16)
            return outgoing
        }
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(renamePressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var removeBtn: UIButton = {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .systemRed
        config.title = "Remove"
        config.imagePadding = 12
        config.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.poppinsFont(varation: .medium, size: 16)
            return outgoing
        }
        
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(removePressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.spacing = 14
        containerView.distribution = .fill
        containerView.isUserInteractionEnabled = true
        
        // TOOD: Add dismiss on tap
        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        containerView.addGestureRecognizer(dismissGesture)
        
        containerView.addArrangedSubviews([
            quantityField, unitField, priceField, categoryBtn, notesField, renameBtn, removeBtn, UIView()
        ])
        containerView.setCustomSpacing(20, after: notesField)
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    func configure(with item: ListableItem, delegate: EditListableItemCellDelegate?) {
        self.delegate = delegate
        let quantityStr = item.quantity != 0 ? item.quantity.formatted() : nil
        quantityField.setText(quantityStr)
        unitField.setText(item.unit)
        categoryBtn.setTitle(item.item?.categoryName, for: .normal)
//        let priceStr = item.price == 0 ? nil : item.price.formatted()
        let priceStr = item.price == 0 ? nil : String(format: "%.2f", item.price)
        priceField.setText(priceStr)
        notesField.setText(text: item.notes)
    }
    
    // MARK: - ExpandingTextView Delegate
    func expandingTextViewDidChange(_ text: String) {
        delegate?.notesDidChange(in: self, to: text)
    }
    
    // MARK: - Actions
    @objc func dismissKeyboard() {
        endEditing(true)
    }
    
    @objc func renamePressed(_ sender: UIButton) {
        delegate?.renamePressed(self)
    }
    
    @objc func categoryBtnPressed(_ sender: UIButton) {
        endEditing(true)
        delegate?.categoryBtnPressed(self)
    }
    
    @objc func removePressed(_ sender: UIButton) {
        delegate?.removePressed(self)
    }
}
