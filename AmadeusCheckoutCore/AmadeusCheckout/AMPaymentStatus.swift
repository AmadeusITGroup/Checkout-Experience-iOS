//
//  AMPaymentStatus.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 24/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


@objc public enum AMPaymentStatus : Int {
    case success
    case failure
    case unknown
    case cancellation
}
