//
//  BoundTextFieldTests.swift
//  BoundTextFieldTests
//
//  Created by Yann Armelin on 16/04/2019.
//  Copyright © 2019 Yann Armelin. All rights reserved.
//

import XCTest
@testable import AmadeusCheckout

fileprivate class RootModel : NSObject {
    @objc dynamic var value: String = "Foo"
    @objc dynamic var child = ChildModel()
}
fileprivate class ChildModel : NSObject {
    @objc dynamic var nestedValue: String = "Bar"
}

class BoundTextFieldTests: XCTestCase {
    var textField: BoundTextField!
    fileprivate var model: RootModel!
    
    
    override func setUp() {
        textField = BoundTextField(frame:CGRect(x: 0, y: 0, width: 200, height: 100))
        model = RootModel()
    }

    override func tearDown() {
        textField = nil
        model = nil
    }

    func testBinbing() {
        // Set binding with root property
        textField.binding = DataModelBinding(model, keyPath: \.value)
        
        // Initial value
        XCTAssertEqual(textField.text , "Foo")
        
        // Model to view binding
        model.value = "Hello"
        XCTAssertEqual(textField.text , "Hello")
        XCTAssertEqual(textField.text , textField.viewValue)
        
        // View to model binding
        textField.text = "World"
        textField.editingChanged() //textField.sendActions(for: .editingChanged)
        
        XCTAssertEqual(model.value , "World")
        XCTAssertEqual(model.value , textField.binding?.value)
        
    
        // Set binding with nested property
        textField.binding = DataModelBinding(model, keyPath: \.child.nestedValue)
        
        // Initial value
        XCTAssertEqual(textField.text , "Bar")
        
        // Model to view binding
        model.child = ChildModel()
        model.child.nestedValue = "Batman"
        XCTAssertEqual(textField.text , "Batman")
        
        // View to model binding
        textField.text = "Superman"
        textField.editingChanged()
        XCTAssertEqual(model.child.nestedValue , "Superman")
    }
    
    func testFormatter() {
        // Set binding with root property
        textField.binding = DataModelBinding(model, keyPath: \.value)
        textField.binding?.formatter = { "/"+$0+"/" }
        
        XCTAssertEqual(textField.text , "/Foo/")
        
        model.value = "Hello"
        XCTAssertEqual(textField.text , "/Hello/")
    }
    
    func testParser() {
        // Set binding with root property
        textField.binding = DataModelBinding(model, keyPath: \.value)
        textField.binding?.parser = { $0.uppercased() }
        
        textField.text = "Superman"
        textField.editingChanged()
        XCTAssertEqual(model.value , "SUPERMAN")
    }
    class OKValidator: Validator {
        static let errorMessage = "NOTOK"
        func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void {
            if value == "OK" {
                successHandler()
            }else{
                failureHandler(OKValidator.errorMessage)
            }
        }
    }
    func testSynchronousValidator() {
        // Set binding with root property
        textField.binding = DataModelBinding(model, keyPath: \.value)
        textField.binding?.validator = OKValidator()
        
        XCTAssertEqual(textField.binding?.isValid , false)
        XCTAssertEqual(textField.errorText , "NOTOK")
        
        textField.text = "Superman"
        textField.editingChanged()
        XCTAssertEqual(textField.binding?.isValid , false)
        XCTAssertEqual(textField.errorText , "NOTOK")
        
        textField.text = "OK"
        textField.editingChanged()
        XCTAssertEqual(textField.binding?.isValid , true)
        XCTAssertEqual(textField.errorText , nil)
        
    }
    class OKAsyncValidator: Validator {
        static let errorMessage = "NOTOK"
        var expectation: XCTestExpectation? = nil
        
        func isValid(_ value: String, successHandler:@escaping SuccessHandler, failureHandler:@escaping FailureHandler) -> Void {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if value == "OK" {
                    successHandler()
                }else{
                    failureHandler(OKAsyncValidator.errorMessage)
                }
                self.expectation?.fulfill()
            }
        }
    }
    
    func testAsynchronousValidator() {
       
        // Set binding with root property
        textField.binding = DataModelBinding(model, keyPath: \.value)
        let asyncValidator = OKAsyncValidator()
        textField.binding?.validator = asyncValidator
        
        asyncValidator.expectation = self.expectation(description: "Accept")
        XCTAssertEqual(textField.binding?.isValid , false)
        XCTAssertEqual(textField.binding?.isPending , true)
        XCTAssertEqual(textField.errorText , nil)
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(textField.binding?.isValid , false)
        XCTAssertEqual(textField.binding?.isPending , false)
        XCTAssertEqual(textField.errorText , "NOTOK")
        
        
        asyncValidator.expectation = self.expectation(description: "Reject")
        textField.text = "OK"
        textField.editingChanged()
        
        
        XCTAssertEqual(textField.binding?.isValid , false)
        XCTAssertEqual(textField.binding?.isPending , true)
        XCTAssertEqual(textField.errorText , nil)
        waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(textField.binding?.isValid , true)
        XCTAssertEqual(textField.binding?.isPending , false)
        XCTAssertEqual(textField.errorText , nil)
        
    }
    class KOValidator: Validator {
        static let errorMessage: String = "ERROR"
        func isValid(_ value: String, successHandler: @escaping SuccessHandler, failureHandler: @escaping FailureHandler) {
            failureHandler(KOValidator.errorMessage)
        }
    }
    func testHideError() {
        // We set up a field that is always invalid no matter its value
        textField.binding = DataModelBinding(model, keyPath: \.value)
        textField.binding?.validator = KOValidator()
        model.value = ""
        
        // Field is invalid, and error is displayed since value has changed
        XCTAssertEqual(textField.binding?.isValid , false)
        XCTAssertEqual(textField.errorText , "ERROR")
        
        
        textField.text = "OK"
        textField.editingChanged()
        
        // Field is still invalid and error is invalid
        XCTAssertEqual(textField.binding?.isValid , false)
        XCTAssertEqual(textField.errorText , "ERROR")
        
        //textField.binding?.hideErrorIfEmpty()
        
        // Field is still invalid and is not hidde, because field has a value
        XCTAssertEqual(textField.binding?.isValid , false)
        XCTAssertEqual(textField.errorText , "ERROR")
    }
    
    
    
    func testBindingAggregator() {
        let aggregator = DataModelBindingAggregator()
        
        let binding1 = DataModelBinding(model, keyPath: \.child.nestedValue)
        let binding2 = DataModelBinding(model, keyPath: \.value)
        
        binding1.validator = OKValidator()
        binding2.validator = OKValidator()
        
        aggregator.add(binding1)
        aggregator.add(binding2)
        XCTAssertEqual(aggregator.isValid , false)
        
        binding1.value = "OK"
        binding2.value = "OK"
        XCTAssertEqual(aggregator.isValid , true)
        
        
        binding2.value = "NOTKO"
        XCTAssertEqual(aggregator.isValid , false)
        
        aggregator.remove(binding2)
        XCTAssertEqual(aggregator.isValid , true)
    }

}
