//
//  String+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-05-06.
//

import Foundation

extension String {
    /// Returns whether the trimmed version of the string is empty
    var isTrimmedEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
