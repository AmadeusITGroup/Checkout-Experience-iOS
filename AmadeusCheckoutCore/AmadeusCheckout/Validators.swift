//
//  Validators.swift
//  AmadeusCheckout
//
//  Created by Hela OTHMANI on 29/05/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


protocol Validator {
    typealias SuccessHandler = ()->Void
    typealias FailureHandler = (_ errorMessage: String)->Void
    
    /*
    Function to check if value is valid or not.
    Implementations have to call the successHandler if the value is correct, and the
    failureHandler otherwise.
    successHandler or failureHandler should never be called several times.
    */
    func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void
    
}

enum ValidatorFactory {
    case ccNum
    case expiryDate
    case cvv
    case requiredField
    case maxLength(Int)
    case minLength(Int)
    case requiredMinMaxLength(Bool?, Int?, Int?)
    
    func create() -> Validator {
        switch self {
        case .ccNum:
            let ctx = AMCheckoutContext.sharedContext!
            return ObFeesCCNumValidator(ctx: ctx, dynamic: ctx.options?.dynamicVendor == true)
        case .expiryDate:
            return ExpiryDateValidator()
        case .cvv:
            let ctx = AMCheckoutContext.sharedContext!
            return CvvValidator(ctx: ctx)
        case .requiredField:
            return RequiredFieldValidator()
        case let .maxLength(len):
            return MaxLengthValidator(maxLength:len)
        case let .minLength(len):
            return MinLengthValidator(minLength:len)
        case let .requiredMinMaxLength(required, minLen, maxLen):
            var validators: [Validator] = []
            if required == true { validators.append(RequiredFieldValidator()) }
            if minLen != nil { validators.append(MinLengthValidator(minLength:minLen!)) }
            if maxLen != nil { validators.append(MaxLengthValidator(maxLength:maxLen!)) }
            if validators.count == 1 { return validators[0] }
            return ValidatorChain(validators)
        }
    }
}


/**
 CCNumValidator: Validator for credit card number.
 
 This validator is asynchronous, and has a dependency on the data model to trigger
 the bin validation.
 The validity of a specific credit card number is dependant on the vendor selected
 in the data model: for a given number, the isValid function may accept or reject it
 depending on the vendor.
 It means the validation needs to be done again when the vendor changes.
 
 Optimization:
 If the isValid method is called several times for the same BIN+VendorCode,
 only one call to the bin table is done.
 Nevertheless, the isValid method guarantees to call either the successHandler
 or failureHandler depending on the result of the call.

 */
class CCNumValidator: Validator {
    
    weak var ctx : AMCheckoutContext?
    var dynamic : Bool
    
