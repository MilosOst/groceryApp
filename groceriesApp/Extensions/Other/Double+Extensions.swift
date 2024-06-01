//
//  Double+Extensions.swift
//  groceriesApp
//
//  Created by Milos Abcd on 2024-06-01.
//

import Foundation

extension Double {
    var currencyStr: String {
        let decimalVal = Decimal(floatLiteral: self)
        let currencyCode = Locale.current.currency?.identifier
        let formatStyle = Decimal.FormatStyle.Currency(code: currencyCode ?? "", locale: .current)
        return formatStyle.format(decimalVal)
    }
}
