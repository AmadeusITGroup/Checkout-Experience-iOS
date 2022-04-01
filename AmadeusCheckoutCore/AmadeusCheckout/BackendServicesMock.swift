//
//  BackendServicesMock.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 19/06/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

fileprivate func inRange(_ card: String, _ binList: [String]) -> Bool {
    for bin in binList {
        if card[0, bin.count] == bin {
            return true
        }
    }
    return false
}

class BackendServicesMock: BackendServices {
    static let MockData: JSON = {
        try! JSON(data:Data(contentsOf: FileTools.mainBundle.url(forResource: "BackendMock", withExtension: "json")!))
    }()
    
    static var delay = 0.5
    static var auto_verify_once = false
    
    override func call(action: String, data: JSON? = nil, responseHandler: @escaping Callback) {
        print("BackendServicesMock called with action: \(action), data:\(data?.rawString() ?? "null")")
        var response: JSON? = nil
        switch action {
        case "load":
            if BackendServicesMock.auto_verify_once {
                response = BackendServicesMock.MockData["load.verify"]
                BackendServicesMock.auto_verify_once  = false
            } else {
                response = BackendServicesMock.MockData["load.success"]
            }
        case "add":
            if data!["mopid"].stringValue.starts(with: "amop0") {
                response = BackendServicesMock.MockData["add.amop"]
                BackendServicesMock.auto_verify_once  = true
            } else if data!["mopdata","holdername"].stringValue.contains("no3ds") {
                response = BackendServicesMock.MockData["add.success"]
            } else {
                response = BackendServicesMock.MockData["add.3ds"]
                BackendServicesMock.auto_verify_once  = true
            }
        case "verify":
            response = BackendServicesMock.MockData["verify.success"]
        case "obfees":
            let pan : String = data!["mopdata"]["pan"].string ?? ""
            if pan[0,1] == "4" {
                response = BackendServicesMock.MockData["obfees.success"]
            } else {
                response = BackendServicesMock.MockData["obfees.none"]
            }
        case "bin":
            let pan : String = data!["mopdata"]["pan"].string ?? ""
            var vendor:String? = nil
            let selectedVendor = data!["mopdata","vendor"].error == nil ? data!["mopdata","vendor"].stringValue : nil

            if inRange(pan, ["34", "37"]) {
                vendor = "amex"
            } else if inRange(pan,["30", "36", "38", "39"]) {
                vendor = "diners"
            } else if inRange(pan,["60", "64", "65"]) {
                vendor = "discovery"
            } else if inRange(pan,["35"]) {
                vendor = "japancredit"
            } else if inRange(pan,["5", "22", "23", "24", "25", "26", "27", "67"]) {
                vendor = "mastercard"
            } else if inRange(pan,["62"]) {
                vendor = "unionpay"
            } else if inRange(pan,["4"]) {
                vendor = "visa"
            }
            

            if vendor != nil && (selectedVendor == nil || selectedVendor == vendor) {
                response = BackendServicesMock.MockData["bin.success"]
                if selectedVendor == nil {
                    response?["vendor_bin"] = JSON(vendor!)
                }
            } else {
                response = BackendServicesMock.MockData["bin.failure"]
            }
        case "cancel":
            response = BackendServicesMock.MockData["load.success"]
            response?["message"] = [["text":"label_error_abort","type":"error"]]
            break
        default:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + BackendServicesMock.delay) {
            responseHandler(response, BackendServices.mapError(response: response!))
        }
            
    }
}
