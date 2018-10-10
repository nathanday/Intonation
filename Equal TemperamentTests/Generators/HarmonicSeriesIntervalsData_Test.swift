//
//  HarmonicSeriesIntervalsData_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 11/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class HarmonicSeriesIntervalsData_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNOctave() {
		for theOctaves in 3...8 {
			let		theHarmonics = 1<<(theOctaves-1);
			guard let theHarmonicSeriesIntervalsData = HarmonicSeriesIntervalsData(propertyList: ["harmonicSeries" : ["octave":theOctaves]]) else {
				XCTFail();
				return;
			}
			XCTAssertEqual( theHarmonicSeriesIntervalsData.documentType, .harmonicSeries );
			XCTAssertEqual( theHarmonicSeriesIntervalsData.octave, theOctaves );
			let		theGenerator = theHarmonicSeriesIntervalsData.intervalsDataGenerator( );
			let		theEveryInterval = theGenerator.everyEntry;
			XCTAssertEqual( theEveryInterval.count, theHarmonics + 1 );
			for i in 0..<theHarmonics {
				XCTAssertEqual( theEveryInterval[i], IntervalEntry(interval: RationalInterval(theHarmonics+i,theHarmonics)) );
			}
		}
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
