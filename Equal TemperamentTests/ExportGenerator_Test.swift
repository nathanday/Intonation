//
//  ExportGenerator_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 13/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class ExportGenerator_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTextExportGenerator() {
		let		theIntervals = [RationalInterval(1),
								RationalInterval(5,4),
								RationalInterval(3,2),
								RationalInterval(15,8)];
		let		theTextExportGenerator = TextExportGenerator(everyInterval:theIntervals);
		guard let theData = theTextExportGenerator.data() else {
			XCTFail();
			return;
		}
		XCTAssertEqual(String(data: theData, encoding: String.Encoding.utf8), "1.0\n1.25\n1.5\n1.875")
    }

	func testJSONExportGenerator() {
		let		theIntervals = [RationalInterval(1),
								   RationalInterval(5,4),
								   RationalInterval(3,2),
								   RationalInterval(15,8)];
		let		theJSONExportGenerator = JSONExportGenerator(everyInterval:theIntervals);
		guard let theData = try? theJSONExportGenerator.data() else {
			XCTFail();
			return;
		}
		XCTAssertEqual(String(data: theData, encoding: String.Encoding.utf8), "{\"intervals\":[{\"name\":\"1\",\"value\":1},{\"name\":\"5\\/4\",\"value\":1.25},{\"name\":\"3\\/2\",\"value\":1.5},{\"name\":\"15\\/8\",\"value\":1.875}]}")
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
