//
//  IntervalSet_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 11/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class IntervalSet_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	func testIntervalSet() {
		let		theMajorScale = Scale.major;
		XCTAssertEqual(theMajorScale.name,"major");
		XCTAssertEqual(theMajorScale.everyInterval,[RationalInterval(1,1),RationalInterval(9,8),RationalInterval(5,4),RationalInterval(4,3),RationalInterval(3,2),RationalInterval(5,3),RationalInterval(15,8)]);
		XCTAssertEqual(theMajorScale.indexOf(RationalInterval(1,1)),0);
		XCTAssertEqual(theMajorScale.indexOf(RationalInterval(9,8)),1);
		XCTAssertEqual(theMajorScale.indexOf(RationalInterval(5,4)),2);
		XCTAssertEqual(theMajorScale.indexOf(RationalInterval(4,3)),3);
		XCTAssertEqual(theMajorScale.indexOf(RationalInterval(3,2)),4);
		XCTAssertEqual(theMajorScale.indexOf(RationalInterval(5,3)),5);
		XCTAssertEqual(theMajorScale.indexOf(RationalInterval(15,8)),6);

		XCTAssertEqual(theMajorScale[0],RationalInterval(1,1));
		XCTAssertEqual(theMajorScale[1],RationalInterval(9,8));
		XCTAssertEqual(theMajorScale[2],RationalInterval(5,4));
		XCTAssertEqual(theMajorScale[3],RationalInterval(4,3));
		XCTAssertEqual(theMajorScale[4],RationalInterval(3,2));
		XCTAssertEqual(theMajorScale[5],RationalInterval(5,3));
		XCTAssertEqual(theMajorScale[6],RationalInterval(15,8));

		var		theIndex = 0;
		for theInterval in theMajorScale {
			switch(theIndex) {
			case 0: XCTAssertEqual(theInterval,RationalInterval(1,1));
			case 1: XCTAssertEqual(theInterval,RationalInterval(9,8));
			case 2: XCTAssertEqual(theInterval,RationalInterval(5,4));
			case 3: XCTAssertEqual(theInterval,RationalInterval(4,3));
			case 4: XCTAssertEqual(theInterval,RationalInterval(3,2));
			case 5: XCTAssertEqual(theInterval,RationalInterval(5,3));
			case 6: XCTAssertEqual(theInterval,RationalInterval(15,8));
			default: XCTFail()
			}
			theIndex += 1;
		}

		XCTAssertEqual( theMajorScale.interval(closestTo:0.999), RationalInterval(1,1) );
		XCTAssertEqual( theMajorScale.interval(closestTo:1.124), RationalInterval(9,8) );
		XCTAssertEqual( theMajorScale.interval(closestTo:1.24), RationalInterval(5,4) );
		XCTAssertEqual( theMajorScale.interval(closestTo:1.333), RationalInterval(4,3) );
		XCTAssertEqual( theMajorScale.interval(closestTo:1.45), RationalInterval(3,2) );
		XCTAssertEqual( theMajorScale.interval(closestTo:1.666), RationalInterval(5,3) );
		XCTAssertEqual( theMajorScale.interval(closestTo:1.87), RationalInterval(15,8) );
	}

    func testScale() {
		guard let theScale = Scale(propertyList: ["name":"Test Scale",
												  "everyInterval":[
													["names":["One"],"numerator":1,"denominator":1],
													["names":["Two"],"numerator":5,"denominator":4],
													["names":["Three"],"ratio":1.5]]]) else {
			XCTFail();
			return;
		}
		XCTAssertEqual(theScale.name,"Test Scale");
		XCTAssertEqual(theScale.everyInterval,[RationalInterval(1), RationalInterval(5,4), IrrationalInterval(1.5)]);
    }

	func testRationalStackedIntervalSet() {
		let theStackedIntervalSet = StackedIntervalSet( interval : RationalInterval(3,2), steps: 5, octaves: 12 );
		XCTAssertEqual(theStackedIntervalSet.name,"3:2");
		XCTAssertEqual(theStackedIntervalSet.everyInterval, [RationalInterval(1,1), RationalInterval(3,2), RationalInterval(9,8), RationalInterval(27,16), RationalInterval(81,64)]);
		XCTAssertTrue(theStackedIntervalSet.contains(RationalInterval(3,2)));
		XCTAssertFalse(theStackedIntervalSet.contains(IrrationalInterval(1.55)));
		XCTAssertFalse(theStackedIntervalSet.contains(RationalInterval(5,4)));
		//		XCTAssertEqual(theStackedIntervalSet.propertyList, ["interval":"3:2","steps":5,"octaves":12] as [String : Any] );
	}

	func testIrrationalStackedIntervalSet() {
		let theStackedIntervalSet = StackedIntervalSet( interval : IrrationalInterval(1.49), steps: 5, octaves: 12 );
		XCTAssertEqual(theStackedIntervalSet.name,"1.49000");
		XCTAssertEqual(theStackedIntervalSet.everyInterval, [IrrationalInterval(1.0), IrrationalInterval(1.49), IrrationalInterval(1.11005), IrrationalInterval(1.6539745), IrrationalInterval(1.2322110025)]);
		XCTAssertTrue(theStackedIntervalSet.contains(IrrationalInterval(1.2322110025)));
		XCTAssertTrue(theStackedIntervalSet.contains(IrrationalInterval(1.49)));
		//		XCTAssertEqual(theStackedIntervalSet.propertyList, ["interval":"3:2","steps":5,"octaves":12] as [String : Any] );
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
