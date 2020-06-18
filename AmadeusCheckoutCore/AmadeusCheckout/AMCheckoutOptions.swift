//
//  AMCheckoutOptions.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 24/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

public class AMAmountDetails: NSObject {
    @objc public var label: String
    @objc public var amount: Double
    
    @objc public init(label: String, amount: Double) {
        self.label = label
        self.amount = amount
    }
}

public class AMFlight: NSObject {
    @objc public var departureAirport: String
    @objc public var arrivalAirport: String
    @objc public var departureDate: String
    @objc public var arrivalDate: String
    
    @objc public init(
        departureAirport: String, departureDate: Date, departureTimezone: TimeZone,
        arrivalAirport:   String, arrivalDate:   Date, arrivalTimezone:   TimeZone)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = departureTimezone
        
        self.departureAirport = departureAirport
        dateFormatter.timeZone = departureTimezone
        self.departureDate = dateFormatter.string(from: departureDate)

        self.arrivalAirport = arrivalAirport
        dateFormatter.timeZone = arrivalTimezone
        self.arrivalDate = dateFormatter.string(from: arrivalDate)
    }
    
    @objc public init(
        departureAirport: String, departureDate: String,
        arrivalAirport:   String, arrivalDate:   String)
    {
        self.departureAirport = departureAirport
        self.departureDate = departureDate
        self.arrivalAirport = arrivalAirport
        self.arrivalDate = arrivalDate
    }
}

public class AMBookingDetails: NSObject {
    @objc public var passengerList: [String]?
    @objc public var flightList: [AMFlight]?
    
    @objc public init(passengerList: [String]?,  flightList: [AMFlight]?) {
        self.passengerList = passengerList
        self.flightList = flightList
    }

}

public class AMTermsAndConditions : NSObject {
    @objc public var localizedLabel: String
    @objc public var link: URL
    
    @objc public init(link: URL, localizedLabel: String){
        self.link = link
        self.localizedLabel = localizedLabel
    }
}

public class AMCheckoutOptions : NSObject {
    // Behavior customizations
    @objc public var displayPayButtonOnTop = false
    @objc public var displayCvvHelp = true
    @objc public var dynamicVendor = false
    @objc public var termsAndConditions: [AMTermsAndConditions] = []
    @objc public var bookingDetails: AMBookingDetails?
    @objc public var amountBreakdown: [AMAmountDetails] = []
    @objc public var paymentControllerPresentationStyle: UIModalPresentationStyle = .pageSheet
    
    
    // This should be overriden by application if a redirection
    // to an external application or browser can occur.
    @objc public var appCallbackScheme = "amadeus-checkout"
    
    // Visual customizations
    @objc public var primaryBackgroundColor: UIColor?
    @objc public var secondaryBackgroundColor: UIColor?
    @objc public var primaryForegroundColor: UIColor?
    @objc public var secondaryForegroundColor: UIColor?
    @objc public var accentColor: UIColor?
    @objc public var errorColor: UIColor?
    @objc public var font: UIFont?
    @objc public var emphasisFont: UIFont?
    

    public override init(){}
}
