//
//  BookingDetailsViewTests.swift
//  AmadeusCheckoutTests
//
//  Created by Yann Armelin on 14/10/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import XCTest
@testable import AmadeusCheckout

class BookingDetailsViewTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEmptyDetails() {
        var details = AMBookingDetails(passengerList: nil, flightList: nil)
        let testView0 = BookingDetailsView(details)
        XCTAssertEqual(testView0.frame.width, 400)
        
        details = AMBookingDetails(passengerList: [], flightList: [])
        let testView1 = BookingDetailsView(details)
        XCTAssertEqual(testView1.frame.width, 400)
    }
    
    func testBookingDetails() {
        let details = AMBookingDetails(
            passengerList: ["Yann Armelin"],
            flightList: [AMFlight(departureAirport: "CDG", departureDate: "16 oct", arrivalAirport: "NCE", arrivalDate: "17 oct")]
        )
        let testView = BookingDetailsView(details)
        XCTAssertEqual(testView.frame.width, 400)
        
        let button1 = UIButton()
        button1.tag = 1
        let button2 = UIButton()
        button2.tag = 2
        
        let originalHeight = testView.frame.height
        
        testView.didClick(button1)
        
        let partiallyClosedHeight = testView.frame.height
        XCTAssertTrue(partiallyClosedHeight < originalHeight)
        
        testView.didClick(button2)
        
        let allClosedHeight = testView.frame.height
        XCTAssertTrue(allClosedHeight < partiallyClosedHeight)
    }

}
