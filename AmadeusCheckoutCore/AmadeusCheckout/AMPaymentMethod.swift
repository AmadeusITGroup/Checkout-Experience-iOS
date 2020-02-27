//
//  AMPaymentMethod.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 24/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


public class AMPaymentMethod : NSObject {
    init(paymentMethodType: AMPaymentMethodType, name: String, identifier: String){
        self.paymentMethodType = paymentMethodType
        self.name = name
        self.identifier = identifier
        super.init()
    }
    
    @objc public let paymentMethodType: AMPaymentMethodType
    @objc public let name: String
    @objc public let identifier: String
    
    @objc static public func typeToString(_ feature: AMPaymentMethodType) -> String? {
        return feature.description
    }
}
