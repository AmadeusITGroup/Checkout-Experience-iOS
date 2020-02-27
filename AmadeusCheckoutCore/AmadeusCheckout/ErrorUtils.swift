//
//  ErrorUtils.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 28/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation



extension NSError {
    static func checkoutError(type: AMErrorType, feature: AMErrorFeature) -> NSError {
        let code = type.rawValue
        
        var userInfo: [String: Any] = [:]
        userInfo[AMConstants.ErrorTypeKey] = type
        userInfo[AMConstants.ErrorFeatureKey] = feature
        
        return NSError(domain: AMConstants.AmadeusCheckoutDomain, code: code, userInfo: userInfo)
        
    }
}
