//
//  ListSummaryHeaderView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-02.
//

import UIKit

class ListSummaryHeaderView: UIView {
    var dateChangeHandler: ((Date) -> Void)?
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Completion Date:"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 16)
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        picker.addTarget(self, action: #selector(handleDateChange(_:)), for: .valueChanged)
        return picker
    }()
    
    // Not to confuse with label showing actual total cost
    private lazy var totalSpentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 16)
        label.text = "Total Spent:"
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 16)
        label.textColor = .systemGreen
        return label
    }()
    
    init(dateChangeHandler: ((Date) -> Void)?) {
        self.dateChangeHandler = dateChangeHandler
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .horizontal
        containerView.spacing = 8
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 8
        
        let leftStack = UIStackView(arrangedSubviews: [totalSpentLabel, dateLabel])
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.axis = .vertical
        leftStack.alignment = .leading
        leftStack.spacing = 8
        leftStack.distribution = .fill
        
        let rightStack = UIStackView(arrangedSubviews: [priceLabel, datePicker])
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.axis = .vertical
        rightStack.alignment = .center
        rightStack.spacing = 8
        rightStack.distribution = .fill
        
        containerView.addArrangedSubviews([leftStack, UIView(), rightStack])
        addSubview(containerView)
        containerView.constrainToEdgesOf(view: self, insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    func configure(cost: Double, completionDate: Date) {
        print(cost.currencyStr)
        priceLabel.text = cost.currencyStr
        datePicker.setDate(completionDate, animated: true)
    }
    
    // MARK: - Actions
    @objc func handleDateChange(_ picker: UIDatePicker) {
        dateChangeHandler?(picker.date)
    }
}
