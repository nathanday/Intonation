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
		XCTAssertEqual(theRationalInterval * 2, RationalInterval(9, 4));
		var		a = theRationalInterval;
		a *= 2
		XCTAssertEqual(a, RationalInterval(9, 4));
	}

	func testIrrationalInterval() {
		let		theIrrationalInterval	= IrrationalInterval(3.1415);
		XCTAssertEqual(theIrrationalInterval.toDouble, Double.pi, accuracy: 0.0001);
		XCTAssertEqual(theIrrationalInterval.toString, "3.1415");
		XCTAssertTrue(theIrrationalInterval == IrrationalInterval(3.1415));

		XCTAssertTrue(theIrrationalInterval < IrrationalInterval(4.0));
		XCTAssertTrue(theIrrationalInterval < 4);
		XCTAssertTrue(theIrrationalInterval <= IrrationalInterval(3.1415));
		XCTAssertTrue(theIrrationalInterval <= IrrationalInterval(4.0));

		XCTAssertTrue(theIrrationalInterval > IrrationalInterval(2.0));
		XCTAssertTrue(theIrrationalInterval > 2);
		XCTAssertTrue(theIrrationalInterval >= IrrationalInterval(3.1415));
		XCTAssertEqual(theIrrationalInterval * 2, IrrationalInterval(3.1415*2.0));
		var		a = theIrrationalInterval;
		a *= 2
		XCTAssertEqual(a, IrrationalInterval(3.1415*2.0));
	}

	func testEqualTemperamentInterval() {
		let		theEqualTemperamentInterval	= EqualTemperamentInterval( degree: 7, names: ["5th"] );
		XCTAssertEqual(theEqualTemperamentInterval.toDouble, 1.498307076876682, accuracy: 0.000001);
		XCTAssertEqual(theEqualTemperamentInterval.toString, "2^7/12");
		XCTAssertTrue(theEqualTemperamentInterval == EqualTemperamentInterval( degree: 7, names: ["5th"] ));
		XCTAssertEqual(theEqualTemperamentInterval.degree,7);
		XCTAssertEqual(theEqualTemperamentInterval.steps,12);
		XCTAssertEqual(theEqualTemperamentInterval.interval,RationalInterval(2));

		XCTAssertTrue(theEqualTemperamentInterval < EqualTemperamentInterval( degree: 9, names: ["6th"] ));
		XCTAssertTrue(theEqualTemperamentInterval < 2);
		XCTAssertTrue(theEqualTemperamentInterval <= EqualTemperamentInterval( degree: 9, names: ["6th"] ));
		XCTAssertTrue(theEqualTemperamentInterval <= EqualTemperamentInterval( degree: 7, names: ["5th"] ));

		XCTAssertTrue(theEqualTemperamentInterval > EqualTemperamentInterval( degree: 6, names: ["4th"] ));
		XCTAssertTrue(theEqualTemperamentInterval > 1);
		XCTAssertTrue(theEqualTemperamentInterval >= EqualTemperamentInterval( degree: 6, names: ["4th"] ));
	}


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
