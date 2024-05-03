//
//  TemplateSelectionCellView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-02.
//

import UIKit

class TemplateSelectionCellView: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    func configure(name: String, itemCount: Int16) {
        var config = UIListContentConfiguration.valueCell()
        config.text = name
        config.secondaryText = "\(itemCount) Items"
        config.textProperties.font = .poppinsFont(varation: .light, size: 16)
        config.secondaryTextProperties.font = .poppinsFont(varation: .medium, size: 14)
        
        contentConfiguration = config
    }
}
