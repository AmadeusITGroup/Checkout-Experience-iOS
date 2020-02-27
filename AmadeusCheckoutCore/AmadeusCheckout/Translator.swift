//
//  Translator.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 06/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class Translator{
    static let countryLabels = ({() -> [String:String] in
        var result :[String:String] = [:]
        for countryCode in NSLocale.isoCountryCodes {
            let identifier = NSLocale.localeIdentifier(fromComponents:[NSLocale.Key.countryCode.rawValue: countryCode])
            let country = (NSLocale.current as NSLocale).displayName(forKey:NSLocale.Key.identifier, value:identifier)
            result[countryCode] = country
        }
        return result
    })()
    
    static let monthLabels = ({() -> [Int:String] in
        var result :[Int:String] = [:]
        let dateDecoder = DateFormatter()
        dateDecoder.dateFormat = "yyyy-MM"
        dateDecoder.locale = Locale(identifier: "en_US_POSIX")
        
        let monthEncoder = DateFormatter()
        monthEncoder.dateFormat = "LLLL"
        
        for i in 1...12 {
            let date = dateDecoder.date(from: "2000-\(i)")
            let nameOfMonth = monthEncoder.string(from: date!)
            result[i] = nameOfMonth
        }
        return result
    })()
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()
    
    
    static func monthLocalName(month: Int) -> String {
        return monthLabels[month]!
    }
    
    static func countryLocalName(code: String) -> String? {
        return countryLabels[code]
    }
    
    static func formatAmount(_ amount: Double, currency: String) -> String {
        currencyFormatter.currencyCode = currency
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }
}
