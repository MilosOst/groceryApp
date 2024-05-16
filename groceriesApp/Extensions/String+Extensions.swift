//
//  String+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-06.
//

import Foundation

extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns whether the trimmed version of the string is empty
    var isTrimmedEmpty: Bool {
        self.trimmed.isEmpty
    }
    
    /// Returns whether the string is composed of only numeric characters (including decimals)
    var isNumeric: Bool {
        guard self != "" else { return true }
        // Verify no more than one decimal point
        let nDots = self.filter({ $0 == "." }).count
        guard nDots <= 1 else { return false }
        
        let allowedChars = CharacterSet(charactersIn: "1234567890.")
        let strSet = CharacterSet(charactersIn: self)
        return allowedChars.isSuperset(of: strSet)
    }
}
