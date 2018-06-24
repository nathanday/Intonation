//
//  UInt+Additions_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 7/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class UInt_Additions_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPow() {
		var		theValue : Int64 = 1;
		for x in UInt64(0)...UInt64(26) {
			XCTAssertEqual(pow(Int64(2),x), theValue, "Passed saturationComponent" );
			theValue *= 2;
		}
    }
}
