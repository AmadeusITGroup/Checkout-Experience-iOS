//
//  Translator.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 06/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class Translator{
    static var instance = Translator()
    
    let locale: NSLocale
    let currencyFormatter: NumberFormatter
    let currencyWithoutSymbolFormatter: NumberFormatter
    let monthLabels: [Int:String]
    let countryLabels: [String:String]
    
    init(withLocale locale: NSLocale = NSLocale.current as NSLocale) {
        self.locale = locale
        
        currencyFormatter = Translator.initCurrencyFormatter(withLocale: locale)
        currencyWithoutSymbolFormatter = Translator.initCurrencyFormatter(withLocale: locale)
        currencyWithoutSymbolFormatter.currencySymbol = ""
        monthLabels = Translator.initMonthLabels(withLocale: locale)
        countryLabels = Translator.initCountryLabels(withLocale: locale)
    }
    
    private static func initCurrencyFormatter(withLocale locale: NSLocale) -> NumberFormatter {
        let result = NumberFormatter()
        result.usesGroupingSeparator = true
        result.numberStyle = .currency
        result.locale = locale as Locale
        return result
    }
    
    
    private static func initCountryLabels(withLocale locale: NSLocale ) -> [String:String] {
        var result :[String:String] = [:]
        for countryCode in NSLocale.isoCountryCodes {
            let identifier = NSLocale.localeIdentifier(fromComponents:[NSLocale.Key.countryCode.rawValue: countryCode])
            let country = locale.displayName(forKey:NSLocale.Key.identifier, value:identifier)
            result[countryCode] = country
        }
        return result
    }

    private static func initMonthLabels(withLocale locale: NSLocale ) -> [Int:String] {
        var result :[Int:String] = [:]
        let dateDecoder = DateFormatter()
        dateDecoder.dateFormat = "yyyy-MM"
        dateDecoder.locale = Locale(identifier: "en_US_POSIX")
        
        let monthEncoder = DateFormatter()
        monthEncoder.dateFormat = "LLLL"
        monthEncoder.locale = locale as Locale
        
        for i in 1...12 {
            let date = dateDecoder.date(from: "2000-\(i)")
            let nameOfMonth = monthEncoder.string(from: date!)
            result[i] = nameOfMonth
        }
        return result
    }
    
    
    func monthLocalName(month: Int) -> String {
        return monthLabels[month]!
    }
    
    func countryLocalName(code: String) -> String? {
        return countryLabels[code]
    }
    
    func formatAmount(_ amount: Double, currency: String, style: AMAmountFormatterStyle) -> String {
        currencyFormatter.currencyCode = currency
        currencyWithoutSymbolFormatter.currencyCode = currency
        if style == .currencyCodeOnLeft || style == .currencyCodeOnRight {
            var formattedAmount = currencyWithoutSymbolFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
            formattedAmount = formattedAmount.trimmingCharacters(in: .whitespaces)
            if style == .currencyCodeOnLeft {
                return "\(currency) \(formattedAmount)"
            } else {
                return "\(formattedAmount) \(currency)"
            }
        }
        
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }
}
