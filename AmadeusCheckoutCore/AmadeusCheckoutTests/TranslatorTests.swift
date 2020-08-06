//
//  TranslatorTests.swift
//  AmadeusCheckoutTests
//
//  Created by Yann Armelin on 03/08/2020.
//  Copyright © 2020 Amadeus. All rights reserved.
//

import XCTest
@testable import AmadeusCheckout

class TranslatorTests: XCTestCase {
    override func setUp() {
    }

    override func tearDown() {
    }

    func testMonthLocalName() {
        var tr = Translator(withLocale: NSLocale(localeIdentifier: "en_EN"))
        XCTAssertEqual(tr.monthLocalName(month: 1), "January")
        XCTAssertEqual(tr.monthLocalName(month: 12), "December")
        
        tr = Translator(withLocale: NSLocale(localeIdentifier: "fr_FR"))
        XCTAssertEqual(tr.monthLocalName(month: 1), "janvier")
        XCTAssertEqual(tr.monthLocalName(month: 12), "décembre")
    }
    
    func testCountryLocalName() {
        var tr = Translator(withLocale: NSLocale(localeIdentifier: "en_EN"))
        XCTAssertEqual(tr.countryLocalName(code: "ES"), "Spain")
        
        tr = Translator(withLocale: NSLocale(localeIdentifier: "fr_FR"))
        XCTAssertEqual(tr.countryLocalName(code: "ES"), "Espagne")
        
    }
    
    func testFormatAmount() {
        var tr = Translator(withLocale: NSLocale(localeIdentifier: "en_EN"))
        
        var codeOnLeft = tr.formatAmount(10.0, currency: "USD", style: .currencyCodeOnLeft)
        XCTAssertEqual(codeOnLeft, "USD 10.00")
        
        var codeOnRight = tr.formatAmount(10.0, currency: "USD", style: .currencyCodeOnRight)
        XCTAssertEqual(codeOnRight, "10.00 USD")

        var localeBased = tr.formatAmount(10.0, currency: "USD", style: .localeBased)
        XCTAssertEqual(localeBased, "$10.00")

        
        tr = Translator(withLocale: NSLocale(localeIdentifier: "fr_FR"))
        
        codeOnLeft = tr.formatAmount(25.0, currency: "JPY", style: .currencyCodeOnLeft)
        XCTAssertEqual(codeOnLeft, "JPY 25")
        
        codeOnRight = tr.formatAmount(25.0, currency: "JPY", style: .currencyCodeOnRight)
        XCTAssertEqual(codeOnRight, "25 JPY")

        localeBased = tr.formatAmount(25.0, currency: "JPY", style: .localeBased)
        XCTAssertEqual(localeBased, "25\u{00a0}JPY")
    }

}
