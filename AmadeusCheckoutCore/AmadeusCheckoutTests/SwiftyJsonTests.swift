//
//  SwiftyJsonTests.swift
//  AmadeusCheckoutTests
//
//  Created by Yann Armelin on 18/07/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import XCTest
import Foundation
@testable import AmadeusCheckout

//  ArrayTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class ArrayTests: XCTestCase {

    func testSingleDimensionalArraysGetter() {
        let array = ["1", "2", "a", "B", "D"]
        let json = JSON(array)
        XCTAssertEqual((json.array![0] as JSON).string!, "1")
        XCTAssertEqual((json.array![1] as JSON).string!, "2")
        XCTAssertEqual((json.array![2] as JSON).string!, "a")
        XCTAssertEqual((json.array![3] as JSON).string!, "B")
        XCTAssertEqual((json.array![4] as JSON).string!, "D")
    }

    func testSingleDimensionalArraysSetter() {
        let array = ["1", "2", "a", "B", "D"]
        var json = JSON(array)
        json.arrayObject = ["111", "222"]
        XCTAssertEqual((json.array![0] as JSON).string!, "111")
        XCTAssertEqual((json.array![1] as JSON).string!, "222")
    }
}
//  BaseTests.swift
//
//  Copyright (c) 2014 - 2017 Ruoyu Fu, Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class BaseTests: XCTestCase {

    var testData: Data!

    override func setUp() {

        super.setUp()

//        let file = "./Tests/Tes/Tests.json"
//        self.testData = try? Data(contentsOf: URL(fileURLWithPath: file))
        if let file = Bundle(for: BaseTests.self).path(forResource: "Tests", ofType: "json") {
            self.testData = try? Data(contentsOf: URL(fileURLWithPath: file))
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        guard let json0 = try? JSON(data: self.testData) else {
            XCTFail("Unable to parse testData")
            return
        }
        XCTAssertEqual(json0.array!.count, 3)
        XCTAssertEqual(JSON("123").description, "123")
        XCTAssertEqual(JSON(["1": "2"])["1"].string!, "2")
        let dictionary = NSMutableDictionary()
        dictionary.setObject(NSNumber(value: 1.0), forKey: "number" as NSString)
        dictionary.setObject(NSNull(), forKey: "null" as NSString)
        _ = JSON(dictionary)
        do {
            let object: Any = try JSONSerialization.jsonObject(with: self.testData, options: [])
            let json2 = JSON(object)
            XCTAssertEqual(json0, json2)
        } catch _ {
        }
    }

    func testCompare() {
        XCTAssertNotEqual(JSON("32.1234567890"), JSON(32.1234567890))
        let veryLargeNumber: UInt64 = 9876543210987654321
        XCTAssertNotEqual(JSON("9876543210987654321"), JSON(NSNumber(value: veryLargeNumber)))
        XCTAssertNotEqual(JSON("9876543210987654321.12345678901234567890"), JSON(9876543210987654321.12345678901234567890))
        XCTAssertEqual(JSON("😊"), JSON("😊"))
        XCTAssertNotEqual(JSON("😱"), JSON("😁"))
        XCTAssertEqual(JSON([123, 321, 456]), JSON([123, 321, 456]))
        XCTAssertNotEqual(JSON([123, 321, 456]), JSON(123456789))
        XCTAssertNotEqual(JSON([123, 321, 456]), JSON("string"))
        XCTAssertNotEqual(JSON(["1": 123, "2": 321, "3": 456]), JSON("string"))
        XCTAssertEqual(JSON(["1": 123, "2": 321, "3": 456]), JSON(["2": 321, "1": 123, "3": 456]))
        XCTAssertEqual(JSON(NSNull()), JSON(NSNull()))
        XCTAssertNotEqual(JSON(NSNull()), JSON(123))
    }

    func testJSONDoesProduceValidWithCorrectKeyPath() {

        guard let json = try? JSON(data: self.testData) else {
            XCTFail("Unable to parse testData")
            return
        }

        let tweets = json
        let tweets_array = json.array
        let tweets_1 = json[1]
        _ = tweets_1[1]
        let tweets_1_user_name = tweets_1["user"]["name"]
        let tweets_1_user_name_string = tweets_1["user"]["name"].string
        XCTAssertNotEqual(tweets.type, Type.null)
        XCTAssert(tweets_array != nil)
        XCTAssertNotEqual(tweets_1.type, Type.null)
        XCTAssertEqual(tweets_1_user_name, JSON("Raffi Krikorian"))
        XCTAssertEqual(tweets_1_user_name_string!, "Raffi Krikorian")

        let tweets_1_coordinates = tweets_1["coordinates"]
        let tweets_1_coordinates_coordinates = tweets_1_coordinates["coordinates"]
        let tweets_1_coordinates_coordinates_point_0_double = tweets_1_coordinates_coordinates[0].double
        let tweets_1_coordinates_coordinates_point_1_float = tweets_1_coordinates_coordinates[1].float
        let new_tweets_1_coordinates_coordinates = JSON([-122.25831, 37.871609] as NSArray)
        XCTAssertEqual(tweets_1_coordinates_coordinates, new_tweets_1_coordinates_coordinates)
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0_double!, -122.25831)
        XCTAssertTrue(tweets_1_coordinates_coordinates_point_1_float! == 37.871609)
        let tweets_1_coordinates_coordinates_point_0_string = tweets_1_coordinates_coordinates[0].stringValue
        let tweets_1_coordinates_coordinates_point_1_string = tweets_1_coordinates_coordinates[1].stringValue
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0_string, "-122.25831")
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1_string, "37.871609")
        let tweets_1_coordinates_coordinates_point_0 = tweets_1_coordinates_coordinates[0]
        let tweets_1_coordinates_coordinates_point_1 = tweets_1_coordinates_coordinates[1]
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0, JSON(-122.25831))
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1, JSON(37.871609))

        let created_at = json[0]["created_at"].string
        let id_str = json[0]["id_str"].string
        let favorited = json[0]["favorited"].bool
        let id = json[0]["id"].int64
        let in_reply_to_user_id_str = json[0]["in_reply_to_user_id_str"]
        XCTAssertEqual(created_at!, "Tue Aug 28 21:16:23 +0000 2012")
        XCTAssertEqual(id_str!, "240558470661799936")
        XCTAssertFalse(favorited!)
        XCTAssertEqual(id!, 240558470661799936)
        XCTAssertEqual(in_reply_to_user_id_str.type, Type.null)

        let user = json[0]["user"]
        let user_name = user["name"].string
        let user_profile_image_url = user["profile_image_url"].url
        XCTAssert(user_name == "OAuth Dancer")
        XCTAssert(user_profile_image_url == URL(string: "http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg"))

        let user_dictionary = json[0]["user"].dictionary
        let user_dictionary_name = user_dictionary?["name"]?.string
        let user_dictionary_name_profile_image_url = user_dictionary?["profile_image_url"]?.url
        XCTAssert(user_dictionary_name == "OAuth Dancer")
        XCTAssert(user_dictionary_name_profile_image_url == URL(string: "http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg"))
    }

    func testJSONNumberCompare() {
        XCTAssertEqual(JSON(12376352.123321), JSON(12376352.123321))
        XCTAssertGreaterThan(JSON(20.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(30.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(65232), JSON(65232))
        XCTAssertLessThan(JSON(-82320.211), JSON(20.112))
        XCTAssertLessThanOrEqual(JSON(-320.211), JSON(123.1))
        XCTAssertLessThanOrEqual(JSON(-8763), JSON(-8763))

        XCTAssertEqual(JSON(12376352.123321), JSON(12376352.123321))
        XCTAssertGreaterThan(JSON(20.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(30.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(65232), JSON(65232))
        XCTAssertLessThan(JSON(-82320.211), JSON(20.112))
        XCTAssertLessThanOrEqual(JSON(-320.211), JSON(123.1))
        XCTAssertLessThanOrEqual(JSON(-8763), JSON(-8763))
    }

    func testNumberConvertToString() {
        XCTAssertEqual(JSON(true).stringValue, "true")
        XCTAssertEqual(JSON(999.9823).stringValue, "999.9823")
        XCTAssertEqual(JSON(true).number!.stringValue, "1")
        XCTAssertEqual(JSON(false).number!.stringValue, "0")
        XCTAssertEqual(JSON("hello").numberValue.stringValue, "0")
        XCTAssertEqual(JSON(NSNull()).numberValue.stringValue, "0")
        XCTAssertEqual(JSON(["a", "b", "c", "d"]).numberValue.stringValue, "0")
        XCTAssertEqual(JSON(["a": "b", "c": "d"]).numberValue.stringValue, "0")
    }

    func testNumberPrint() {

        XCTAssertEqual(JSON(false).description, "false")
        XCTAssertEqual(JSON(true).description, "true")

        XCTAssertEqual(JSON(1).description, "1")
        XCTAssertEqual(JSON(22).description, "22")
        #if (arch(x86_64) || arch(arm64))
        XCTAssertEqual(JSON(9.22337203685478E18).description, "9.22337203685478e+18")
        #elseif (arch(i386) || arch(arm))
        XCTAssertEqual(JSON(2147483647).description, "2147483647")
        #endif
        XCTAssertEqual(JSON(-1).description, "-1")
        XCTAssertEqual(JSON(-934834834).description, "-934834834")
        XCTAssertEqual(JSON(-2147483648).description, "-2147483648")

        XCTAssertEqual(JSON(1.5555).description, "1.5555")
        XCTAssertEqual(JSON(-9.123456789).description, "-9.123456789")
        XCTAssertEqual(JSON(-0.00000000000000001).description, "-1e-17")
        XCTAssertEqual(JSON(-999999999999999999999999.000000000000000000000001).description, "-1e+24")
        XCTAssertEqual(JSON(-9999999991999999999999999.88888883433343439438493483483943948341).stringValue, "-9.999999991999999e+24")

        XCTAssertEqual(JSON(Int(Int.max)).description, "\(Int.max)")
        XCTAssertEqual(JSON(NSNumber(value: Int.min)).description, "\(Int.min)")
        XCTAssertEqual(JSON(NSNumber(value: UInt.max)).description, "\(UInt.max)")
        XCTAssertEqual(JSON(NSNumber(value: UInt64.max)).description, "\(UInt64.max)")
        XCTAssertEqual(JSON(NSNumber(value: Int64.max)).description, "\(Int64.max)")
        XCTAssertEqual(JSON(NSNumber(value: UInt64.max)).description, "\(UInt64.max)")

        XCTAssertEqual(JSON(Double.infinity).description, "inf")
        XCTAssertEqual(JSON(-Double.infinity).description, "-inf")
        XCTAssertEqual(JSON(Double.nan).description, "nan")

        XCTAssertEqual(JSON(1.0/0.0).description, "inf")
        XCTAssertEqual(JSON(-1.0/0.0).description, "-inf")
        XCTAssertEqual(JSON(0.0/0.0).description, "nan")
    }

    func testNullJSON() {
        XCTAssertEqual(JSON(NSNull()).debugDescription, "null")

        let json: JSON = JSON.null
        XCTAssertEqual(json.debugDescription, "null")
        XCTAssertNil(json.error)
        let json1: JSON = JSON(NSNull())
        if json1 != JSON.null {
            XCTFail("json1 should be nil")
        }
    }

    func testExistance() {
        let dictionary = ["number": 1111]
        let json = JSON(dictionary)
        XCTAssertFalse(json["unspecifiedValue"].exists())
        XCTAssertFalse(json[0].exists())
        XCTAssertTrue(json["number"].exists())

        let array = [["number": 1111]]
        let jsonForArray = JSON(array)
        XCTAssertTrue(jsonForArray[0].exists())
        XCTAssertFalse(jsonForArray[1].exists())
        XCTAssertFalse(jsonForArray["someValue"].exists())
    }

    func testErrorHandle() {
        guard let json = try? JSON(data: self.testData) else {
            XCTFail("Unable to parse testData")
            return
        }
        if json["wrong-type"].string != nil {
            XCTFail("Should not run into here")
        } else {
            XCTAssertEqual(json["wrong-type"].error, SwiftyJSONError.wrongType)
        }

        if json[0]["not-exist"].string != nil {
            XCTFail("Should not run into here")
        } else {
            XCTAssertEqual(json[0]["not-exist"].error, SwiftyJSONError.notExist)
        }

        let wrongJSON = JSON(NSObject())
        if let error = wrongJSON.error {
            XCTAssertEqual(error, SwiftyJSONError.unsupportedType)
        }
    }

    func testReturnObject() {
        guard let json = try? JSON(data: self.testData) else {
            XCTFail("Unable to parse testData")
            return
        }
        XCTAssertNotNil(json.object)
    }

    func testErrorThrowing() {
        let invalidJson = "{\"foo\": 300]"  // deliberately incorrect JSON
        let invalidData = invalidJson.data(using: .utf8)!
        do {
            _ = try JSON(data: invalidData)
            XCTFail("Should have thrown error; we should not have gotten here")
        } catch {
            // everything is OK
        }
    }
}
//  CodableTests.swift
//
//  Created by Lei Wang on 2018/1/9.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class CodableTests: XCTestCase {

    func testEncodeNull() {
        var json = JSON([NSNull()])
        _ = try! JSONEncoder().encode(json)
        json = JSON([nil])
        _ = try! JSONEncoder().encode(json)
        let dictionary: [String: Any?] = ["key": nil]
        json = JSON(dictionary)
        _ = try! JSONEncoder().encode(json)
    }

    func testArrayCodable() {
        let jsonString = """
        [1,"false", ["A", 4.3231],"3",true]
        """
        var data = jsonString.data(using: .utf8)!
        let json = try! JSONDecoder().decode(JSON.self, from: data)
        XCTAssertEqual(json.arrayValue.first?.int, 1)
        XCTAssertEqual(json[1].bool, nil)
        XCTAssertEqual(json[1].string, "false")
        XCTAssertEqual(json[3].string, "3")
        XCTAssertEqual(json[2][1].double!, 4.3231)
        XCTAssertEqual(json.arrayValue[0].bool, nil)
        XCTAssertEqual(json.array!.last!.bool, true)
        let jsonList = try! JSONDecoder().decode([JSON].self, from: data)
        XCTAssertEqual(jsonList.first?.int, 1)
        XCTAssertEqual(jsonList.last!.bool, true)
        data = try! JSONEncoder().encode(json)
        let list = try! JSONSerialization.jsonObject(with: data, options: []) as! [Any]
        XCTAssertEqual(list[0] as! Int, 1)
        XCTAssertEqual((list[2] as! [Any])[1] as! NSNumber, 4.3231)
    }

    func testDictionaryCodable() {
        let dictionary: [String: Any] = ["number": 9823.212, "name": "NAME", "list": [1234, 4.21223256], "object": ["sub_number": 877.2323, "sub_name": "sub_name"], "bool": true]
        var data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        let json = try! JSONDecoder().decode(JSON.self, from: data)
        XCTAssertNotNil(json.dictionary)
        XCTAssertEqual(json["number"].float, 9823.212)
        XCTAssertEqual(json["list"].arrayObject is [NSNumber], true)
        XCTAssertEqual(json["object"]["sub_number"].float, 877.2323)
        XCTAssertEqual(json["bool"].bool, true)
        let jsonDict = try! JSONDecoder().decode([String: JSON].self, from: data)
        XCTAssertEqual(jsonDict["number"]?.int, 9823)
        XCTAssertEqual(jsonDict["object"]?["sub_name"], "sub_name")
        data = try! JSONEncoder().encode(json)
        var encoderDict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(encoderDict["list"] as! [NSNumber], [1234, 4.21223256])
        XCTAssertEqual(encoderDict["bool"] as! Bool, true)
        data = try! JSONEncoder().encode(jsonDict)
        encoderDict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(encoderDict["name"] as! String, dictionary["name"] as! String)
        XCTAssertEqual((encoderDict["object"] as! [String: Any])["sub_number"] as! NSNumber, 877.2323)
    }

    func testCodableModel() {
        let dictionary: [String: Any] = [
            "number": 9823.212,
            "name": "NAME",
            "list": [1234, 4.21223256],
            "object": ["sub_number": 877.2323, "sub_name": "sub_name"],
            "bool": true]
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        let model = try! JSONDecoder().decode(CodableModel.self, from: data)
        XCTAssertEqual(model.subName, "sub_name")
    }
}

private struct CodableModel: Codable {
    let name: String
    let number: Double
    let bool: Bool
    let list: [Double]
    private let object: JSON
    var subName: String? {
        return object["sub_name"].string
    }
}
//  ComparableTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class ComparableTests: XCTestCase {

    func testNumberEqual() {
        let jsonL1: JSON = 1234567890.876623
        let jsonR1: JSON = JSON(1234567890.876623)
        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 == 1234567890.876623)

        let jsonL2: JSON = 987654321
        let jsonR2: JSON = JSON(987654321)
        XCTAssertEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonR2 == 987654321)

        let jsonL3: JSON = JSON(NSNumber(value: 87654321.12345678))
        let jsonR3: JSON = JSON(NSNumber(value: 87654321.12345678))
        XCTAssertEqual(jsonL3, jsonR3)
        XCTAssertTrue(jsonR3 == 87654321.12345678)
    }

    func testNumberNotEqual() {
        let jsonL1: JSON = 1234567890.876623
        let jsonR1: JSON = JSON(123.123)
        XCTAssertNotEqual(jsonL1, jsonR1)
        XCTAssertFalse(jsonL1 == 34343)

        let jsonL2: JSON = 8773
        let jsonR2: JSON = JSON(123.23)
        XCTAssertNotEqual(jsonL2, jsonR2)
        XCTAssertFalse(jsonR1 == 454352)

        let jsonL3: JSON = JSON(NSNumber(value: 87621.12345678))
        let jsonR3: JSON = JSON(NSNumber(value: 87654321.45678))
        XCTAssertNotEqual(jsonL3, jsonR3)
        XCTAssertFalse(jsonL3 == 4545.232)
    }

    func testNumberGreaterThanOrEqual() {
        let jsonL1: JSON = 1234567890.876623
        let jsonR1: JSON = JSON(123.123)
        XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 >= -37434)

        let jsonL2: JSON = 8773
        let jsonR2: JSON = JSON(-87343)
        XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonR2 >= -988343)

        let jsonL3: JSON = JSON(NSNumber(value: 87621.12345678))
        let jsonR3: JSON = JSON(NSNumber(value: 87621.12345678))
        XCTAssertGreaterThanOrEqual(jsonL3, jsonR3)
        XCTAssertTrue(jsonR3 >= 0.3232)
    }

    func testNumberLessThanOrEqual() {
        let jsonL1: JSON = 1234567890.876623
        let jsonR1: JSON = JSON(123.123)
        XCTAssertLessThanOrEqual(jsonR1, jsonL1)
        XCTAssertFalse(83487343.3493 <= jsonR1)

        let jsonL2: JSON = 8773
        let jsonR2: JSON = JSON(-123.23)
        XCTAssertLessThanOrEqual(jsonR2, jsonL2)
        XCTAssertFalse(9348343 <= jsonR2)

        let jsonL3: JSON = JSON(NSNumber(value: 87621.12345678))
        let jsonR3: JSON = JSON(NSNumber(value: 87621.12345678))
        XCTAssertLessThanOrEqual(jsonR3, jsonL3)
        XCTAssertTrue(87621.12345678 <= jsonR3)
    }

    func testNumberGreaterThan() {
        let jsonL1: JSON = 1234567890.876623
        let jsonR1: JSON = JSON(123.123)
        XCTAssertGreaterThan(jsonL1, jsonR1)
        XCTAssertFalse(jsonR1 > 192388843.0988)

        let jsonL2: JSON = 8773
        let jsonR2: JSON = JSON(123.23)
        XCTAssertGreaterThan(jsonL2, jsonR2)
        XCTAssertFalse(jsonR2 > 877434)

        let jsonL3: JSON = JSON(NSNumber(value: 87621.12345678))
        let jsonR3: JSON = JSON(NSNumber(value: 87621.1234567))
        XCTAssertGreaterThan(jsonL3, jsonR3)
        XCTAssertFalse(-7799 > jsonR3)
    }

    func testNumberLessThan() {
        let jsonL1: JSON = 1234567890.876623
        let jsonR1: JSON = JSON(123.123)
        XCTAssertLessThan(jsonR1, jsonL1)
        XCTAssertTrue(jsonR1 < 192388843.0988)

        let jsonL2: JSON = 8773
        let jsonR2: JSON = JSON(123.23)
        XCTAssertLessThan(jsonR2, jsonL2)
        XCTAssertTrue(jsonR2 < 877434)

        let jsonL3: JSON = JSON(NSNumber(value: 87621.12345678))
        let jsonR3: JSON = JSON(NSNumber(value: 87621.1234567))
        XCTAssertLessThan(jsonR3, jsonL3)
        XCTAssertTrue(-7799 < jsonR3)
    }

    func testBoolEqual() {
        let jsonL1: JSON = true
        let jsonR1: JSON = JSON(true)
        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 == true)

        let jsonL2: JSON = false
        let jsonR2: JSON = JSON(false)
        XCTAssertEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonL2 == false)
    }

    func testBoolNotEqual() {
        let jsonL1: JSON = true
        let jsonR1: JSON = JSON(false)
        XCTAssertNotEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 != false)

        let jsonL2: JSON = false
        let jsonR2: JSON = JSON(true)
        XCTAssertNotEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonL2 != true)
    }

    func testBoolGreaterThanOrEqual() {
        let jsonL1: JSON = true
        let jsonR1: JSON = JSON(true)
        XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 >= true)

        let jsonL2: JSON = false
        let jsonR2: JSON = JSON(false)
        XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
        XCTAssertFalse(jsonL2 >= true)
    }

    func testBoolLessThanOrEqual() {
        let jsonL1: JSON = true
        let jsonR1: JSON = JSON(true)
        XCTAssertLessThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(true <= jsonR1)

        let jsonL2: JSON = false
        let jsonR2: JSON = JSON(false)
        XCTAssertLessThanOrEqual(jsonL2, jsonR2)
        XCTAssertFalse(jsonL2 <= true)
    }

    func testBoolGreaterThan() {
        let jsonL1: JSON = true
        let jsonR1: JSON = JSON(true)
        XCTAssertFalse(jsonL1 > jsonR1)
        XCTAssertFalse(jsonL1 > true)
        XCTAssertFalse(jsonR1 > false)

        let jsonL2: JSON = false
        let jsonR2: JSON = JSON(false)
        XCTAssertFalse(jsonL2 > jsonR2)
        XCTAssertFalse(jsonL2 > false)
        XCTAssertFalse(jsonR2 > true)

        let jsonL3: JSON = true
        let jsonR3: JSON = JSON(false)
        XCTAssertFalse(jsonL3 > jsonR3)
        XCTAssertFalse(jsonL3 > false)
        XCTAssertFalse(jsonR3 > true)

        let jsonL4: JSON = false
        let jsonR4: JSON = JSON(true)
        XCTAssertFalse(jsonL4 > jsonR4)
        XCTAssertFalse(jsonL4 > false)
        XCTAssertFalse(jsonR4 > true)
    }

    func testBoolLessThan() {
        let jsonL1: JSON = true
        let jsonR1: JSON = JSON(true)
        XCTAssertFalse(jsonL1 < jsonR1)
        XCTAssertFalse(jsonL1 < true)
        XCTAssertFalse(jsonR1 < false)

        let jsonL2: JSON = false
        let jsonR2: JSON = JSON(false)
        XCTAssertFalse(jsonL2 < jsonR2)
        XCTAssertFalse(jsonL2 < false)
        XCTAssertFalse(jsonR2 < true)

        let jsonL3: JSON = true
        let jsonR3: JSON = JSON(false)
        XCTAssertFalse(jsonL3 < jsonR3)
        XCTAssertFalse(jsonL3 < false)
        XCTAssertFalse(jsonR3 < true)

        let jsonL4: JSON = false
        let jsonR4: JSON = JSON(true)
        XCTAssertFalse(jsonL4 < jsonR4)
        XCTAssertFalse(jsonL4 < false)
        XCTAssertFalse(true < jsonR4)
    }

    func testStringEqual() {
        let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
        let jsonR1: JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 == "abcdefg 123456789 !@#$%^&*()")
    }

    func testStringNotEqual() {
        let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
        let jsonR1: JSON = JSON("-=[]\\\"987654321")

        XCTAssertNotEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 != "not equal")
    }

    func testStringGreaterThanOrEqual() {
        let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
        let jsonR1: JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 >= "abcdefg 123456789 !@#$%^&*()")

        let jsonL2: JSON = "z-+{}:"
        let jsonR2: JSON = JSON("a<>?:")
        XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonL2 >= "mnbvcxz")
    }

    func testStringLessThanOrEqual() {
        let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
        let jsonR1: JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertLessThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 <= "abcdefg 123456789 !@#$%^&*()")

        let jsonL2: JSON = "z-+{}:"
        let jsonR2: JSON = JSON("a<>?:")
        XCTAssertLessThanOrEqual(jsonR2, jsonL2)
        XCTAssertTrue("mnbvcxz" <= jsonL2)
    }

    func testStringGreaterThan() {
        let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
        let jsonR1: JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertFalse(jsonL1 > jsonR1)
        XCTAssertFalse(jsonL1 > "abcdefg 123456789 !@#$%^&*()")

        let jsonL2: JSON = "z-+{}:"
        let jsonR2: JSON = JSON("a<>?:")
        XCTAssertGreaterThan(jsonL2, jsonR2)
        XCTAssertFalse("87663434" > jsonL2)
    }

    func testStringLessThan() {
        let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
        let jsonR1: JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertFalse(jsonL1 < jsonR1)
        XCTAssertFalse(jsonL1 < "abcdefg 123456789 !@#$%^&*()")

        let jsonL2: JSON = "98774"
        let jsonR2: JSON = JSON("123456")
        XCTAssertLessThan(jsonR2, jsonL2)
        XCTAssertFalse(jsonL2 < "09")
    }

    func testNil() {
        let jsonL1: JSON = JSON.null
        let jsonR1: JSON = JSON(NSNull())
        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 != "123")
        XCTAssertFalse(jsonL1 > "abcd")
        XCTAssertFalse(jsonR1 < "*&^")
        XCTAssertFalse(jsonL1 >= "jhfid")
        XCTAssertFalse(jsonR1 <= "你好")
        XCTAssertTrue(jsonL1 >= jsonR1)
        XCTAssertTrue(jsonL1 <= jsonR1)
    }

    func testArray() {
        let jsonL1: JSON = [1, 2, "4", 5, "6"]
        let jsonR1: JSON = JSON([1, 2, "4", 5, "6"])
        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 == [1, 2, "4", 5, "6"])
        XCTAssertTrue(jsonL1 != ["abcd", "efg"])
        XCTAssertTrue(jsonL1 >= jsonR1)
        XCTAssertTrue(jsonL1 <= jsonR1)
        XCTAssertFalse(jsonL1 > ["abcd", ""])
        XCTAssertFalse(jsonR1 < [])
        XCTAssertFalse(jsonL1 >= [:])
    }

    func testDictionary() {
        let jsonL1: JSON = ["2": 2, "name": "Jack", "List": ["a", 1.09, NSNull()]]
        let jsonR1: JSON = JSON(["2": 2, "name": "Jack", "List": ["a", 1.09, NSNull()]])

        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 != ["1": 2, "Hello": "World", "Koo": "Foo"])
        XCTAssertTrue(jsonL1 >= jsonR1)
        XCTAssertTrue(jsonL1 <= jsonR1)
        XCTAssertFalse(jsonL1 >= [:])
        XCTAssertFalse(jsonR1 <= ["999": "aaaa"])
        XCTAssertFalse(jsonL1 > [")(*&^": 1234567])
        XCTAssertFalse(jsonR1 < ["MNHH": "JUYTR"])
    }
}
//  DictionaryTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class DictionaryTests: XCTestCase {

    func testGetter() {
        let dictionary = ["number": 9823.212, "name": "NAME", "list": [1234, 4.212], "object": ["sub_number": 877.2323, "sub_name": "sub_name"], "bool": true] as [String: Any]
        let json = JSON(dictionary)
        //dictionary
        XCTAssertEqual((json.dictionary!["number"]! as JSON).double!, 9823.212)
        XCTAssertEqual((json.dictionary!["name"]! as JSON).string!, "NAME")
        XCTAssertEqual(((json.dictionary!["list"]! as JSON).array![0] as JSON).int!, 1234)
        XCTAssertEqual(((json.dictionary!["list"]! as JSON).array![1] as JSON).double!, 4.212)
        XCTAssertEqual((((json.dictionary!["object"]! as JSON).dictionaryValue)["sub_number"]! as JSON).double!, 877.2323)
        XCTAssertTrue(json.dictionary!["null"] == nil)
        //dictionaryValue
        XCTAssertEqual(((((json.dictionaryValue)["object"]! as JSON).dictionaryValue)["sub_name"]! as JSON).string!, "sub_name")
        XCTAssertEqual((json.dictionaryValue["bool"]! as JSON).bool!, true)
        XCTAssertTrue(json.dictionaryValue["null"] == nil)
        XCTAssertTrue(JSON.null.dictionaryValue == [:])
        //dictionaryObject
        XCTAssertEqual(json.dictionaryObject!["number"]! as? Double, 9823.212)
        XCTAssertTrue(json.dictionaryObject!["null"] == nil)
        XCTAssertTrue(JSON.null.dictionaryObject == nil)
    }

    func testSetter() {
        var json: JSON = ["test": "case"]
        XCTAssertEqual(json.dictionaryObject! as! [String: String], ["test": "case"])
        json.dictionaryObject = ["name": "NAME"]
        XCTAssertEqual(json.dictionaryObject! as! [String: String], ["name": "NAME"])
    }
}
//  LiteralConvertibleTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class LiteralConvertibleTests: XCTestCase {

    func testNumber() {
        let json: JSON = 1234567890.876623
        XCTAssertEqual(json.int!, 1234567890)
        XCTAssertEqual(json.intValue, 1234567890)
        XCTAssertEqual(json.double!, 1234567890.876623)
        XCTAssertEqual(json.doubleValue, 1234567890.876623)
        XCTAssertTrue(json.float! == 1234567890.876623)
        XCTAssertTrue(json.floatValue == 1234567890.876623)
    }

    func testBool() {
        let jsonTrue: JSON = true
        XCTAssertEqual(jsonTrue.bool!, true)
        XCTAssertEqual(jsonTrue.boolValue, true)
        let jsonFalse: JSON = false
        XCTAssertEqual(jsonFalse.bool!, false)
        XCTAssertEqual(jsonFalse.boolValue, false)
    }

    func testString() {
        let json: JSON = "abcd efg, HIJK;LMn"
        XCTAssertEqual(json.string!, "abcd efg, HIJK;LMn")
        XCTAssertEqual(json.stringValue, "abcd efg, HIJK;LMn")
    }

    func testNil() {
        let jsonNil_1: JSON = JSON.null
        XCTAssert(jsonNil_1 == JSON.null)
        let jsonNil_2: JSON = JSON(NSNull.self)
        XCTAssert(jsonNil_2 != JSON.null)
        let jsonNil_3: JSON = JSON([1: 2])
        XCTAssert(jsonNil_3 != JSON.null)
    }

    func testArray() {
        let json: JSON = [1, 2, "4", 5, "6"]
        XCTAssertEqual(json.array!, [1, 2, "4", 5, "6"])
        XCTAssertEqual(json.arrayValue, [1, 2, "4", 5, "6"])
    }

    func testDictionary() {
        let json: JSON = ["1": 2, "2": 2, "three": 3, "list": ["aa", "bb", "dd"]]
        XCTAssertEqual(json.dictionary!, ["1": 2, "2": 2, "three": 3, "list": ["aa", "bb", "dd"]])
        XCTAssertEqual(json.dictionaryValue, ["1": 2, "2": 2, "three": 3, "list": ["aa", "bb", "dd"]])
    }
}
//  MergeTests.swift
//
//  Created by Daniel Kiedrowski on 17.11.16.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class MergeTests: XCTestCase {

    func testDifferingTypes() {
        let A = JSON("a")
        let B = JSON(1)

        do {
            _ = try A.merged(with: B)
        } catch let error as SwiftyJSONError {
            XCTAssertEqual(error.errorCode, SwiftyJSONError.wrongType.rawValue)
            XCTAssertEqual(type(of: error).errorDomain, SwiftyJSONError.errorDomain)
            XCTAssertEqual(error.errorUserInfo as! [String: String], [NSLocalizedDescriptionKey: "Couldn't merge, because the JSONs differ in type on top level."])
        } catch _ {}
    }

    func testPrimitiveType() {
        let A = JSON("a")
        let B = JSON("b")
        XCTAssertEqual(try! A.merged(with: B), B)
    }

    func testMergeEqual() {
        let json = JSON(["a": "A"])
        XCTAssertEqual(try! json.merged(with: json), json)
    }

    func testMergeUnequalValues() {
        let A = JSON(["a": "A"])
        let B = JSON(["a": "B"])
        XCTAssertEqual(try! A.merged(with: B), B)
    }

    func testMergeUnequalKeysAndValues() {
        let A = JSON(["a": "A"])
        let B = JSON(["b": "B"])
        XCTAssertEqual(try! A.merged(with: B), JSON(["a": "A", "b": "B"]))
    }

    func testMergeFilledAndEmpty() {
        let A = JSON(["a": "A"])
        let B = JSON([:])
        XCTAssertEqual(try! A.merged(with: B), A)
    }

    func testMergeEmptyAndFilled() {
        let A = JSON([:])
        let B = JSON(["a": "A"])
        XCTAssertEqual(try! A.merged(with: B), B)
    }

    func testMergeArray() {
        let A = JSON(["a"])
        let B = JSON(["b"])
        XCTAssertEqual(try! A.merged(with: B), JSON(["a", "b"]))
    }

    func testMergeNestedJSONs() {
        let A = JSON([
            "nested": [
                "A": "a"
            ]
        ])

        let B = JSON([
            "nested": [
                "A": "b"
            ]
        ])

        XCTAssertEqual(try! A.merged(with: B), B)
    }
}
//  MutabilityTests.swift
//
//  Copyright (c) 2014 - 2017 Zigii Wong
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class MutabilityTests: XCTestCase {

    func testDictionaryMutability() {
        let dictionary: [String: Any] = [
            "string": "STRING",
            "number": 9823.212,
            "bool": true,
            "empty": ["nothing"],
            "foo": ["bar": ["1"]],
            "bar": ["foo": ["1": "a"]]
        ]

        var json = JSON(dictionary)
        XCTAssertEqual(json["string"], "STRING")
        XCTAssertEqual(json["number"], 9823.212)
        XCTAssertEqual(json["bool"], true)
        XCTAssertEqual(json["empty"], ["nothing"])

        json["string"] = "muted"
        XCTAssertEqual(json["string"], "muted")

        json["number"] = 9999.0
        XCTAssertEqual(json["number"], 9999.0)

        json["bool"] = false
        XCTAssertEqual(json["bool"], false)

        json["empty"] = []
        XCTAssertEqual(json["empty"], [])

        json["new"] = JSON(["foo": "bar"])
        XCTAssertEqual(json["new"], ["foo": "bar"])

        json["foo"]["bar"] = JSON([])
        XCTAssertEqual(json["foo"]["bar"], [])

        json["bar"]["foo"] = JSON(["2": "b"])
        XCTAssertEqual(json["bar"]["foo"], ["2": "b"])
    }

    func testArrayMutability() {
        let array: [Any] = ["1", "2", 3, true, []]

        var json = JSON(array)
        XCTAssertEqual(json[0], "1")
        XCTAssertEqual(json[1], "2")
        XCTAssertEqual(json[2], 3)
        XCTAssertEqual(json[3], true)
        XCTAssertEqual(json[4], [])

        json[0] = false
        XCTAssertEqual(json[0], false)

        json[1] = 2
        XCTAssertEqual(json[1], 2)

        json[2] = "3"
        XCTAssertEqual(json[2], "3")

        json[3] = [:]
        XCTAssertEqual(json[3], [:])

        json[4] = [1, 2]
        XCTAssertEqual(json[4], [1, 2])
    }

    func testValueMutability() {
        var intArray = JSON([0, 1, 2])
        intArray[0] = JSON(55)
        XCTAssertEqual(intArray[0], 55)
        XCTAssertEqual(intArray[0].intValue, 55)

        var dictionary = JSON(["foo": "bar"])
        dictionary["foo"] = JSON("foo")
        XCTAssertEqual(dictionary["foo"], "foo")
        XCTAssertEqual(dictionary["foo"].stringValue, "foo")

        var number = JSON(1)
        number = JSON("111")
        XCTAssertEqual(number, "111")
        XCTAssertEqual(number.intValue, 111)
        XCTAssertEqual(number.stringValue, "111")

        var boolean = JSON(true)
        boolean = JSON(false)
        XCTAssertEqual(boolean, false)
        XCTAssertEqual(boolean.boolValue, false)
    }

    func testArrayRemovability() {
        let array = ["Test", "Test2", "Test3"]
        var json = JSON(array)

        json.arrayObject?.removeFirst()
        XCTAssertEqual(false, json.arrayValue.isEmpty)
        XCTAssertEqual(json.arrayValue, ["Test2", "Test3"])

        json.arrayObject?.removeLast()
        XCTAssertEqual(false, json.arrayValue.isEmpty)
        XCTAssertEqual(json.arrayValue, ["Test2"])

        json.arrayObject?.removeAll()
        XCTAssertEqual(true, json.arrayValue.isEmpty)
        XCTAssertEqual(JSON([]), json)
    }

    func testDictionaryRemovability() {
        let dictionary: [String: Any] = ["key1": "Value1", "key2": 2, "key3": true]
        var json = JSON(dictionary)

        json.dictionaryObject?.removeValue(forKey: "key1")
        XCTAssertEqual(false, json.dictionaryValue.isEmpty)
        XCTAssertEqual(json.dictionaryValue, ["key2": 2, "key3": true])

        json.dictionaryObject?.removeValue(forKey: "key3")
        XCTAssertEqual(false, json.dictionaryValue.isEmpty)
        XCTAssertEqual(json.dictionaryValue, ["key2": 2])

        json.dictionaryObject?.removeAll()
        XCTAssertEqual(true, json.dictionaryValue.isEmpty)
        XCTAssertEqual(json.dictionaryValue, [:])
    }
}
//  NestedJSONTests.swift
//
//  Created by Hector Matos on 9/27/16.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class NestedJSONTests: XCTestCase {
    let family: JSON = [
        "names": [
            "Brooke Abigail Matos",
            "Rowan Danger Matos"
        ],
        "motto": "Hey, I don't know about you, but I'm feeling twenty-two! So, release the KrakenDev!"
    ]

    func testTopLevelNestedJSON() {
        let nestedJSON: JSON = [
            "family": family
        ]
        XCTAssertNotNil(try? nestedJSON.rawData())
    }

    func testDeeplyNestedJSON() {
        let nestedFamily: JSON = [
            "count": 1,
            "families": [
                [
                    "isACoolFamily": true,
                    "family": [
                        "hello": family
                    ]
                ]
            ]
        ]
        XCTAssertNotNil(try? nestedFamily.rawData())
    }

    func testArrayJSON() {
        let arr: [JSON] = ["a", 1, ["b", 2]]
        let json = JSON(arr)
        XCTAssertEqual(json[0].string, "a")
        XCTAssertEqual(json[2, 1].int, 2)
    }

    func testDictionaryJSON() {
        let json: JSON = ["a": JSON("1"), "b": JSON([1, 2, "3"]), "c": JSON(["aa": "11", "bb": 22])]
        XCTAssertEqual(json["a"].string, "1")
        XCTAssertEqual(json["b"].array!, [1, 2, "3"])
        XCTAssertEqual(json["c"]["aa"].string, "11")
    }

    func testNestedJSON() {
        let inner = JSON([
            "some_field": "1" + "2"
            ])
        let json = JSON([
            "outer_field": "1" + "2",
            "inner_json": inner
            ])
        XCTAssertEqual(json["inner_json"], ["some_field": "12"])

        let foo = "foo"
        let json2 = JSON([
            "outer_field": foo,
            "inner_json": inner
            ])
        XCTAssertEqual(json2["inner_json"].rawValue as! [String: String], ["some_field": "12"])
    }
}
//  NumberTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class NumberTests: XCTestCase {

    func testNumber() {
        //getter
        var json = JSON(NSNumber(value: 9876543210.123456789))
        XCTAssertEqual(json.number!, 9876543210.123456789)
        XCTAssertEqual(json.numberValue, 9876543210.123456789)
        XCTAssertEqual(json.stringValue, "9876543210.123457")

        json.string = "1000000000000000000000000000.1"
        XCTAssertNil(json.number)
        XCTAssertEqual(json.numberValue.description, "1000000000000000000000000000.1")

        json.string = "1e+27"
        XCTAssertEqual(json.numberValue.description, "1000000000000000000000000000")

        //setter
        json.number = NSNumber(value: 123456789.0987654321)
        XCTAssertEqual(json.number!, 123456789.0987654321)
        XCTAssertEqual(json.numberValue, 123456789.0987654321)

        json.number = nil
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as? NSNull, NSNull())
        XCTAssertTrue(json.number == nil)

        json.numberValue = 2.9876
        XCTAssertEqual(json.number!, 2.9876)
    }

    func testBool() {
        var json = JSON(true)
        XCTAssertEqual(json.bool!, true)
        XCTAssertEqual(json.boolValue, true)
        XCTAssertEqual(json.numberValue, true as NSNumber)
        XCTAssertEqual(json.stringValue, "true")

        json.bool = false
        XCTAssertEqual(json.bool!, false)
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.numberValue, false as NSNumber)

        json.bool = nil
        XCTAssertTrue(json.bool == nil)
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.numberValue, 0)

        json.boolValue = true
        XCTAssertEqual(json.bool!, true)
        XCTAssertEqual(json.boolValue, true)
        XCTAssertEqual(json.numberValue, true as NSNumber)
    }

    func testDouble() {
        var json = JSON(9876543210.123456789)
        XCTAssertEqual(json.double!, 9876543210.123456789)
        XCTAssertEqual(json.doubleValue, 9876543210.123456789)
        XCTAssertEqual(json.numberValue, 9876543210.123456789)
        XCTAssertEqual(json.stringValue, "9876543210.123457")

        json.double = 2.8765432
        XCTAssertEqual(json.double!, 2.8765432)
        XCTAssertEqual(json.doubleValue, 2.8765432)
        XCTAssertEqual(json.numberValue, 2.8765432)

        json.doubleValue = 89.0987654
        XCTAssertEqual(json.double!, 89.0987654)
        XCTAssertEqual(json.doubleValue, 89.0987654)
        XCTAssertEqual(json.numberValue, 89.0987654)

        json.double = nil
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.doubleValue, 0.0)
        XCTAssertEqual(json.numberValue, 0)
    }

    func testFloat() {
        var json = JSON(54321.12345)
        XCTAssertTrue(json.float! == 54321.12345)
        XCTAssertTrue(json.floatValue == 54321.12345)
        XCTAssertEqual(json.numberValue, 54321.12345)
        XCTAssertEqual(json.stringValue, "54321.12345")

        json.double = 23231.65
        XCTAssertTrue(json.float! == 23231.65)
        XCTAssertTrue(json.floatValue == 23231.65)
        XCTAssertEqual(json.numberValue, NSNumber(value: 23231.65))

        json.double = -98766.23
        XCTAssertEqual(json.float!, -98766.23)
        XCTAssertEqual(json.floatValue, -98766.23)
        XCTAssertEqual(json.numberValue, NSNumber(value: -98766.23))
    }

    func testInt() {
        var json = JSON(123456789)
        XCTAssertEqual(json.int!, 123456789)
        XCTAssertEqual(json.intValue, 123456789)
        XCTAssertEqual(json.numberValue, NSNumber(value: 123456789))
        XCTAssertEqual(json.stringValue, "123456789")

        json.int = nil
        XCTAssertTrue(json.boolValue == false)
        XCTAssertTrue(json.intValue == 0)
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as? NSNull, NSNull())
        XCTAssertTrue(json.int == nil)

        json.intValue = 76543
        XCTAssertEqual(json.int!, 76543)
        XCTAssertEqual(json.intValue, 76543)
        XCTAssertEqual(json.numberValue, NSNumber(value: 76543))

        json.intValue = 98765421
        XCTAssertEqual(json.int!, 98765421)
        XCTAssertEqual(json.intValue, 98765421)
        XCTAssertEqual(json.numberValue, NSNumber(value: 98765421))
    }

    func testUInt() {
        var json = JSON(123456789)
        XCTAssertTrue(json.uInt! == 123456789)
        XCTAssertTrue(json.uIntValue == 123456789)
        XCTAssertEqual(json.numberValue, NSNumber(value: 123456789))
        XCTAssertEqual(json.stringValue, "123456789")

        json.uInt = nil
        XCTAssertTrue(json.boolValue == false)
        XCTAssertTrue(json.uIntValue == 0)
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as? NSNull, NSNull())
        XCTAssertTrue(json.uInt == nil)

        json.uIntValue = 76543
        XCTAssertTrue(json.uInt! == 76543)
        XCTAssertTrue(json.uIntValue == 76543)
        XCTAssertEqual(json.numberValue, NSNumber(value: 76543))

        json.uIntValue = 98765421
        XCTAssertTrue(json.uInt! == 98765421)
        XCTAssertTrue(json.uIntValue == 98765421)
        XCTAssertEqual(json.numberValue, NSNumber(value: 98765421))
    }

    func testInt8() {
        let n127 = NSNumber(value: 127)
        var json = JSON(n127)
        XCTAssertTrue(json.int8! == n127.int8Value)
        XCTAssertTrue(json.int8Value == n127.int8Value)
        XCTAssertTrue(json.number! == n127)
        XCTAssertEqual(json.numberValue, n127)
        XCTAssertEqual(json.stringValue, "127")

        let nm128 = NSNumber(value: -128)
        json.int8Value = nm128.int8Value
        XCTAssertTrue(json.int8! == nm128.int8Value)
        XCTAssertTrue(json.int8Value == nm128.int8Value)
        XCTAssertTrue(json.number! == nm128)
        XCTAssertEqual(json.numberValue, nm128)
        XCTAssertEqual(json.stringValue, "-128")

        let n0 = NSNumber(value: 0 as Int8)
        json.int8Value = n0.int8Value
        XCTAssertTrue(json.int8! == n0.int8Value)
        XCTAssertTrue(json.int8Value == n0.int8Value)
        XCTAssertTrue(json.number!.isEqual(to: n0))
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")

        let n1 = NSNumber(value: 1 as Int8)
        json.int8Value = n1.int8Value
        XCTAssertTrue(json.int8! == n1.int8Value)
        XCTAssertTrue(json.int8Value == n1.int8Value)
        XCTAssertTrue(json.number!.isEqual(to:n1))
        XCTAssertEqual(json.numberValue, n1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testUInt8() {
        let n255 = NSNumber(value: 255)
        var json = JSON(n255)
        XCTAssertTrue(json.uInt8! == n255.uint8Value)
        XCTAssertTrue(json.uInt8Value == n255.uint8Value)
        XCTAssertTrue(json.number! == n255)
        XCTAssertEqual(json.numberValue, n255)
        XCTAssertEqual(json.stringValue, "255")

        let nm2 = NSNumber(value: 2)
        json.uInt8Value = nm2.uint8Value
        XCTAssertTrue(json.uInt8! == nm2.uint8Value)
        XCTAssertTrue(json.uInt8Value == nm2.uint8Value)
        XCTAssertTrue(json.number! == nm2)
        XCTAssertEqual(json.numberValue, nm2)
        XCTAssertEqual(json.stringValue, "2")

        let nm0 = NSNumber(value: 0)
        json.uInt8Value = nm0.uint8Value
        XCTAssertTrue(json.uInt8! == nm0.uint8Value)
        XCTAssertTrue(json.uInt8Value == nm0.uint8Value)
        XCTAssertTrue(json.number! == nm0)
        XCTAssertEqual(json.numberValue, nm0)
        XCTAssertEqual(json.stringValue, "0")

        let nm1 = NSNumber(value: 1)
        json.uInt8 = nm1.uint8Value
        XCTAssertTrue(json.uInt8! == nm1.uint8Value)
        XCTAssertTrue(json.uInt8Value == nm1.uint8Value)
        XCTAssertTrue(json.number! == nm1)
        XCTAssertEqual(json.numberValue, nm1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testInt16() {

        let n32767 = NSNumber(value: 32767)
        var json = JSON(n32767)
        XCTAssertTrue(json.int16! == n32767.int16Value)
        XCTAssertTrue(json.int16Value == n32767.int16Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let nm32768 = NSNumber(value: -32768)
        json.int16Value = nm32768.int16Value
        XCTAssertTrue(json.int16! == nm32768.int16Value)
        XCTAssertTrue(json.int16Value == nm32768.int16Value)
        XCTAssertTrue(json.number! == nm32768)
        XCTAssertEqual(json.numberValue, nm32768)
        XCTAssertEqual(json.stringValue, "-32768")

        let n0 = NSNumber(value: 0)
        json.int16Value = n0.int16Value
        XCTAssertTrue(json.int16! == n0.int16Value)
        XCTAssertTrue(json.int16Value == n0.int16Value)
        XCTAssertEqual(json.number, n0)
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")

        let n1 = NSNumber(value: 1)
        json.int16 = n1.int16Value
        XCTAssertTrue(json.int16! == n1.int16Value)
        XCTAssertTrue(json.int16Value == n1.int16Value)
        XCTAssertTrue(json.number! == n1)
        XCTAssertEqual(json.numberValue, n1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testUInt16() {

        let n65535 = NSNumber(value: 65535)
        var json = JSON(n65535)
        XCTAssertTrue(json.uInt16! == n65535.uint16Value)
        XCTAssertTrue(json.uInt16Value == n65535.uint16Value)
        XCTAssertTrue(json.number! == n65535)
        XCTAssertEqual(json.numberValue, n65535)
        XCTAssertEqual(json.stringValue, "65535")

        let n32767 = NSNumber(value: 32767)
        json.uInt16 = n32767.uint16Value
        XCTAssertTrue(json.uInt16! == n32767.uint16Value)
        XCTAssertTrue(json.uInt16Value == n32767.uint16Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")
    }

    func testInt32() {
        let n2147483647 = NSNumber(value: 2147483647)
        var json = JSON(n2147483647)
        XCTAssertTrue(json.int32! == n2147483647.int32Value)
        XCTAssertTrue(json.int32Value == n2147483647.int32Value)
        XCTAssertTrue(json.number! == n2147483647)
        XCTAssertEqual(json.numberValue, n2147483647)
        XCTAssertEqual(json.stringValue, "2147483647")

        let n32767 = NSNumber(value: 32767)
        json.int32 = n32767.int32Value
        XCTAssertTrue(json.int32! == n32767.int32Value)
        XCTAssertTrue(json.int32Value == n32767.int32Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let nm2147483648 = NSNumber(value: -2147483648)
        json.int32Value = nm2147483648.int32Value
        XCTAssertTrue(json.int32! == nm2147483648.int32Value)
        XCTAssertTrue(json.int32Value == nm2147483648.int32Value)
        XCTAssertTrue(json.number! == nm2147483648)
        XCTAssertEqual(json.numberValue, nm2147483648)
        XCTAssertEqual(json.stringValue, "-2147483648")
    }

    func testUInt32() {
        let n2147483648 = NSNumber(value: 2147483648 as UInt32)
        var json = JSON(n2147483648)
        XCTAssertTrue(json.uInt32! == n2147483648.uint32Value)
        XCTAssertTrue(json.uInt32Value == n2147483648.uint32Value)
        XCTAssertTrue(json.number! == n2147483648)
        XCTAssertEqual(json.numberValue, n2147483648)
        XCTAssertEqual(json.stringValue, "2147483648")

        let n32767 = NSNumber(value: 32767 as UInt32)
        json.uInt32 = n32767.uint32Value
        XCTAssertTrue(json.uInt32! == n32767.uint32Value)
        XCTAssertTrue(json.uInt32Value == n32767.uint32Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let n0 = NSNumber(value: 0 as UInt32)
        json.uInt32Value = n0.uint32Value
        XCTAssertTrue(json.uInt32! == n0.uint32Value)
        XCTAssertTrue(json.uInt32Value == n0.uint32Value)
        XCTAssertTrue(json.number! == n0)
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")
    }

    func testInt64() {
        let int64Max = NSNumber(value: INT64_MAX)
        var json = JSON(int64Max)
        XCTAssertTrue(json.int64! == int64Max.int64Value)
        XCTAssertTrue(json.int64Value == int64Max.int64Value)
        XCTAssertTrue(json.number! == int64Max)
        XCTAssertEqual(json.numberValue, int64Max)
        XCTAssertEqual(json.stringValue, int64Max.stringValue)

        let n32767 = NSNumber(value: 32767)
        json.int64 = n32767.int64Value
        XCTAssertTrue(json.int64! == n32767.int64Value)
        XCTAssertTrue(json.int64Value == n32767.int64Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let int64Min = NSNumber(value: (INT64_MAX-1) * -1)
        json.int64Value = int64Min.int64Value
        XCTAssertTrue(json.int64! == int64Min.int64Value)
        XCTAssertTrue(json.int64Value == int64Min.int64Value)
        XCTAssertTrue(json.number! == int64Min)
        XCTAssertEqual(json.numberValue, int64Min)
        XCTAssertEqual(json.stringValue, int64Min.stringValue)
    }

    func testUInt64() {
        let uInt64Max = NSNumber(value: UINT64_MAX)
        var json = JSON(uInt64Max)
        XCTAssertTrue(json.uInt64! == uInt64Max.uint64Value)
        XCTAssertTrue(json.uInt64Value == uInt64Max.uint64Value)
        XCTAssertTrue(json.number! == uInt64Max)
        XCTAssertEqual(json.numberValue, uInt64Max)
        XCTAssertEqual(json.stringValue, uInt64Max.stringValue)

        let n32767 = NSNumber(value: 32767)
        json.int64 = n32767.int64Value
        XCTAssertTrue(json.int64! == n32767.int64Value)
        XCTAssertTrue(json.int64Value == n32767.int64Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")
    }
}

//  PrintableTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class PrintableTests: XCTestCase {
    func testNumber() {
        let json: JSON = 1234567890.876623
        XCTAssertEqual(json.description, "1234567890.876623")
        XCTAssertEqual(json.debugDescription, "1234567890.876623")
    }

    func testBool() {
        let jsonTrue: JSON = true
        XCTAssertEqual(jsonTrue.description, "true")
        XCTAssertEqual(jsonTrue.debugDescription, "true")
        let jsonFalse: JSON = false
        XCTAssertEqual(jsonFalse.description, "false")
        XCTAssertEqual(jsonFalse.debugDescription, "false")
    }

    func testString() {
        let json: JSON = "abcd efg, HIJK;LMn"
        XCTAssertEqual(json.description, "abcd efg, HIJK;LMn")
        XCTAssertEqual(json.debugDescription, "abcd efg, HIJK;LMn")
    }

    func testNil() {
        let jsonNil_1: JSON = JSON.null
        XCTAssertEqual(jsonNil_1.description, "null")
        XCTAssertEqual(jsonNil_1.debugDescription, "null")
        let jsonNil_2: JSON = JSON(NSNull())
        XCTAssertEqual(jsonNil_2.description, "null")
        XCTAssertEqual(jsonNil_2.debugDescription, "null")
    }

    func testArray() {
        let json: JSON = [1, 2, "4", 5, "6"]
        var description = json.description.replacingOccurrences(of: "\n", with: "")
        description = description.replacingOccurrences(of: " ", with: "")
        XCTAssertEqual(description, "[1,2,\"4\",5,\"6\"]")
        XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
        XCTAssertTrue(json.debugDescription.lengthOfBytes(using: String.Encoding.utf8) > 0)
    }

    func testArrayWithStrings() {
        let array = ["\"123\""]
        let json = JSON(array)
        var description = json.description.replacingOccurrences(of: "\n", with: "")
        description = description.replacingOccurrences(of: " ", with: "")
        XCTAssertEqual(description, "[\"\\\"123\\\"\"]")
        XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
        XCTAssertTrue(json.debugDescription.lengthOfBytes(using: String.Encoding.utf8) > 0)
    }

    func testArrayWithOptionals() {
        let array = [1, 2, "4", 5, "6", nil] as [Any?]
        let json = JSON(array)
		guard var description = json.rawString([.castNilToNSNull: true]) else {
			XCTFail("could not represent array")
			return
		}
		description = description.replacingOccurrences(of: "\n", with: "")
        description = description.replacingOccurrences(of: " ", with: "")
        XCTAssertEqual(description, "[1,2,\"4\",5,\"6\",null]")
        XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
        XCTAssertTrue(json.debugDescription.lengthOfBytes(using: String.Encoding.utf8) > 0)
    }

    func testDictionary() {
        let json: JSON = ["1": 2, "2": "two", "3": 3]
        var debugDescription = json.debugDescription.replacingOccurrences(of: "\n", with: "")
        debugDescription = debugDescription.replacingOccurrences(of: " ", with: "")
        XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
        XCTAssertTrue(debugDescription.range(of: "\"1\":2", options: String.CompareOptions.caseInsensitive) != nil)
        XCTAssertTrue(debugDescription.range(of: "\"2\":\"two\"", options: String.CompareOptions.caseInsensitive) != nil)
        XCTAssertTrue(debugDescription.range(of: "\"3\":3", options: String.CompareOptions.caseInsensitive) != nil)
    }

    func testDictionaryWithStrings() {
        let dict = ["foo": "{\"bar\":123}"] as [String: Any]
        let json = JSON(dict)
        var debugDescription = json.debugDescription.replacingOccurrences(of: "\n", with: "")
        debugDescription = debugDescription.replacingOccurrences(of: " ", with: "")
        XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
        let exceptedResult = "{\"foo\":\"{\\\"bar\\\":123}\"}"
        XCTAssertEqual(debugDescription, exceptedResult)
    }

    func testDictionaryWithOptionals() {
        let dict = ["1": 2, "2": "two", "3": nil] as [String: Any?]
        let json = JSON(dict)
		guard var description = json.rawString([.castNilToNSNull: true]) else {
			XCTFail("could not represent dictionary")
			return
		}
		description = description.replacingOccurrences(of: "\n", with: "")
        description = description.replacingOccurrences(of: " ", with: "")
        XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
        XCTAssertTrue(description.range(of: "\"1\":2", options: NSString.CompareOptions.caseInsensitive) != nil)
        XCTAssertTrue(description.range(of: "\"2\":\"two\"", options: NSString.CompareOptions.caseInsensitive) != nil)
        XCTAssertTrue(description.range(of: "\"3\":null", options: NSString.CompareOptions.caseInsensitive) != nil)
    }
}
//  RawRepresentableTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class RawRepresentableTests: XCTestCase {

    func testNumber() {
        let json: JSON = JSON(rawValue: 948394394.347384 as NSNumber)!
        XCTAssertEqual(json.int!, 948394394)
        XCTAssertEqual(json.intValue, 948394394)
        XCTAssertEqual(json.double!, 948394394.347384)
        XCTAssertEqual(json.doubleValue, 948394394.347384)
        XCTAssertEqual(json.float!, 948394394.347384)
        XCTAssertEqual(json.floatValue, 948394394.347384)

        let object: Any = json.rawValue
        if let int = object as? Int {
            XCTAssertEqual(int, 948394394)
        }
        XCTAssertEqual(object as? Double, 948394394.347384)
        if let float = object as? Float {
            XCTAssertEqual(float, 948394394.347384)
        }
        XCTAssertEqual(object as? NSNumber, 948394394.347384)
    }

    func testBool() {
        let jsonTrue: JSON = JSON(rawValue: true as NSNumber)!
        XCTAssertEqual(jsonTrue.bool!, true)
        XCTAssertEqual(jsonTrue.boolValue, true)

        let jsonFalse: JSON = JSON(rawValue: false)!
        XCTAssertEqual(jsonFalse.bool!, false)
        XCTAssertEqual(jsonFalse.boolValue, false)

        let objectTrue = jsonTrue.rawValue
        XCTAssertEqual(objectTrue as? Bool, true)

        let objectFalse = jsonFalse.rawValue
        XCTAssertEqual(objectFalse as? Bool, false)
    }

    func testString() {
        let string = "The better way to deal with JSON data in Swift."
        if let json: JSON = JSON(rawValue: string) {
            XCTAssertEqual(json.string!, string)
            XCTAssertEqual(json.stringValue, string)
            XCTAssertTrue(json.array == nil)
            XCTAssertTrue(json.dictionary == nil)
            XCTAssertTrue(json.null == nil)
            XCTAssertTrue(json.error == nil)
            XCTAssertTrue(json.type == .string)
            XCTAssertEqual(json.object as? String, string)
        } else {
            XCTFail("Should not run into here")
        }

        let object: Any = JSON(rawValue: string)!.rawValue
        XCTAssertEqual(object as? String, string)
    }

    func testNil() {
        if JSON(rawValue: NSObject()) != nil {
            XCTFail("Should not run into here")
        }
    }

    func testArray() {
        let array = [1, 2, "3", 4102, "5632", "abocde", "!@# $%^&*()"] as NSArray
        if let json: JSON = JSON(rawValue: array) {
            XCTAssertEqual(json, JSON(array))
        }

        let object: Any = JSON(rawValue: array)!.rawValue
        XCTAssertTrue(array == object as! NSArray)
    }

    func testDictionary() {
        let dictionary = ["1": 2, "2": 2, "three": 3, "list": ["aa", "bb", "dd"]] as NSDictionary
        if let json: JSON = JSON(rawValue: dictionary) {
            XCTAssertEqual(json, JSON(dictionary))
        }

        let object: Any = JSON(rawValue: dictionary)!.rawValue
        XCTAssertTrue(dictionary == object as! NSDictionary)
    }
}
//  RawTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class RawTests: XCTestCase {

    func testRawData() {
        let json: JSON = ["somekey": "some string value"]
        let expectedRawData = "{\"somekey\":\"some string value\"}".data(using: String.Encoding.utf8)
        do {
            let data: Data = try json.rawData()
            XCTAssertEqual(expectedRawData, data)
        } catch _ {}
    }

    func testInvalidJSONForRawData() {
        let json: JSON = "...<nonsense>xyz</nonsense>"
        do {
            _ = try json.rawData()
        } catch let error as SwiftyJSONError {
            XCTAssertEqual(error, SwiftyJSONError.invalidJSON)
        } catch _ {}
    }

    func testArray() {
        let json: JSON = [1, "2", 3.12, NSNull(), true, ["name": "Jack"]]
        let data: Data?
        do {
            data = try json.rawData()
        } catch _ {
            data = nil
        }
        let string = json.rawString()
        XCTAssertTrue (data != nil)
        XCTAssertTrue (string!.lengthOfBytes(using: String.Encoding.utf8) > 0)
    }

    func testDictionary() {
        let json: JSON = ["number": 111111.23456789, "name": "Jack", "list": [1, 2, 3, 4], "bool": false, "null": NSNull()]
        let data: Data?
        do {
            data = try json.rawData()
        } catch _ {
            data = nil
        }
        let string = json.rawString()
        XCTAssertTrue (data != nil)
        XCTAssertTrue (string!.lengthOfBytes(using: String.Encoding.utf8) > 0)
    }

    func testString() {
        let json: JSON = "I'm a json"
        XCTAssertEqual(json.rawString(), "I'm a json")
    }

    func testNumber() {
        let json: JSON = 123456789.123
        XCTAssertEqual(json.rawString(), "123456789.123")
    }

    func testBool() {
        let json: JSON = true
        XCTAssertEqual(json.rawString(), "true")
    }

    func testNull() {
        let json: JSON = JSON.null
        XCTAssertEqual(json.rawString(), "null")
    }

    func testNestedJSON() {
        let inner: JSON = ["name": "john doe"]
        let json: JSON = ["level": 1337, "user": inner]
        let data: Data?
        do {
            data = try json.rawData()
        } catch _ {
            data = nil
        }
        let string = json.rawString()
        XCTAssertNotNil(data)
        XCTAssertNotNil(string)
    }
}
//  SequenceTypeTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class SequenceTypeTests: XCTestCase {

    func testJSONFile() {
        if let file = Bundle(for: BaseTests.self).path(forResource: "Tests", ofType: "json") {
            let testData = try? Data(contentsOf: URL(fileURLWithPath: file))
            guard let json = try? JSON(data: testData!) else {
                XCTFail("Unable to parse the data")
                return
            }
            for (index, sub) in json {
                switch (index as NSString).integerValue {
                case 0:
                    XCTAssertTrue(sub["id_str"] == "240558470661799936")
                case 1:
                    XCTAssertTrue(sub["id_str"] == "240556426106372096")
                case 2:
                    XCTAssertTrue(sub["id_str"] == "240539141056638977")
                default:
                    continue
                }
            }
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }

    func testArrayAllNumber() {
        let json: JSON = [1, 2.0, 3.3, 123456789, 987654321.123456789]
        XCTAssertEqual(json.count, 5)

        var index = 0
        var array = [NSNumber]()
        for (i, sub) in json {
            XCTAssertEqual(sub, json[index])
            XCTAssertEqual(i, "\(index)")
            array.append(sub.number!)
            index += 1
        }
        XCTAssertEqual(index, 5)
        XCTAssertEqual(array, [1, 2.0, 3.3, 123456789, 987654321.123456789])
    }

    func testArrayAllBool() {
        let json: JSON = JSON([true, false, false, true, true])
        XCTAssertEqual(json.count, 5)

        var index = 0
        var array = [Bool]()
        for (i, sub) in json {
            XCTAssertEqual(sub, json[index])
            XCTAssertEqual(i, "\(index)")
            array.append(sub.bool!)
            index += 1
        }
        XCTAssertEqual(index, 5)
        XCTAssertEqual(array, [true, false, false, true, true])
    }

    func testArrayAllString() {
        let json: JSON = JSON(rawValue: ["aoo", "bpp", "zoo"] as NSArray)!
        XCTAssertEqual(json.count, 3)

        var index = 0
        var array = [String]()
        for (i, sub) in json {
            XCTAssertEqual(sub, json[index])
            XCTAssertEqual(i, "\(index)")
            array.append(sub.string!)
            index += 1
        }
        XCTAssertEqual(index, 3)
        XCTAssertEqual(array, ["aoo", "bpp", "zoo"])
    }

    func testArrayWithNull() {
        let json: JSON = JSON(rawValue: ["aoo", "bpp", NSNull(), "zoo"] as NSArray)!
        XCTAssertEqual(json.count, 4)

        var index = 0
        var array = [AnyObject]()
        for (i, sub) in json {
            XCTAssertEqual(sub, json[index])
            XCTAssertEqual(i, "\(index)")
            array.append(sub.object as AnyObject)
            index += 1
        }
        XCTAssertEqual(index, 4)
        XCTAssertEqual(array[0] as? String, "aoo")
        XCTAssertEqual(array[2] as? NSNull, NSNull())
    }

    func testArrayAllDictionary() {
        let json: JSON = [["1": 1, "2": 2], ["a": "A", "b": "B"], ["null": NSNull()]]
        XCTAssertEqual(json.count, 3)

        var index = 0
        var array = [AnyObject]()
        for (i, sub) in json {
            XCTAssertEqual(sub, json[index])
            XCTAssertEqual(i, "\(index)")
            array.append(sub.object as AnyObject)
            index += 1
        }
        XCTAssertEqual(index, 3)
        XCTAssertEqual((array[0] as! [String: Int])["1"]!, 1)
        XCTAssertEqual((array[0] as! [String: Int])["2"]!, 2)
        XCTAssertEqual((array[1] as! [String: String])["a"]!, "A")
        XCTAssertEqual((array[1] as! [String: String])["b"]!, "B")
        XCTAssertEqual((array[2] as! [String: NSNull])["null"]!, NSNull())
    }

    func testDictionaryAllNumber() {
        let json: JSON = ["double": 1.11111, "int": 987654321]
        XCTAssertEqual(json.count, 2)

        var index = 0
        var dictionary = [String: NSNumber]()
        for (key, sub) in json {
            XCTAssertEqual(sub, json[key])
            dictionary[key] = sub.number!
            index += 1
        }

        XCTAssertEqual(index, 2)
        XCTAssertEqual(dictionary["double"]! as NSNumber, 1.11111)
        XCTAssertEqual(dictionary["int"]! as NSNumber, 987654321)
    }

    func testDictionaryAllBool() {
        let json: JSON = ["t": true, "f": false, "false": false, "tr": true, "true": true]
        XCTAssertEqual(json.count, 5)

        var index = 0
        var dictionary = [String: Bool]()
        for (key, sub) in json {
            XCTAssertEqual(sub, json[key])
            dictionary[key] = sub.bool!
            index += 1
        }

        XCTAssertEqual(index, 5)
        XCTAssertEqual(dictionary["t"]! as Bool, true)
        XCTAssertEqual(dictionary["false"]! as Bool, false)
    }

    func testDictionaryAllString() {
        let json: JSON = JSON(rawValue: ["a": "aoo", "bb": "bpp", "z": "zoo"] as NSDictionary)!
        XCTAssertEqual(json.count, 3)

        var index = 0
        var dictionary = [String: String]()
        for (key, sub) in json {
            XCTAssertEqual(sub, json[key])
            dictionary[key] = sub.string!
            index += 1
        }

        XCTAssertEqual(index, 3)
        XCTAssertEqual(dictionary["a"]! as String, "aoo")
        XCTAssertEqual(dictionary["bb"]! as String, "bpp")
    }

    func testDictionaryWithNull() {
        let json: JSON = JSON(rawValue: ["a": "aoo", "bb": "bpp", "null": NSNull(), "z": "zoo"] as NSDictionary)!
        XCTAssertEqual(json.count, 4)

        var index = 0
        var dictionary = [String: AnyObject]()
        for (key, sub) in json {
            XCTAssertEqual(sub, json[key])
            dictionary[key] = sub.object as AnyObject?
            index += 1
        }

        XCTAssertEqual(index, 4)
        XCTAssertEqual(dictionary["a"]! as? String, "aoo")
        XCTAssertEqual(dictionary["bb"]! as? String, "bpp")
        XCTAssertEqual(dictionary["null"]! as? NSNull, NSNull())
    }

    func testDictionaryAllArray() {
        let json: JSON = JSON (["Number": [NSNumber(value: 1), NSNumber(value: 2.123456), NSNumber(value: 123456789)], "String": ["aa", "bbb", "cccc"], "Mix": [true, "766", NSNull(), 655231.9823]])

        XCTAssertEqual(json.count, 3)

        var index = 0
        var dictionary = [String: AnyObject]()
        for (key, sub) in json {
            XCTAssertEqual(sub, json[key])
            dictionary[key] = sub.object as AnyObject?
            index += 1
        }

        XCTAssertEqual(index, 3)
        XCTAssertEqual((dictionary["Number"] as! NSArray)[0] as? Int, 1)
        XCTAssertEqual((dictionary["Number"] as! NSArray)[1] as? Double, 2.123456)
        XCTAssertEqual((dictionary["String"] as! NSArray)[0] as? String, "aa")
        XCTAssertEqual((dictionary["Mix"] as! NSArray)[0] as? Bool, true)
        XCTAssertEqual((dictionary["Mix"] as! NSArray)[1] as? String, "766")
        XCTAssertEqual((dictionary["Mix"] as! NSArray)[2] as? NSNull, NSNull())
        XCTAssertEqual((dictionary["Mix"] as! NSArray)[3] as? Double, 655231.9823)
    }

    func testDictionaryIteratingPerformance() {
        var json: JSON = [:]
        for i in 1...1000 {
            json[String(i)] = "hello"
        }
        measure {
            for (key, value) in json {
                print(key, value)
            }
        }
    }
}
//  StringTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class StringTests: XCTestCase {

    func testString() {
        //getter
        var json = JSON("abcdefg hijklmn;opqrst.?+_()")
        XCTAssertEqual(json.string!, "abcdefg hijklmn;opqrst.?+_()")
        XCTAssertEqual(json.stringValue, "abcdefg hijklmn;opqrst.?+_()")

        json.string = "12345?67890.@#"
        XCTAssertEqual(json.string!, "12345?67890.@#")
        XCTAssertEqual(json.stringValue, "12345?67890.@#")
    }

    func testUrl() {
        let json = JSON("http://github.com")
        XCTAssertEqual(json.url!, URL(string: "http://github.com")!)
    }

    func testBool() {
        let json = JSON("true")
        XCTAssertTrue(json.boolValue)
    }

    func testBoolWithY() {
        let json = JSON("Y")
        XCTAssertTrue(json.boolValue)
    }

    func testBoolWithT() {
        let json = JSON("T")
        XCTAssertTrue(json.boolValue)
    }

    func testBoolWithYes() {
        let json = JSON("Yes")
        XCTAssertTrue(json.boolValue)
    }

    func testBoolWith1() {
        let json = JSON("1")
        XCTAssertTrue(json.boolValue)
    }

    func testUrlPercentEscapes() {
        let emDash = "\\u2014"
        let urlString = "http://examble.com/unencoded" + emDash + "string"
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return XCTFail("Couldn't encode URL string \(urlString)")
        }
        let json = JSON(urlString)
        XCTAssertEqual(json.url!, URL(string: encodedURLString)!, "Wrong unpacked ")
        let preEscaped = JSON(encodedURLString)
        XCTAssertEqual(preEscaped.url!, URL(string: encodedURLString)!, "Wrong unpacked ")
    }
}

//  SubscriptTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.




class SubscriptTests: XCTestCase {

    func testArrayAllNumber() {
        var json: JSON = [1, 2.0, 3.3, 123456789, 987654321.123456789]
        XCTAssertTrue(json == [1, 2.0, 3.3, 123456789, 987654321.123456789])
        XCTAssertTrue(json[0] == 1)
        XCTAssertEqual(json[1].double!, 2.0)
        XCTAssertTrue(json[2].floatValue == 3.3)
        XCTAssertEqual(json[3].int!, 123456789)
        XCTAssertEqual(json[4].doubleValue, 987654321.123456789)

        json[0] = 1.9
        json[1] = 2.899
        json[2] = 3.567
        json[3] = 0.999
        json[4] = 98732

        XCTAssertTrue(json[0] == 1.9)
        XCTAssertEqual(json[1].doubleValue, 2.899)
        XCTAssertTrue(json[2] == 3.567)
        XCTAssertTrue(json[3].float! == 0.999)
        XCTAssertTrue(json[4].intValue == 98732)
    }

    func testArrayAllBool() {
        var json: JSON = [true, false, false, true, true]
        XCTAssertTrue(json == [true, false, false, true, true])
        XCTAssertTrue(json[0] == true)
        XCTAssertTrue(json[1] == false)
        XCTAssertTrue(json[2] == false)
        XCTAssertTrue(json[3] == true)
        XCTAssertTrue(json[4] == true)

        json[0] = false
        json[4] = true
        XCTAssertTrue(json[0] == false)
        XCTAssertTrue(json[4] == true)
    }

    func testArrayAllString() {
        var json: JSON = JSON(rawValue: ["aoo", "bpp", "zoo"] as NSArray)!
        XCTAssertTrue(json == ["aoo", "bpp", "zoo"])
        XCTAssertTrue(json[0] == "aoo")
        XCTAssertTrue(json[1] == "bpp")
        XCTAssertTrue(json[2] == "zoo")

        json[1] = "update"
        XCTAssertTrue(json[0] == "aoo")
        XCTAssertTrue(json[1] == "update")
        XCTAssertTrue(json[2] == "zoo")
    }

    func testArrayWithNull() {
        var json: JSON = JSON(rawValue: ["aoo", "bpp", NSNull(), "zoo"] as NSArray)!
        XCTAssertTrue(json[0] == "aoo")
        XCTAssertTrue(json[1] == "bpp")
        XCTAssertNil(json[2].string)
        XCTAssertNotNil(json[2].null)
        XCTAssertTrue(json[3] == "zoo")

        json[2] = "update"
        json[3] = JSON(NSNull())
        XCTAssertTrue(json[0] == "aoo")
        XCTAssertTrue(json[1] == "bpp")
        XCTAssertTrue(json[2] == "update")
        XCTAssertNil(json[3].string)
        XCTAssertNotNil(json[3].null)
    }

    func testArrayAllDictionary() {
        let json: JSON = [["1": 1, "2": 2], ["a": "A", "b": "B"], ["null": NSNull()]]
        XCTAssertTrue(json[0] == ["1": 1, "2": 2])
        XCTAssertEqual(json[1].dictionary!, ["a": "A", "b": "B"])
        XCTAssertEqual(json[2], JSON(["null": NSNull()]))
        XCTAssertTrue(json[0]["1"] == 1)
        XCTAssertTrue(json[0]["2"] == 2)
        XCTAssertEqual(json[1]["a"], JSON(rawValue: "A")!)
        XCTAssertEqual(json[1]["b"], JSON("B"))
        XCTAssertNotNil(json[2]["null"].null)
        XCTAssertNotNil(json[2, "null"].null)
        let keys: [JSONSubscriptType] = [1, "a"]
        XCTAssertEqual(json[keys], JSON(rawValue: "A")!)
    }

    func testDictionaryAllNumber() {
        var json: JSON = ["double": 1.11111, "int": 987654321]
        XCTAssertEqual(json["double"].double!, 1.11111)
        XCTAssertTrue(json["int"] == 987654321)

        json["double"] = 2.2222
        json["int"] = 123456789
        json["add"] = 7890
        XCTAssertTrue(json["double"] == 2.2222)
        XCTAssertEqual(json["int"].doubleValue, 123456789.0)
        XCTAssertEqual(json["add"].intValue, 7890)
    }

    func testDictionaryAllBool() {
        var json: JSON = ["t": true, "f": false, "false": false, "tr": true, "true": true, "yes": true, "1": true]
        XCTAssertTrue(json["1"] == true)
        XCTAssertTrue(json["yes"] == true)
        XCTAssertTrue(json["t"] == true)
        XCTAssertTrue(json["f"] == false)
        XCTAssertTrue(json["false"] == false)
        XCTAssertTrue(json["tr"] == true)
        XCTAssertTrue(json["true"] == true)

        json["f"] = true
        json["tr"] = false
        XCTAssertTrue(json["f"] == true)
        XCTAssertTrue(json["tr"] == JSON(false))
    }

    func testDictionaryAllString() {
        var json: JSON = JSON(rawValue: ["a": "aoo", "bb": "bpp", "z": "zoo"] as NSDictionary)!
        XCTAssertTrue(json["a"] == "aoo")
        XCTAssertEqual(json["bb"], JSON("bpp"))
        XCTAssertTrue(json["z"] == "zoo")

        json["bb"] = "update"
        XCTAssertTrue(json["a"] == "aoo")
        XCTAssertTrue(json["bb"] == "update")
        XCTAssertTrue(json["z"] == "zoo")
    }

    func testDictionaryWithNull() {
        var json: JSON = JSON(rawValue: ["a": "aoo", "bb": "bpp", "null": NSNull(), "z": "zoo"] as NSDictionary)!
        XCTAssertTrue(json["a"] == "aoo")
        XCTAssertEqual(json["bb"], JSON("bpp"))
        XCTAssertEqual(json["null"], JSON(NSNull()))
        XCTAssertTrue(json["z"] == "zoo")

        json["null"] = "update"
        XCTAssertTrue(json["a"] == "aoo")
        XCTAssertTrue(json["null"] == "update")
        XCTAssertTrue(json["z"] == "zoo")
    }

    func testDictionaryAllArray() {
        //Swift bug: [1, 2.01,3.09] is convert to [1, 2, 3] (Array<Int>)
        let json: JSON = JSON ([[NSNumber(value: 1), NSNumber(value: 2.123456), NSNumber(value: 123456789)], ["aa", "bbb", "cccc"], [true, "766", NSNull(), 655231.9823]] as NSArray)
        XCTAssertTrue(json[0] == [1, 2.123456, 123456789])
        XCTAssertEqual(json[0][1].double!, 2.123456)
        XCTAssertTrue(json[0][2] == 123456789)
        XCTAssertTrue(json[1][0] == "aa")
        XCTAssertTrue(json[1] == ["aa", "bbb", "cccc"])
        XCTAssertTrue(json[2][0] == true)
        XCTAssertTrue(json[2][1] == "766")
        XCTAssertTrue(json[[2, 1]] == "766")
        XCTAssertEqual(json[2][2], JSON(NSNull()))
        XCTAssertEqual(json[2, 2], JSON(NSNull()))
        XCTAssertEqual(json[2][3], JSON(655231.9823))
        XCTAssertEqual(json[2, 3], JSON(655231.9823))
        XCTAssertEqual(json[[2, 3]], JSON(655231.9823))
    }

    func testOutOfBounds() {
        let json: JSON = JSON ([[NSNumber(value: 1), NSNumber(value: 2.123456), NSNumber(value: 123456789)], ["aa", "bbb", "cccc"], [true, "766", NSNull(), 655231.9823]] as NSArray)
        XCTAssertEqual(json[9], JSON.null)
        XCTAssertEqual(json[-2].error, SwiftyJSONError.indexOutOfBounds)
        XCTAssertEqual(json[6].error, SwiftyJSONError.indexOutOfBounds)
        XCTAssertEqual(json[9][8], JSON.null)
        XCTAssertEqual(json[8][7].error, SwiftyJSONError.indexOutOfBounds)
        XCTAssertEqual(json[8, 7].error, SwiftyJSONError.indexOutOfBounds)
        XCTAssertEqual(json[999].error, SwiftyJSONError.indexOutOfBounds)
    }

    func testErrorWrongType() {
        let json = JSON(12345)
        XCTAssertEqual(json[9], JSON.null)
        XCTAssertEqual(json[9].error, SwiftyJSONError.wrongType)
        XCTAssertEqual(json[8][7].error, SwiftyJSONError.wrongType)
        XCTAssertEqual(json["name"], JSON.null)
        XCTAssertEqual(json["name"].error, SwiftyJSONError.wrongType)
        XCTAssertEqual(json[0]["name"].error, SwiftyJSONError.wrongType)
        XCTAssertEqual(json["type"]["name"].error, SwiftyJSONError.wrongType)
        XCTAssertEqual(json["name"][99].error, SwiftyJSONError.wrongType)
        XCTAssertEqual(json[1, "Value"].error, SwiftyJSONError.wrongType)
        XCTAssertEqual(json[1, 2, "Value"].error, SwiftyJSONError.wrongType)
        XCTAssertEqual(json[[1, 2, "Value"]].error, SwiftyJSONError.wrongType)
    }

    func testErrorNotExist() {
        let json: JSON = ["name": "NAME", "age": 15]
        XCTAssertEqual(json["Type"], JSON.null)
        XCTAssertEqual(json["Type"].error, SwiftyJSONError.notExist)
        XCTAssertEqual(json["Type"][1].error, SwiftyJSONError.notExist)
        XCTAssertEqual(json["Type", 1].error, SwiftyJSONError.notExist)
        XCTAssertEqual(json["Type"]["Value"].error, SwiftyJSONError.notExist)
        XCTAssertEqual(json["Type", "Value"].error, SwiftyJSONError.notExist)
    }

    func testMultilevelGetter() {
        let json: JSON = [[[[["one": 1]]]]]
        XCTAssertEqual(json[[0, 0, 0, 0, "one"]].int!, 1)
        XCTAssertEqual(json[0, 0, 0, 0, "one"].int!, 1)
        XCTAssertEqual(json[0][0][0][0]["one"].int!, 1)
    }

    func testMultilevelSetter1() {
        var json: JSON = [[[[["num": 1]]]]]
        json[0, 0, 0, 0, "num"] = 2
        XCTAssertEqual(json[[0, 0, 0, 0, "num"]].intValue, 2)
        json[0, 0, 0, 0, "num"] = JSON.null
        XCTAssertEqual(json[0, 0, 0, 0, "num"].null!, NSNull())
        json[0, 0, 0, 0, "num"] = 100.009
        XCTAssertEqual(json[0][0][0][0]["num"].doubleValue, 100.009)
        json[[0, 0, 0, 0]] = ["name": "Jack"]
        XCTAssertEqual(json[0, 0, 0, 0, "name"].stringValue, "Jack")
        XCTAssertEqual(json[0][0][0][0]["name"].stringValue, "Jack")
        XCTAssertEqual(json[[0, 0, 0, 0, "name"]].stringValue, "Jack")
        json[[0, 0, 0, 0, "name"]].string = "Mike"
        XCTAssertEqual(json[0, 0, 0, 0, "name"].stringValue, "Mike")
        let path: [JSONSubscriptType] = [0, 0, 0, 0, "name"]
        json[path].string = "Jim"
        XCTAssertEqual(json[path].stringValue, "Jim")
    }

    func testMultilevelSetter2() {
        var json: JSON = ["user": ["id": 987654, "info": ["name": "jack", "email": "jack@gmail.com"], "feeds": [98833, 23443, 213239, 23232]]]
        json["user", "info", "name"] = "jim"
        XCTAssertEqual(json["user", "id"], 987654)
        XCTAssertEqual(json["user", "info", "name"], "jim")
        XCTAssertEqual(json["user", "info", "email"], "jack@gmail.com")
        XCTAssertEqual(json["user", "feeds"], [98833, 23443, 213239, 23232])
        json["user", "info", "email"] = "jim@hotmail.com"
        XCTAssertEqual(json["user", "id"], 987654)
        XCTAssertEqual(json["user", "info", "name"], "jim")
        XCTAssertEqual(json["user", "info", "email"], "jim@hotmail.com")
        XCTAssertEqual(json["user", "feeds"], [98833, 23443, 213239, 23232])
        json["user", "info"] = ["name": "tom", "email": "tom@qq.com"]
        XCTAssertEqual(json["user", "id"], 987654)
        XCTAssertEqual(json["user", "info", "name"], "tom")
        XCTAssertEqual(json["user", "info", "email"], "tom@qq.com")
        XCTAssertEqual(json["user", "feeds"], [98833, 23443, 213239, 23232])
        json["user", "feeds"] = [77323, 2313, 4545, 323]
        XCTAssertEqual(json["user", "id"], 987654)
        XCTAssertEqual(json["user", "info", "name"], "tom")
        XCTAssertEqual(json["user", "info", "email"], "tom@qq.com")
        XCTAssertEqual(json["user", "feeds"], [77323, 2313, 4545, 323])
    }
}
