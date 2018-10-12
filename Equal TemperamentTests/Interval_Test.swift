//
//  Interval_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 12/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class Interval_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRationalInterval() {
		let		theRationalInterval	= RationalInterval(9, 8);
		XCTAssertEqual(theRationalInterval.toDouble, 1.125, accuracy: 0.0001);
		XCTAssertEqual(theRationalInterval.toString, "9/8");
		XCTAssertEqual(theRationalInterval.numerator, 9);
		XCTAssertEqual(theRationalInterval.denominator, 8);
		XCTAssertTrue(theRationalInterval == RationalInterval(9, 8));
		XCTAssertEqual(theRationalInterval.oddLimit,9);
		XCTAssertEqual(theRationalInterval.primeLimit,3);
		XCTAssertEqual(theRationalInterval.factorsString,"3²∶2³");
		XCTAssertEqual(theRationalInterval.ratioString,"9:8");
		XCTAssertEqual(theRationalInterval.additiveDissonance,9+8);
		XCTAssertEqual(theRationalInterval.numeratorForDenominator(16),18);

		XCTAssertTrue(theRationalInterval < RationalInterval(11, 8));
		XCTAssertTrue(theRationalInterval < 2);
		XCTAssertTrue(theRationalInterval <= RationalInterval(9, 8));
		XCTAssertTrue(theRationalInterval <= RationalInterval(11, 8));

		XCTAssertTrue(theRationalInterval > RationalInterval(11, 10));
		XCTAssertTrue(theRationalInterval > 1);
		XCTAssertTrue(theRationalInterval >= RationalInterval(9, 8));
		XCTAssertEqual(theRationalInterval * RationalInterval(10, 8), RationalInterval(45, 32));
		XCTAssertEqual(theRationalInterval * 2, RationalInterval(9, 4));
		var		a = theRationalInterval;
		a *= RationalInterval(10, 8);
		XCTAssertEqual(a, RationalInterval(45, 32));
		a = theRationalInterval
		a *= 2
		XCTAssertEqual(a, RationalInterval(9, 4));
}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
