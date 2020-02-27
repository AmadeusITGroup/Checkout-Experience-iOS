//
//  Bundle.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 10/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class FileTools {
    static var mainBundle : Bundle {
        get {
            #if !COCOAPODS
                return Bundle(identifier: "com.amadeus.ios.AmadeusCheckout")!
            #else
                return Bundle(identifier:"org.cocoapods.AmadeusCheckout")!
            #endif
        }
    }
}
