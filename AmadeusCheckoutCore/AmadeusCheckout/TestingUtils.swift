//
//  TestingUtils.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 16/10/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


public func __AMCheckout_setBackendMockDelay(_ delay: Double) {
    BackendServicesMock.delay = delay
}
