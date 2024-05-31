//
//  InventoryItemSelectionCell.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-06.
//

import UIKit

class InventoryItemSelectionCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    func configure(name: String, isFavourite: Bool, isSelected: Bool) {
        var config = UIListContentConfiguration.cell()
        config.text = name
        config.textProperties.font = .poppinsFont(varation: .light, size: 16)
        
        // Set up image view indicating selection
        
        let imageName = isSelected ? "checkmark.circle.fill" : "circle"
        let tintColor: UIColor = isSelected ? .systemGreen : .systemBlue
        config.image = UIImage(systemName: imageName)
        config.imageProperties.tintColor = tintColor
        contentConfiguration = config
        
        accessoryType = .detailButton
//        if isFavourite {
//            let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
//            imageView.tintColor = .systemYellow
//            self.accessoryView = imageView
//        } else {
//            self.accessoryView = nil
//        }
    }
}
