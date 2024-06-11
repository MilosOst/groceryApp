//
//  EmptyResultsView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-10.
//

import UIKit

class EmptyResultsView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .medium, size: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .poppinsFont(varation: .light, size: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(_ title: String, message: String, imageName: String) {
        super.init(frame: .zero)
        setupUI()
        titleLabel.text = title
        messageLabel.text = message
        imageView.image = UIImage(systemName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.setCustomSpacing(6, after: imageView)
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 44),
//            imageView.widthAnchor.constraint(equalToConstant: 44),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
    }
}
