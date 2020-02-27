//
//  BinTableCache.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 10/07/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation



class BinTableCache {
    typealias ValidHandler = (_ vendor: CreditCardVendor)->Void
    typealias InvalidHandler = (_ errorMessage: String)->Void
    typealias UnknownHandler = (_ error: BackendError)->Void
    
    struct BinVendorPair: Hashable {
        var bin: String = ""
        var vendor: String = ""
        
        static func == (lhs: BinVendorPair, rhs: BinVendorPair) -> Bool {
            return lhs.bin == rhs.bin && lhs.vendor == rhs.vendor
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(bin)
            hasher.combine(vendor)
        }
    }
    
    
    /**
     BinValidity: Local enum used to store the validity of a BIN+VendorCode pair.
     
     The possibles values are:
     - valid: the pair has been checked against bin table and is valid.
     - invalid: the pair has been checked against bin table and is not valid.
     - ongoing: the validation with bin table is on-going and has not yet returned
     a result.
     This value also store a list of validHandler and failureHanlder,
     as soon as the validaty of the pair is known, all the validHandlers
     are called if it's valid, or all the invalidHandlers are called
     if it's invalid.
     */
    enum BinValidity {
        case valid(CreditCardVendor)
        case invalid
        case ongoing([ValidHandler],[InvalidHandler],[UnknownHandler])
        
        func validHandler(vendor: CreditCardVendor) {
            switch self {
            case let .ongoing(validHandlers, _, _):
                for handler in validHandlers {
                    handler(vendor)
                }
            default: break
            }
        }
        func invalidHandler(_ errorMessage: String) {
            switch self {
            case let .ongoing(_, invalidHandlers, _):
                for handler in invalidHandlers {
                    handler(errorMessage)
                }
            default: break
            }
        }
        func unknownHandler(_ error: BackendError) {
            switch self {
            case let .ongoing(_, _, unknownHandlers):
                for handler in unknownHandlers {
                    handler(error)
                }
            default: break
            }
        }
    }
    var binVendorMap: [BinVendorPair: BinValidity] = [:]
    
    
    /**
     Set the bin/vendor couple as invalid.
 
     This method will call all the invalid handlers that were
     waiting for this couple validity.
     */
    func setInvalid(_ binValue: String, _ vendorValue:String) {
        let binVendor = BinVendorPair(bin:binValue, vendor:vendorValue)
        let responseHandler = binVendorMap[binVendor]
        binVendorMap[binVendor] = .invalid
        responseHandler?.invalidHandler("")
    }
    
    /**
     Set the bin/vendor couple as valid.
 
     This method will call all the valid handlers that were
     waiting for this couple validity.
     */
    func setValid(_ binValue: String, _ vendorValue:String, vendor: CreditCardVendor) {
        let binVendor = BinVendorPair(bin:binValue, vendor:vendorValue)
        let responseHandler = binVendorMap[binVendor]
        binVendorMap[binVendor] = .valid(vendor)
        responseHandler?.validHandler(vendor: vendor)
    }
    
   /**
    Set the bin/vendor couple as not checked.

    This method will call all the error handlers that were
    waiting for this couple validity.
    */
    func setUnknown(_ binValue: String, _ vendorValue:String, error: BackendError) {
        let binVendor = BinVendorPair(bin:binValue, vendor:vendorValue)
        let responseHandler = binVendorMap[binVendor]
        binVendorMap.removeValue(forKey: binVendor)
        responseHandler?.unknownHandler(error)
    }
    
    /**
     Check is a bin/vendor couple is available in the cache.
     
     There are 4 possible cases:
        - bin/vendor has already been checked and is valid
            the validHandler is called immediately, and method returns true.
        - bin/vendor has already been checked and is invalid
            the invalidHandler is called immediately, and method returns true.
        - a check is ongoing for the requested bin/vendor
            the validHandler and invalidHandler are put in a queue, to be called as soon a the result
            is available. Method returns true.
        - bin/vendor has never been checked
            the bin/vendor couple is flagged as ongoing. The validHandler and invalidHandler are put in a queue,
            to be called as soon a the result is available.
     */
    func checkCache(_ binValue: String, _ vendorValue:String, validHandler:@escaping ValidHandler, invalidHandler:@escaping InvalidHandler, unknownHandler:@escaping UnknownHandler) -> Bool {
        let binVendor = BinVendorPair(bin:binValue, vendor:vendorValue)
        if let validity =  binVendorMap[binVendor] {
            switch validity {
            case .invalid:
                // Bin check already failed
                invalidHandler("")
            case let .valid(vendor):
                // Bin check already successful
                validHandler(vendor)
            case let .ongoing(validHandlers, invalidHandlers, unknownHandlers):
                // A bin check for this vendor is already ongoing, we add the response handlers to the list to ensure they are called
                // when we receive the bin response
                binVendorMap[binVendor] = .ongoing(validHandlers+[validHandler], invalidHandlers+[invalidHandler], unknownHandlers+[unknownHandler])
            }
            return true
        }
        binVendorMap[binVendor] = .ongoing([validHandler], [invalidHandler], [unknownHandler])
        return false
    }
}
