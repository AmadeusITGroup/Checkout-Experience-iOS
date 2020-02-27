//
//  BStringSlicingTests.swift
//  StringSlicingTests
//
//  Created by Yann Armelin on 16/04/2019.
//  Copyright © 2019 Yann Armelin. All rights reserved.
//

import XCTest
@testable import AmadeusCheckout

class StringSlicingTests: XCTestCase {
    
    override func setUp() {
    }

    override func tearDown() {
    }

    func testStringSlicing() {
        let str = "ABCDEF"

        XCTAssertEqual(str[0, 3] , "ABC")
        
        XCTAssertEqual(str[nil, 6, nil] , "ABCDEF")
        XCTAssertEqual(str[-10, 20, 1] , "ABCDEF")
        XCTAssertEqual(str[2, nil, nil] , "CDEF")
        XCTAssertEqual(str[0, 4, nil] , "ABCD")
        XCTAssertEqual(str[0, -2, nil] , "ABCD")
        XCTAssertEqual(str[-4, -2, nil] , "CD")
        XCTAssertEqual(str[-2, -2, nil] , "")
        XCTAssertEqual(str[3, 2, nil] , "")
        
        XCTAssertEqual(str[nil, nil, 2] , "ACE")
        XCTAssertEqual(str[1, nil, 2] , "BDF")
        XCTAssertEqual(str[6, nil, 2] , "")
        
        XCTAssertEqual("ABC"[-6, -2, 2] , "A")
        XCTAssertEqual("ABC"[-2, nil, -1] , "BA")
        XCTAssertEqual("ABC"[2, 0, -1] , "CB")
        XCTAssertEqual("ABC"[1, 0, -1] , "B")
        XCTAssertEqual("ABC"[3, -4, -1] , "CBA")
        XCTAssertEqual("ABC"[-6, nil, -1] , "")
        XCTAssertEqual("ABC"[-1, -1, -1] , "")
    }
    
    func testStringRange() {
        
    }
}
