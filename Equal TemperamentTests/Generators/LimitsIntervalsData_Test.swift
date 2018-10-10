//
//  LimitsIntervalsData_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 9/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class LimitsIntervalsData_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFiveLimt() {
		guard let theLimitsIntervalsData = LimitsIntervalsData(propertyList:[
			"limits":[ "numeratorPrime":5,
					   "oddLimit":51,
					   "additiveDissonance":80]]) else {
						XCTFail();
						return;
		}
		XCTAssertEqual( theLimitsIntervalsData.documentType, .limits );
		XCTAssertEqual( theLimitsIntervalsData.numeratorPrimeLimit, UInt(5) );
		XCTAssertEqual( theLimitsIntervalsData.denominatorPrimeLimit, UInt(5) );
		XCTAssertFalse( theLimitsIntervalsData.separatePrimeLimit );
		XCTAssertEqual( theLimitsIntervalsData.oddLimit, UInt(51) );
		XCTAssertEqual( theLimitsIntervalsData.additiveDissonance, UInt(80) );

		let		theGenerator = theLimitsIntervalsData.intervalsDataGenerator( );
//		let		theSmallestErrorEntries = theGenerator.smallestError;
//		let		theBiggestErrorEntries = theGenerator.biggestError;
//		let		theAverageError = theGenerator.averageError;
		let		theEveryInterval = theGenerator.everyEntry;
		XCTAssertEqual( theEveryInterval.count,  26);

		XCTAssertEqual( (theEveryInterval[0].interval as! RationalInterval).ratio, Rational(1) );
		XCTAssertEqual( (theEveryInterval[1].interval as! RationalInterval).ratio, Rational(25,24) );
		XCTAssertEqual( (theEveryInterval[2].interval as! RationalInterval).ratio, Rational(16,15) );
		XCTAssertEqual( (theEveryInterval[3].interval as! RationalInterval).ratio, Rational(27, 25) );
		XCTAssertEqual( (theEveryInterval[4].interval as! RationalInterval).ratio, Rational(10, 9) );
		XCTAssertEqual( (theEveryInterval[5].interval as! RationalInterval).ratio, Rational(9, 8) );
		XCTAssertEqual( (theEveryInterval[6].interval as! RationalInterval).ratio, Rational(32, 27) );
		XCTAssertEqual( (theEveryInterval[7].interval as! RationalInterval).ratio, Rational(6, 5) );
		XCTAssertEqual( (theEveryInterval[8].interval as! RationalInterval).ratio, Rational(5, 4) );
		XCTAssertEqual( (theEveryInterval[9].interval as! RationalInterval).ratio, Rational(32, 25) );
		XCTAssertEqual( (theEveryInterval[10].interval as! RationalInterval).ratio, Rational(4, 3) );
		XCTAssertEqual( (theEveryInterval[11].interval as! RationalInterval).ratio, Rational(27, 20) );
		XCTAssertEqual( (theEveryInterval[12].interval as! RationalInterval).ratio, Rational(25, 18) );
		XCTAssertEqual( (theEveryInterval[13].interval as! RationalInterval).ratio, Rational(45, 32) );
		XCTAssertEqual( (theEveryInterval[14].interval as! RationalInterval).ratio, Rational(36, 25) );
		XCTAssertEqual( (theEveryInterval[15].interval as! RationalInterval).ratio, Rational(40, 27) );
		XCTAssertEqual( (theEveryInterval[16].interval as! RationalInterval).ratio, Rational(3, 2) );
		XCTAssertEqual( (theEveryInterval[17].interval as! RationalInterval).ratio, Rational(25, 16) );
		XCTAssertEqual( (theEveryInterval[18].interval as! RationalInterval).ratio, Rational(8, 5) );
		XCTAssertEqual( (theEveryInterval[19].interval as! RationalInterval).ratio, Rational(5, 3) );
		XCTAssertEqual( (theEveryInterval[20].interval as! RationalInterval).ratio, Rational(27, 16) );
		XCTAssertEqual( (theEveryInterval[21].interval as! RationalInterval).ratio, Rational(16, 9) );
		XCTAssertEqual( (theEveryInterval[22].interval as! RationalInterval).ratio, Rational(9, 5) );
		XCTAssertEqual( (theEveryInterval[23].interval as! RationalInterval).ratio, Rational(50, 27) );
		XCTAssertEqual( (theEveryInterval[24].interval as! RationalInterval).ratio, Rational(15, 8) );
		XCTAssertEqual( (theEveryInterval[25].interval as! RationalInterval).ratio, Rational(48, 25) );
    }

	func testSevenLimt() {
		guard let theLimitsIntervalsData = LimitsIntervalsData(propertyList:[
			"limits":[ "numeratorPrime":7,
					   "oddLimit":17,
					   "additiveDissonance":31]]) else {
						XCTFail();
						return;
		}
		XCTAssertEqual( theLimitsIntervalsData.documentType, .limits );
		XCTAssertEqual( theLimitsIntervalsData.numeratorPrimeLimit, UInt(7) );
		XCTAssertEqual( theLimitsIntervalsData.denominatorPrimeLimit, UInt(7) );
		XCTAssertFalse( theLimitsIntervalsData.separatePrimeLimit );
		XCTAssertEqual( theLimitsIntervalsData.oddLimit, UInt(17) );
		XCTAssertEqual( theLimitsIntervalsData.additiveDissonance, UInt(31) );

		let		theGenerator = theLimitsIntervalsData.intervalsDataGenerator( );
		//		let		theSmallestErrorEntries = theGenerator.smallestError;
		//		let		theBiggestErrorEntries = theGenerator.biggestError;
		//		let		theAverageError = theGenerator.averageError;
		let		theEveryInterval = theGenerator.everyEntry;
		XCTAssertEqual( theEveryInterval.count,  22);

		XCTAssertEqual( (theEveryInterval[0].interval as! RationalInterval).ratio, Rational(1) );
		XCTAssertEqual( (theEveryInterval[1].interval as! RationalInterval).ratio, Rational(16, 15) );
		XCTAssertEqual( (theEveryInterval[2].interval as! RationalInterval).ratio, Rational(15, 14) );
		XCTAssertEqual( (theEveryInterval[3].interval as! RationalInterval).ratio, Rational(10, 9) );
		XCTAssertEqual( (theEveryInterval[4].interval as! RationalInterval).ratio, Rational(9, 8) );
		XCTAssertEqual( (theEveryInterval[5].interval as! RationalInterval).ratio, Rational(8, 7) );
		XCTAssertEqual( (theEveryInterval[6].interval as! RationalInterval).ratio, Rational(7, 6) );
		XCTAssertEqual( (theEveryInterval[7].interval as! RationalInterval).ratio, Rational(6, 5) );
		XCTAssertEqual( (theEveryInterval[8].interval as! RationalInterval).ratio, Rational(5, 4) );
		XCTAssertEqual( (theEveryInterval[9].interval as! RationalInterval).ratio, Rational(9, 7) );
		XCTAssertEqual( (theEveryInterval[10].interval as! RationalInterval).ratio, Rational(4, 3) );
		XCTAssertEqual( (theEveryInterval[11].interval as! RationalInterval).ratio, Rational(7, 5) );
		XCTAssertEqual( (theEveryInterval[12].interval as! RationalInterval).ratio, Rational(10, 7) );
		XCTAssertEqual( (theEveryInterval[13].interval as! RationalInterval).ratio, Rational(3, 2) );
		XCTAssertEqual( (theEveryInterval[14].interval as! RationalInterval).ratio, Rational(14, 9) );
		XCTAssertEqual( (theEveryInterval[15].interval as! RationalInterval).ratio, Rational(8, 5) );
		XCTAssertEqual( (theEveryInterval[16].interval as! RationalInterval).ratio, Rational(5, 3) );
		XCTAssertEqual( (theEveryInterval[17].interval as! RationalInterval).ratio, Rational(12, 7) );
		XCTAssertEqual( (theEveryInterval[18].interval as! RationalInterval).ratio, Rational(7, 4) );
		XCTAssertEqual( (theEveryInterval[19].interval as! RationalInterval).ratio, Rational(16, 9) );
		XCTAssertEqual( (theEveryInterval[20].interval as! RationalInterval).ratio, Rational(9, 5) );
		XCTAssertEqual( (theEveryInterval[21].interval as! RationalInterval).ratio, Rational(15, 8) );
	}

	func testFiveThreeLimt() {
		guard let theLimitsIntervalsData = LimitsIntervalsData(propertyList:[
			"limits":[ "numeratorPrime":5,
					   "denominatorPrime":3,
					   "oddLimit":17,
					   "additiveDissonance":31]]) else {
						XCTFail();
						return;
		}
		XCTAssertEqual( theLimitsIntervalsData.documentType, .limits );
		XCTAssertEqual( theLimitsIntervalsData.numeratorPrimeLimit, UInt(5) );
		XCTAssertEqual( theLimitsIntervalsData.denominatorPrimeLimit, UInt(3) );
		XCTAssertTrue( theLimitsIntervalsData.separatePrimeLimit );
		XCTAssertEqual( theLimitsIntervalsData.oddLimit, UInt(17) );
		XCTAssertEqual( theLimitsIntervalsData.additiveDissonance, UInt(31) );

		let		theGenerator = theLimitsIntervalsData.intervalsDataGenerator( );
		//		let		theSmallestErrorEntries = theGenerator.smallestError;
		//		let		theBiggestErrorEntries = theGenerator.biggestError;
		//		let		theAverageError = theGenerator.averageError;
		let		theEveryInterval = theGenerator.everyEntry;
		XCTAssertEqual( theEveryInterval.count,  9);

		XCTAssertEqual( (theEveryInterval[0].interval as! RationalInterval).ratio, Rational(1) );
		XCTAssertEqual( (theEveryInterval[1].interval as! RationalInterval).ratio, Rational(10, 9) );
		XCTAssertEqual( (theEveryInterval[2].interval as! RationalInterval).ratio, Rational(9, 8) );
		XCTAssertEqual( (theEveryInterval[3].interval as! RationalInterval).ratio, Rational(5, 4) );
		XCTAssertEqual( (theEveryInterval[4].interval as! RationalInterval).ratio, Rational(4, 3) );
		XCTAssertEqual( (theEveryInterval[5].interval as! RationalInterval).ratio, Rational(3, 2) );
		XCTAssertEqual( (theEveryInterval[6].interval as! RationalInterval).ratio, Rational(5, 3) );
		XCTAssertEqual( (theEveryInterval[7].interval as! RationalInterval).ratio, Rational(16, 9) );
		XCTAssertEqual( (theEveryInterval[8].interval as! RationalInterval).ratio, Rational(15, 8) );
	}

   func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
