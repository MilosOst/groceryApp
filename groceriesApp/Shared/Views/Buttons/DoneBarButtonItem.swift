//
//  DoneBarButtonItem.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-14.
//

import UIKit

/// Done Button with custom font
class DoneBarButtonItem: UIBarButtonItem {
    override init() {
        super.init()
        title = "Done"
        
        // Set title text attributes
        let states: [UIControl.State] = [.disabled, .focused, .highlighted, .normal]
        for controlState in states {
            setTitleTextAttributes([NSAttributedString.Key.font: UIFont.poppinsFont(varation: .light, size: 16)], for: controlState)
        }
    }
    
    convenience init(target: AnyObject?, selector: Selector?) {
        self.init()
        self.target = target
        self.action = selector
    }
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
}
