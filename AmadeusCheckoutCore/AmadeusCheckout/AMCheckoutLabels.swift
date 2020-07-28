//
//  AMCheckoutLabels.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 10/07/2020.
//  Copyright © 2020 Amadeus. All rights reserved.
//

import Foundation


public class AMCheckoutLabels : NSObject {
    static var overridenStrings: [String: String] = [:]

    @objc static public func overrideLocalizableString(_ key: String, withValue value: String) {
        overridenStrings[key] = value
    }

    static func getOverridenLocalizableString(forKey key: String) -> String? {
        return overridenStrings[key]
    }
}
