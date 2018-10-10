//
//  AdHocIntervalsData_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 11/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class AdHocIntervalsData_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
		guard let theAdHocIntervalsData = AdHocIntervalsData(propertyList: ["adHoc" : ["1","5:4","1.51111", "2"]]) else {
			XCTFail();
			return;
		}
		XCTAssertEqual( theAdHocIntervalsData.documentType, .adHoc );
		let		theGenerator = theAdHocIntervalsData.intervalsDataGenerator( );
		let		theEveryInterval = theGenerator.everyEntry;
		XCTAssertEqual( theEveryInterval.count, 4 );
		XCTAssertEqual( theEveryInterval[0], IntervalEntry(interval: RationalInterval(1)) );
		XCTAssertEqual( theEveryInterval[1], IntervalEntry(interval: RationalInterval(5,4)) );
		XCTAssertEqual( theEveryInterval[2], IntervalEntry(interval: IrrationalInterval(1.51111)) );
		XCTAssertEqual( theEveryInterval[3], IntervalEntry(interval: RationalInterval(2)) );
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
