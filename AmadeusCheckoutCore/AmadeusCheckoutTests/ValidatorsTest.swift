//
//  ValidatorsTest.swift
//  AmadeusCheckoutTests
//
//  Created by Hela OTHMANI on 19/06/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import XCTest
@testable import AmadeusCheckout

class ValidatorsTest: XCTestCase {
    private var cardPaymentMethod : CreditCardPaymentMethod!
    private var context: AMCheckoutContext!
    private var ccnumValidator: Validator!
    
    private var isValid : Bool? = nil
    private var errorMessage: String? = nil
    
    override func setUp() {
        context = AMCheckoutContext(ppid: "", environment: .mock)
        cardPaymentMethod = CreditCardPaymentMethod(JSON(
            ["id": "creditcard",
             "name": "credit card",
             "view": "creditcard",
             "config":
                ["cardVendors":
                    [
                        ["3dsecure":"true","code":"VI","id":"visa","luhn":"true","name":"VISA"],
                        ["3dsecure":"true","code":"AX","id":"amex","luhn":"true","name":"American Express"]
                    ]
                ]
            ]
        ), fields: [])
        ccnumValidator = ValidatorFactory.ccNum.create()
        
        context.dataModel!.selectedPaymentMethod = cardPaymentMethod
        context.dataModel!.paymentMethods = [cardPaymentMethod]
        BackendServicesMock.delay = 0.01
        clean()
    }
    
    override func tearDown() {
        cardPaymentMethod = nil
        context = nil
        ccnumValidator = nil
        isValid = nil
        errorMessage = nil
    }
    
    private func accept(){
        isValid = true
        errorMessage = nil
    }
    private func reject(_ error: String){
        isValid = false
        errorMessage = error
    }
    private func clean(){
        isValid = nil
        errorMessage = nil
    }

    func testRequiredField(){
        let validator = ValidatorFactory.requiredField.create()
        validator.isValid("", successHandler: accept, failureHandler: reject)
        
        XCTAssertEqual(isValid, false)
        XCTAssertEqual(errorMessage, RequiredFieldValidator.errorMessage)
        clean()
        
        validator.isValid("041", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , true)
        XCTAssertEqual(errorMessage, nil)
        clean()
    }
    
    func testCVVValidator(){
        let validator = ValidatorFactory.cvv.create()
        
        validator.isValid("12", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "cvv".localize(type: .errorField).replacingOccurrences(of: "{0}", with: String(3)) )
        clean()
        
        validator.isValid("123", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , true)
        XCTAssertEqual(errorMessage, nil)
        clean()
        
        validator.isValid("1525542", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "cvv".localize(type: .errorField).replacingOccurrences(of: "{0}", with: String(3)) )
        clean()

    }
    
    func testCCNumValidator(){
        
        cardPaymentMethod.creditCardNumber = ""

        //KO mandatory field
        ccnumValidator.isValid("", successHandler: clean, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "mandatory".localize(type: .errorField))
        clean()
        cardPaymentMethod.creditCardNumber = "400"
        
        //KO
        ccnumValidator.isValid("400", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "luhn".localize(type: .errorField))
        clean()
        
        //SET vendor
        cardPaymentMethod.vendor.id = "visa"
        clean()
        
        //KO : Same error as previous
        ccnumValidator.isValid("400", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "luhn".localize(type: .errorField))
        clean()
        
        //SET bin corresponding to the vendor but luhn is incorrect
        cardPaymentMethod.creditCardNumber = "40000000"
        var expectation = self.expectation(description: "ACCEPT BIN, REJECT LUHN")
        
        //KO: luhn, OK: BIN
        ccnumValidator.isValid(cardPaymentMethod.creditCardNumber, successHandler: {
            self.accept()
        }, failureHandler: { errorMessage in
            self.reject(errorMessage)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 0.5, handler: nil)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "luhn".localize(type: .errorField))
        clean()
        
        //Change bin to invalid one
        cardPaymentMethod.creditCardNumber = "55555555"
        expectation = self.expectation(description: "REJECT BIN")
        
        //KO: BIN
        ccnumValidator.isValid(cardPaymentMethod.creditCardNumber, successHandler: {
            self.accept()
        }, failureHandler: { errorMessage in
            self.reject(errorMessage)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 0.5, handler: nil)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "bin".localize(type: .errorField))
        clean()
        
        //OK: WITHOUT REDOING BIN CHECK
        cardPaymentMethod.creditCardNumber = "4000000000000002"
        ccnumValidator.isValid("4000000000000002", successHandler: accept, failureHandler: reject)
        
        XCTAssertEqual(isValid , true)
        XCTAssertEqual(errorMessage, nil)
        clean()
    }
    
