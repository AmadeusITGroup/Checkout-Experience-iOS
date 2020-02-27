//
//  CardFormatter.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 08/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

class CardFormatter {
    static func placehodlerCardSplit(for vendor: String) -> [Int]{
        switch vendor {
        case "amex": return [4,6,5]
        case "diners": return [4,6,4]
        case "uatp": return [4,5,6]
        default: return [4,4,4,4]
        }
    }
    static func cardSplit(for vendor: String) -> [Int]{
        switch vendor {
        case "amex", "diners": return [4,6,9]
        case "uatp": return [4,5,10]
        default: return [4,4,4,4,3]
        }
    }
    static func cvvLength(for vendor: String) -> Int{
        switch vendor {
        case "amex": return 4
        default: return 3
        }
    }
    
    static func format(_ ccNumber: String, vendor: String = "") -> String {
        let splits = cardSplit(for: vendor)
        
        let input = ccNumber[0, 19]
        var result = ""
        var start = 0
        var end = 0
        for i in splits {
            end = start + i
            result += input[start, end]+" "
            start = end
        }
        return result.trimmingCharacters(in: .whitespaces)
    }
    
    static func unformat(_ ccNumber: String) -> String{
        return ccNumber.replacingOccurrences(of: " ", with: "")
    }
}
