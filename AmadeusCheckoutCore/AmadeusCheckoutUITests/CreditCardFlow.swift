//
//  CreditCardFlow.swift
//  AmadeusCheckoutTests
//
//  Created by Yann Armelin on 14/10/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import XCTest

class CreditCardFlow: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func getSdkStatus() -> String? {
        let sdkStatusLabel = app.staticTexts["sdk_result"]
        if sdkStatusLabel.waitForExistence(timeout: 1) {
            return sdkStatusLabel.label
        }
        return nil
    }
    
    func startCreditCardPayment() {
        app.buttons["mop_in_sdk"].tap()
        app.tables.cells.staticTexts["Payment card"].tap()
        //app.pickerWheels.element.adjust(toPickerWheelValue: "Payment card")
        //app.buttons["select_mop"].tap()
        
    }
    
    func pressCancel() {
        let cancelButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 1))
        cancelButton.tap()
    }
    
    func pressPay() {
        let payButton = app.buttons["pay_button"]
        XCTAssertTrue(payButton.waitForExistence(timeout: 1))
        payButton.tap()
    }
    
    func setExpiry(_ month: String, _ year: String) {
        let expiryInput = app.tables.cells.containing(.textField, identifier: "expiry_input").textFields.element
        expiryInput.tap()
        
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: month)
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: year)
    }
    
    func setCardNumber(_ value: String) {
        let cardInput = app.tables.cells.containing(.textField, identifier: "card_number_input").textFields.element
        XCTAssertTrue( cardInput.waitForExistence(timeout: 1) )
        cardInput.tap()
        app.typeText(value)
    }
    
    func setGenericTextInput(_ value: String, index: Int) {
        let cardholderNameInput = app.tables.cells.containing(.textField, identifier: "text_input").textFields.element(boundBy: index)
        cardholderNameInput.tap()
        app.typeText(value)
    }
    
    func selectValue(_ value: String) {
        let vendorCell = app.tables.cells.containing(.staticText, identifier: value).element
        XCTAssertTrue(vendorCell.waitForExistence(timeout: 1.0))
        vendorCell.tap()
    }
    
    func pressNextField() {
        app.buttons["keyboard_next"].tap()
    }
    
    func pressPreviousField() {
        app.buttons["keyboard_previous"].tap()
    }

    
    func testCancelButton() {
        startCreditCardPayment()
        
        pressCancel()
        
        XCTAssertEqual(getSdkStatus(), "Cancellation")
    }
    

    func testCreditCardPayment() {
        startCreditCardPayment()

        // Set card number
        setCardNumber("4444333322221111")
        
        // Go up, and set vendor
        pressPreviousField()
        selectValue("VISA")

        // Set card holder name
        setGenericTextInput("John no3ds", index: 0)
        
        // Set expriy
        setExpiry("01 - January", "2050")
        
        // Go down, and set CVV
        pressNextField()
        app.typeText("123")
        
        // Go down on address line1, keep default value
        pressNextField()
        
        // Go down on address line2, leave field empty
        pressNextField()
        
        // GO down on Zip code, keep default value
        pressNextField()
        
        // Go down on City, set value
        pressNextField()
        app.typeText("Antibes")
        
        // Go down on Country, select value
        pressNextField()
        selectValue("France")

        
        pressPay()
        XCTAssertEqual(getSdkStatus(), "Success")
    }

}
