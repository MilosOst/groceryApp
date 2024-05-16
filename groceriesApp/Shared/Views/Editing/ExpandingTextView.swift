//
//  ExpandingTextView.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-16.
//

import UIKit

protocol ExpandingTextViewDelegate: AnyObject {
    func expandingTextViewDidChange(_ text: String)
}

class ExpandingTextView: UITextView, UITextViewDelegate {
    enum ReturnStyle {
        case onNewline
        case none
    }
    
    private let returnStyle: ReturnStyle
    var placeholder: String
    weak var customDelegate: ExpandingTextViewDelegate?
    
    private let placeholderColor = UIColor.lightGray
    private let contentColor = UIColor.label
    
    
    init(placeholder: String = "", returnStyle: ExpandingTextView.ReturnStyle = .none, delegate: ExpandingTextViewDelegate? = nil) {
        self.placeholder = placeholder
        self.returnStyle = returnStyle
        self.customDelegate = delegate
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        super.init(frame: .zero, textContainer: textContainer)
        
        translatesAutoresizingMaskIntoConstraints = false
        isEditable = true
        isScrollEnabled = false
        textColor = .lightGray
        text = placeholder
        layer.borderColor = UIColor.secondaryLabel.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        font = .poppinsFont(varation: .light, size: 14)
        textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textContainer.heightTracksTextView = true
        textContainer.lineFragmentPadding = 8
        self.delegate = self
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init:coder not supported")
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        customDelegate?.expandingTextViewDidChange(textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Change text color if previously showing placholder
        if textView.textColor == placeholderColor {
            textView.text = ""
            textView.textColor = contentColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Insert placeholder if text is empty
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderColor
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard self.returnStyle == .onNewline else { return true }
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: - Actions
    func setText(text: String?) {
        if let newText = text, !newText.isEmpty {
            self.text = newText
            self.textColor = contentColor
        } else {
            self.text = placeholder
            self.textColor = placeholderColor
        }
    }
}
