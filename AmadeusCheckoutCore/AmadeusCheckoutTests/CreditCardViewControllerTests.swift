//
//  CreditCardViewControllerTests.swift
//  AmadeusCheckoutTests
//
//  Created by Yann Armelin on 12/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import XCTest
@testable import AmadeusCheckout


class CreditCardViewControllerTests: XCTestCase {
    var window: UIWindow!
    var vc: CreditCardViewController!
    var observer: NSKeyValueObservation?
    var context: AMCheckoutContext!
    
    
    override func setUp() {
        // Context intialization
        context = AMCheckoutContext(ppid: "", environment: .mock)
        
        // Data model intialization
        let additionalFields = [
            DataField(["id":"billAddressLine1","required":"true"]),
            DataField(["id":"billAddressLine2","required":"true"]),
            DataField(["id":"city","required":"true"]),
            DataField(["id":"country","required":"true"]),
            DataField(["id":"zipCode","required":"true"])
        ]
        let cardPaymentMethod : CreditCardPaymentMethod = CreditCardPaymentMethod(
            ["id": "creditcard",
             "name": "credit card",
             "view": "creditcard",
             "config":
                ["billingAddress":"true",
                 "cardVendors":
                    [
                        ["3dsecure":"true","code":"VI","id":"visa","luhn":"true","name":"VISA"],
                        ["3dsecure":"true","code":"AX","id":"amex","luhn":"true","name":"American Express"]
                    ]
                ]
            ]
        , fields: additionalFields)
        context.dataModel!.selectedPaymentMethod = cardPaymentMethod
        context.dataModel!.paymentMethods = [cardPaymentMethod]
        context.dataModel!.additionalFields = additionalFields
        context.options = AMCheckoutOptions()

        // View Controller creation
        let storyboard = UIStoryboard(name: StoryboardConstants.Filename, bundle: FileTools.mainBundle)
        vc = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.CreditCardContentViewController) as? CreditCardViewController
        
        // Add the view controller inside to UIWindow, to ensure view lifecycle methods are called
        window = UIWindow()
        window.addSubview(vc.view )
        
        // Mock response time
        BackendServicesMock.delay = 0.01
    }
    
    override func tearDown() {
        observer = nil
        window = nil
        vc = nil
    }
    
    func testInit() {
        XCTAssertNotNil(vc)
        
        // Check table structure
        XCTAssertEqual(vc.numberOfSections(in: vc.tableView), 2)
        XCTAssertEqual(vc.tableView(vc.tableView, numberOfRowsInSection: 0), 5)
        XCTAssertEqual(vc.tableView(vc.tableView, numberOfRowsInSection: 1), 5)
    }
    
    func testNavigation() {
        // Select the PAN field
        let fieldFieldIndex = IndexPath(row: 0, section: 0)
        vc.tableView.selectRow(at: fieldFieldIndex, animated: false, scrollPosition: .none)
        vc.transferRowSelectionToField(at: fieldFieldIndex, openDetails: false)

        // Check that previous field is nil, and next field is correct
        let (previousRow,nextRow)=vc.previousAndNextSelectableRow()
        XCTAssertNil(previousRow)
        XCTAssertEqual(nextRow, IndexPath(row: 1, section: 0))
    }
    
    func testPayButton() {
        XCTAssertTrue(vc.payButton.isEnabled == true)
        
        let expectation = self.expectation(description: "Form is valid")
        observer = vc.tableModel.bindingAggregator.observe(\.isValid, changeHandler: {aggregator, change in
            if aggregator.isValid {
                expectation.fulfill()
            }
        })
        
        // We fill the form, so that its status becomes valid
        let ccMethod = vc.creditCardMethod!
        
        vc.tableModel.getBindings(forCell: .cardholderName)[0].value = "Yann"
        vc.tableModel.getBindings(forCell: .cardNumber)[0].value = "4444333322221111"
        ccMethod.vendor = ccMethod.allowedVendors[0]
        vc.tableModel.getBindings(forCell: .cardCvv)[0].value = "123"
        vc.tableModel.getBindings(forCell: .cardExpiry)[1].value = "01/40"
        vc.tableModel.getBindings(forCell: .billingAddressLine1)[0].value = "Line 1"
        vc.tableModel.getBindings(forCell: .billingAddressLine2)[0].value = "Line 2"
        vc.tableModel.getBindings(forCell: .billingAddressZipCode)[0].value = "00000"
        vc.tableModel.getBindings(forCell: .billingAddressCity)[0].value = "City"
        vc.tableModel.getBindings(forCell: .billingAddressCountry)[0].value = "FR"
        
        waitForExpectations(timeout: 0.5, handler: nil)
        
        XCTAssertTrue(vc.payButton.isEnabled == true)
        
    }
}
