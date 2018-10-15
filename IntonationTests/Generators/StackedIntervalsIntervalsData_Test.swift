//
//  StackedIntervalsIntervalsData_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 10/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class StackedIntervalsIntervalsData_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testSingleInterval() {
		guard let theStackedIntervalsIntervalsData = StackedIntervalsIntervalsData(propertyList: [ "stackedIntervals":[ ["interval":"3:2","steps":5,"octaves":7] ] ])  else {
			XCTFail();
			return;
		}
		XCTAssertEqual( theStackedIntervalsIntervalsData.documentType, .stackedIntervals );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.count, 1 );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.interval, RationalInterval(3,2) );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.steps, 5 );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.octaves, 7 );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.everyInterval.count, 5 );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.everyInterval[0], RationalInterval(1, 1) );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.everyInterval[1], RationalInterval(3, 2) );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.everyInterval[2], RationalInterval(9, 8) );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.everyInterval[3], RationalInterval(27, 16) );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.first?.everyInterval[4], RationalInterval(81, 64) );

		let		theGenerator = theStackedIntervalsIntervalsData.intervalsDataGenerator( );
		let		theEveryInterval = theGenerator.everyEntry;
		XCTAssertEqual( theEveryInterval.count,  5);
		XCTAssertEqual( (theEveryInterval[0].interval as! RationalInterval).ratio, Rational(1) );
		XCTAssertEqual( (theEveryInterval[1].interval as! RationalInterval).ratio, Rational(9,8) );
		XCTAssertEqual( (theEveryInterval[2].interval as! RationalInterval).ratio, Rational(81,64) );
		XCTAssertEqual( (theEveryInterval[3].interval as! RationalInterval).ratio, Rational(3,2) );
		XCTAssertEqual( (theEveryInterval[4].interval as! RationalInterval).ratio, Rational(27,16) );
	}

	func testDoubleInterval() {
		guard let theStackedIntervalsIntervalsData = StackedIntervalsIntervalsData(propertyList: [ "stackedIntervals":[ ["interval":"3:2","steps":4,"octaves":7],["interval":"4:3","steps":3,"octaves":7] ] ])  else {
			XCTFail();
			return;
		}
		XCTAssertEqual( theStackedIntervalsIntervalsData.documentType, .stackedIntervals );
		XCTAssertEqual( theStackedIntervalsIntervalsData.stackedIntervals.count, 2 );
		for s in theStackedIntervalsIntervalsData.stackedIntervals {
			switch s.interval {
			case RationalInterval(3,2):
				XCTAssertEqual( s.steps, 4 );
				XCTAssertEqual( s.octaves, 7 );
				XCTAssertEqual( s.everyInterval.count, 4 );
				XCTAssertEqual( s.everyInterval[0], RationalInterval(1, 1) );
				XCTAssertEqual( s.everyInterval[1], RationalInterval(3, 2) );
				XCTAssertEqual( s.everyInterval[2], RationalInterval(9, 8) );
				XCTAssertEqual( s.everyInterval[3], RationalInterval(27, 16) );
			case RationalInterval(4,3):
				XCTAssertEqual( s.steps, 3 );
				XCTAssertEqual( s.octaves, 7 );
				XCTAssertEqual( s.everyInterval.count, 3 );
				XCTAssertEqual( s.everyInterval[0], RationalInterval(1, 1) );
				XCTAssertEqual( s.everyInterval[1], RationalInterval(4, 3) );
				XCTAssertEqual( s.everyInterval[2], RationalInterval(16, 9) );
			default:
				XCTFail();
			}
			let		theGenerator = theStackedIntervalsIntervalsData.intervalsDataGenerator( );
			let		theEveryInterval = theGenerator.everyEntry;
			XCTAssertEqual( theEveryInterval.count,  6);
			XCTAssertEqual( (theEveryInterval[0].interval as! RationalInterval).ratio, Rational(1) );
			XCTAssertEqual( (theEveryInterval[1].interval as! RationalInterval).ratio, Rational(9,8) );
			XCTAssertEqual( (theEveryInterval[2].interval as! RationalInterval).ratio, Rational(4,3) );
			XCTAssertEqual( (theEveryInterval[3].interval as! RationalInterval).ratio, Rational(3,2) );
			XCTAssertEqual( (theEveryInterval[4].interval as! RationalInterval).ratio, Rational(27,16) );
			XCTAssertEqual( (theEveryInterval[5].interval as! RationalInterval).ratio, Rational(16,9) );
		}
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
