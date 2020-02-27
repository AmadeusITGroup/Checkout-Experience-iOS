//
//  AMScanCardPlugin.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 13/01/2020.
//  Copyright © 2020 Amadeus. All rights reserved.
//

import Foundation

public struct AMScannedCard {
    public let number: String
    public let cvv: String
    public let expiry: String
    public init(number: String, cvv: String, expiry:String) {
        self.number = number
        self.cvv = cvv
        self.expiry = expiry
    }
}


public protocol AMScanCardPlugin: AMCheckoutInitializablePlugin {
    func scanCard(host: UIViewController, callback: @escaping (AMScannedCard?) -> ())
}
