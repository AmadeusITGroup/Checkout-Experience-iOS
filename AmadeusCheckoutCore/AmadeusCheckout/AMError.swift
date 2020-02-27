//
//  AMError.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 28/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


extension NSError {
    @objc public var amErrorType: AMErrorType {
        return userInfo[AMConstants.ErrorTypeKey] as! AMErrorType
    }
    
    @objc public var amErrorFeature: AMErrorFeature {
        return userInfo[AMConstants.ErrorFeatureKey] as! AMErrorFeature
    }
}

@objc public class AMError: NSObject {
    @objc static public func typeToString(_ type: AMErrorType) -> String? {
        return type.description
    }
    @objc static public func featureToString(_ feature: AMErrorFeature) -> String? {
        return feature.description
    }
}

@objc public enum AMErrorType: Int {
    case networkFailure = 0
    case unexpectedError = 1
    case paymentError = 2
    case sessionTimeout = 3
    
    public var description: String {
        switch self {
        case .networkFailure: return "networkFailure"
        case .unexpectedError: return "unexpectedError"
        case .paymentError: return "paymentError"
        case .sessionTimeout: return "sessionTimeout"
        }
    }
}

@objc public enum AMErrorFeature: Int {
    case loadMethodOfPayments
    case addCreditCard
    case addAlternativeMethodOfPayment
    case verifyAfterRedirection
    case webViewRedirection
    case binValidation
    case obFeesComputation
    case none
    
    public var description: String {
        switch self {
        case .loadMethodOfPayments: return "loadMethodOfPayments"
        case .addCreditCard: return "addCreditCard"
        case .addAlternativeMethodOfPayment: return "addAlternativeMethodOfPayment"
        case .verifyAfterRedirection: return "verifyAfterRedirection"
        case .webViewRedirection: return "webViewRedirection"
        case .binValidation: return "binValidation"
        case .obFeesComputation: return "obFeesComputation"
        case .none: return "none"
        }
    }
}
