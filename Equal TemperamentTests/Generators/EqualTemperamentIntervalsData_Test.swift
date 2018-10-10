//
//  EqualTemperamentIntervalsData_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 10/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class EqualTemperamentIntervalsData_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testTwelve() {
		guard let theEqualTemperamentIntervalsData = EqualTemperamentIntervalsData(propertyList: ["equalTemperament":["degrees":12,"interval":"2:1"]]) else {
			XCTFail();
			return;
		}
		XCTAssertEqual( theEqualTemperamentIntervalsData.documentType, .equalTemperament );
		XCTAssertEqual( theEqualTemperamentIntervalsData.degrees, 12 );
		XCTAssertEqual( theEqualTemperamentIntervalsData.interval, RationalInterval(2) );
		let		theGenerator = theEqualTemperamentIntervalsData.intervalsDataGenerator( );
		let		theEveryInterval = theGenerator.everyEntry;
		XCTAssertEqual( theEveryInterval.count, 13 );
		for i in 0...12 {
			XCTAssertEqual( theEveryInterval[i], IntervalEntry(interval: EqualTemperamentInterval(degree: UInt(i), steps: 12, interval: RationalInterval(2), names: [])) );
		}
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