    init(ctx : AMCheckoutContext, dynamic: Bool) {
        self.ctx = ctx
        self.dynamic = dynamic
    }
    
    
    //Length and luhn validator
    private func staticCheck(_ value: String, _ vendor:CreditCardVendor?, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void {
        // CC num cannot be empty
        guard !value.isEmpty else {
            failureHandler("mandatory".localize(type: .errorField))
            return
        }
        
        // If CC num is shorter than 6, we cannot retrieve or check vendor
        guard value.count >= 6 else {
            failureHandler("luhn".localize(type: .errorField))
            return
        }
        
        // If vendor is not set, it means it's invalid or we didn't manage to retrieve it
        guard let vendor = vendor else {
            if dynamic {
                failureHandler("unsupported".localize(type: .errorField))
            } else {
                failureHandler("bin".localize(type: .errorField))
            }
            return
        }
        
        // If CC num doesn't match luhn (for luhn enabled card), or is too short, it's not valid
        guard  (vendor.hasLuhn && value.count >= 12 && CCNumValidator.luhnCheck(value)) || (!vendor.hasLuhn && value.count >= 8) else {
            failureHandler("luhn".localize(type: .errorField))
            return
        }
        
        successHandler()
    }
    
    private static func luhnCheck(_ value: String) -> Bool{
        var sum = 0
        let digitStrings = value.reversed().map { String($0) }
        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1
                
                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return (sum % 10 == 0)
    }
    
    func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void{
        let creditCardMethod = ctx?.dataModel?.selectedPaymentMethod as? CreditCardPaymentMethod
    
        if (value.count < 6) || (!dynamic && creditCardMethod!.vendor.id.isEmpty) {
            // If CC lenght is shorter than 6, or no vendor is selected in manual mode,
            // no need for a asynchronous check, we can call staticCheck instead.
            staticCheck(value, nil, successHandler: successHandler, failureHandler: failureHandler)
            if dynamic {
                ctx?.dataModel?.resetVendor()
            }
            return
        }
        
        ctx?.dataModel?.triggerBinValidation(responseHandler: {[weak self] vendor in
            self?.staticCheck(value, vendor, successHandler: successHandler, failureHandler: failureHandler)
        }, failureHandler: {[weak self]  error in
            if error == .technicalUnreachableNetwork {
                self?.ctx?.closeWithStatus(.failure, error: NSError.checkoutError(type:.networkFailure, feature:.binValidation))
            } else {
                failureHandler("unsupported".localize(type: .errorField))
            }
        })
    }
}

class ObFeesCCNumValidator: CCNumValidator {
    override func isValid(_ value: String, successHandler: @escaping SuccessHandler, failureHandler: @escaping FailureHandler) {
        ctx?.dataModel?.resetObFees()
        super.isValid(value, successHandler: {[weak self] in
            if self?.ctx?.dataModel?.calculateObFee == true {
                // As soon as the CC is validated, we trigger an obfees action
                self?.ctx?.dataModel?.triggerObFees(
                    successHandler: successHandler,
                    failureHandler: {[weak self]  error in
                        if error == .technicalUnreachableNetwork {
                            self?.ctx?.closeWithStatus(.failure, error: NSError.checkoutError(type:.networkFailure, feature:.obFeesComputation))
                        } else {
                            failureHandler("unsupported".localize(type: .errorField))
                        }
                    }
                )
            } else {
                successHandler()
            }
        }, failureHandler: failureHandler)
    }
}

class ExpiryDateValidator: Validator {
    static let errorMessage = "expiryDate".localize(type: .errorField)
    func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void {
        let date = value.split(separator: "/")
        if date.count != 2{
            failureHandler(ExpiryDateValidator.errorMessage)
            return
        }
        let currentYear = Calendar.current.component(.year, from: Date()) % 100 //To get last two digits
        let currentMonth = Calendar.current.component(.month, from: Date())
        let month = Int(date[0])!
        let year = Int(date[1])!
        
        if month < 1 || month > 12 || year < currentYear || (year == currentYear && month < currentMonth){
            failureHandler(ExpiryDateValidator.errorMessage)
        }else{
            successHandler()
        }
    }
}


class CvvValidator: Validator {
    weak var ctx : AMCheckoutContext?
    
    init(ctx : AMCheckoutContext) {
        self.ctx = ctx
    }
    
    func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void
    {
        let creditCardMethod = ctx?.dataModel?.selectedPaymentMethod as? CreditCardPaymentMethod
        let expectedCvvLength = creditCardMethod?.expectedCvvLength ?? 3
        
        if expectedCvvLength == value.count {
            successHandler()
        }else{
            let errorMessage = "cvv".localize(type: .errorField).replacingOccurrences(of: "{0}", with: String(expectedCvvLength))
            failureHandler(errorMessage)
        }
    }
}

class RequiredFieldValidator: Validator {
    static let errorMessage = "mandatory".localize(type: .errorField)
    func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void {
        if value.count > 0 {
            successHandler()
        }else {
            failureHandler(RequiredFieldValidator.errorMessage)
        }
    }
}

class MaxLengthValidator: Validator {
    static let errorMessage = "maxLength".localize(type: .errorField)
    let maxLength: Int
    
    init(maxLength: Int) {
        self.maxLength = maxLength
    }
    func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void {
        if value.count <= maxLength{
            successHandler()
        }else{
            failureHandler(MaxLengthValidator.errorMessage.replacingOccurrences(of: "{0}", with: String(maxLength)))
        }
    }
}

class MinLengthValidator: Validator {
    static let errorMessage = "minLength".localize(type: .errorField)
    let minLength: Int
    
    init(minLength: Int) {
        self.minLength = minLength
    }
    func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void {
        if value.count >= minLength{
            successHandler()
        }else{
            failureHandler(MinLengthValidator.errorMessage.replacingOccurrences(of: "{0}", with: String(minLength)))
        }
    }
}


class ValidatorChain: Validator {
    let head: Validator?
    let tail: ValidatorChain?
    init(_ chain: [Validator]) {
        self.head = chain.first
        self.tail = chain.count>1 ? ValidatorChain(Array(chain.dropFirst())) : nil
    }
    func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void {
        guard let head = head else {
            successHandler()
            return
        }
        head.isValid(value, successHandler: {
            guard let tail = self.tail else {
                successHandler()
                return
            }
            tail.isValid(value, successHandler: successHandler, failureHandler: failureHandler)
        }) { (errorMessage) in
            failureHandler(errorMessage)
        }
    }
}