    func testLuhn(){
        var expectation : XCTestExpectation!
        
        context.dataModel!.dynamicVendor = true
        if let ccValidator = ccnumValidator as? CCNumValidator {
            ccValidator.dynamic = true
        }
        
        let validCCNums : [String] = [
            //VISA
            "4532577854769334", "4916888868011068", "4929593698789569803",
            //Visa Electron
            "4913328335447606", "4844268612624341", "4175001541480512",
            // AMEX
            "373081874896060", "378826701633929", "348503233761604"
            ]
        
        //OK
        validCCNums.forEach { (ccnum) in
            cardPaymentMethod.creditCardNumber = ccnum

            expectation = self.expectation(description: "ACCEPT \(ccnum)")
            ccnumValidator.isValid(cardPaymentMethod.creditCardNumber, successHandler: {
                self.accept()
                expectation.fulfill()
            }, failureHandler: reject)
            waitForExpectations(timeout: 0.5, handler: nil)
            XCTAssertEqual(isValid , true)
            XCTAssertEqual(errorMessage, nil)
            clean()
        }
        
        //KO
        let invalidCCNums : [String] = [
            //VISA
            "4234jjhj43434", "4532577854749334", "4916888808011068", "4929591698789569803",
            //Visa Electron
            "4913328335440606", "4844268612604341", "4175001541400512",
            // AMEX
            "373081874806060", "378826701630929", "348503233701604"
        ]
    
        invalidCCNums.forEach { (ccnum) in
            cardPaymentMethod.creditCardNumber = ccnum
            
            expectation = self.expectation(description: "REJECT \(ccnum)")
            ccnumValidator.isValid(cardPaymentMethod.creditCardNumber, successHandler: accept, failureHandler: { errorMessage in
                self.reject(errorMessage)
                expectation.fulfill()
            })
            waitForExpectations(timeout: 0.5, handler: nil)
            XCTAssertEqual(isValid , false)
            XCTAssertEqual(errorMessage, "luhn".localize(type: .errorField))
            clean()
        }
    }
    
    func testBin(){
        let bin = "4444333322221111"
        cardPaymentMethod.creditCardNumber = bin
        cardPaymentMethod.vendor.id = ""
        
        var expectation = self.expectation(description: "REJECT 1")
        
        ccnumValidator.isValid(bin, successHandler: {
            self.accept()
        }, failureHandler: { errorMessage in
            self.reject(errorMessage)
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 0.5, handler: nil)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "bin".localize(type: .errorField))
        clean()
        
        expectation = self.expectation(description: "REJECT 2")
        //SET WRONG VENDOR: BIN CALL is done again
        cardPaymentMethod.vendor.id = "amex"
        ccnumValidator.isValid(bin, successHandler: {
            self.accept()
        }, failureHandler: { errorMessage in
            self.reject(errorMessage)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 0.5, handler: nil)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "bin".localize(type: .errorField))
        clean()
        
        //SET Valid vendor
        expectation = self.expectation(description: "ACCEPT")
        cardPaymentMethod.vendor.id = "visa"
        ccnumValidator.isValid(bin, successHandler: {
            self.accept()
            expectation.fulfill()
        }, failureHandler: { errorMessage in
            self.reject(errorMessage)
        })
        waitForExpectations(timeout: 0.5, handler: nil)
        XCTAssertEqual(isValid , true)
        XCTAssertEqual(errorMessage, nil)
        clean()
        
        //SET SAME WRONG VENDOR: Bin shouldnt be triggered
        cardPaymentMethod.vendor.id = "amex"
        ccnumValidator.isValid(bin, successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, "bin".localize(type: .errorField))
        clean()
    }
    
    func testExpiryDateValidator(){
        let validator = ValidatorFactory.expiryDate.create()
        
        validator.isValid("10/39", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , true)
        XCTAssertEqual(errorMessage, nil)
        clean()
        
        validator.isValid("10/10", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, ExpiryDateValidator.errorMessage)
        clean()
        
        validator.isValid("13/40", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, ExpiryDateValidator.errorMessage)
        clean()
        
        validator.isValid("1030", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, ExpiryDateValidator.errorMessage)
        clean()
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100 
        let currentMonth = Calendar.current.component(.month, from: Date())
        validator.isValid("\(currentMonth-1)/\(currentYear)", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, ExpiryDateValidator.errorMessage)
        clean()
    }
    
    
    func testMinLenghtValidator() {
        let validator = ValidatorFactory.minLength(5).create()
        
        validator.isValid("ABCDE", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , true)
        clean()
        
        validator.isValid("ABCD", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, MinLengthValidator.errorMessage.replacingOccurrences(of: "{0}", with: "5"))
        clean()
    }
    
    func testMaxLenghtValidator() {
        let validator = ValidatorFactory.maxLength(5).create()
        
        validator.isValid("ABCDE", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , true)
        clean()
        
        validator.isValid("ABCDEF", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, MaxLengthValidator.errorMessage.replacingOccurrences(of: "{0}", with: "5"))
        clean()
    }
    
    
    func testChainValidator() {
        let validator1 = ValidatorFactory.requiredMinMaxLength(true, 5, 10).create()
        
        validator1.isValid("ABCDE", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , true)
        clean()
        
        validator1.isValid("", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, RequiredFieldValidator.errorMessage)
        clean()
        
        validator1.isValid("ABCDEFGHIJK", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, MaxLengthValidator.errorMessage.replacingOccurrences(of: "{0}", with: "10"))
        clean()
        
        validator1.isValid("ABC", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , false)
        XCTAssertEqual(errorMessage, MinLengthValidator.errorMessage.replacingOccurrences(of: "{0}", with: "5"))
        clean()
        
        let validator2 = ValidatorFactory.requiredMinMaxLength(nil, nil, nil).create()

        validator2.isValid("ABC", successHandler: accept, failureHandler: reject)
        XCTAssertEqual(isValid , true)
        clean()
    }
}
