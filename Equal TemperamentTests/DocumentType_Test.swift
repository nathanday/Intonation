//
//  DocumentType_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 13/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class DocumentType_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPropertyList() {
		guard let theLimitsIntervalsData = DocumentType.instance(fromPropertyList: [
			"documentType":"limits",
			"limits":[ "numeratorPrime":5,
					   "denominatorPrime":3,
					   "oddLimit":17,
					   "additiveDissonance":31]]) else {
						XCTFail();
						return;
		}

		XCTAssertTrue( theLimitsIntervalsData is LimitsIntervalsData );

		guard let theStackedIntervalsIntervalsData = DocumentType.instance(fromPropertyList: [
			"documentType":"stackedIntervals",
			"stackedIntervals":[ ["interval":"3:2","steps":4,"octaves":7],["interval":"4:3","steps":3,"octaves":7] ]
			]) else {
						XCTFail();
						return;
		}

		XCTAssertTrue( theStackedIntervalsIntervalsData is StackedIntervalsIntervalsData );

		guard let theEqualTemperamentIntervalsData = DocumentType.instance(fromPropertyList: [
			"documentType":"equalTemperament",
			"equalTemperament":["degrees":12,"interval":"2:1"]
			]) else {
						XCTFail();
						return;
		}

		XCTAssertTrue( theEqualTemperamentIntervalsData is EqualTemperamentIntervalsData );

		guard let theHarmonicSeriesIntervalsData = DocumentType.instance(fromPropertyList: [
			"documentType":"harmonicSeries",
			"harmonicSeries" : ["octave":4]
			]) else {
						XCTFail();
						return;
		}

		XCTAssertTrue( theHarmonicSeriesIntervalsData is HarmonicSeriesIntervalsData );

		guard let thePresetIntervalsData = DocumentType.instance(fromPropertyList: [
			"documentType":"preset",
			"preset" : ["name":"dummy name"]
			]) else {
				XCTFail();
				return;
		}

		XCTAssertTrue( thePresetIntervalsData is PresetIntervalsData );

		guard let theAdHocIntervalsData = DocumentType.instance(fromPropertyList: [
			"documentType":"adHoc",
			"adHoc" : ["1","5:4","1.51111", "2"]
			]) else {
				XCTFail();
				return;
		}

		XCTAssertTrue( theAdHocIntervalsData is AdHocIntervalsData );
	}

	func testDefault() {
		XCTAssertTrue( DocumentType.limits.instance() is LimitsIntervalsData );
		XCTAssertTrue( DocumentType.stackedIntervals.instance() is StackedIntervalsIntervalsData );
		XCTAssertTrue( DocumentType.equalTemperament.instance() is EqualTemperamentIntervalsData );
		XCTAssertTrue( DocumentType.harmonicSeries.instance() is HarmonicSeriesIntervalsData );
		XCTAssertTrue( DocumentType.preset.instance() is PresetIntervalsData );
		XCTAssertTrue( DocumentType.adHoc.instance() is AdHocIntervalsData );
	}

	func testBasic() {
		XCTAssertEqual( DocumentType.limits.title, "Limits");
		XCTAssertEqual( DocumentType.stackedIntervals.title, "Stacked Intervals");
		XCTAssertEqual( DocumentType.equalTemperament.title, "Equal Temperament");
		XCTAssertEqual( DocumentType.harmonicSeries.title, "Natural Harmonic Series");
		XCTAssertEqual( DocumentType.preset.title, "Preset");
		XCTAssertEqual( DocumentType.adHoc.title, "AdHoc");

		XCTAssertEqual( DocumentType.limits.toString(), "limits" );
		XCTAssertEqual( DocumentType.stackedIntervals.toString(), "stackedIntervals" );
		XCTAssertEqual( DocumentType.equalTemperament.toString(), "harmonicSeries" );
		XCTAssertEqual( DocumentType.harmonicSeries.toString(), "equalTemperament" );
		XCTAssertEqual( DocumentType.preset.toString(), "preset" );
		XCTAssertEqual( DocumentType.adHoc.toString(), "adHoc" );
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
