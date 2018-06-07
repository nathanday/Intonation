//
//  ColorInterpolator_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 6/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class ColorInterpolator_Test: XCTestCase {
    override func setUp() {
    }

    override func tearDown() {
    }

    func testCreation() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.5,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:1.5,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertEqual(theColorInterpolation[0]!.hueComponent, 0.0, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[0]!.saturationComponent, 0.0, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[0]!.brightnessComponent, 0.0, "Passed brightnessComponent" );
		XCTAssertEqual(theColorInterpolation[1]!.hueComponent, 1.0, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[1]!.saturationComponent, 0.75, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[1]!.brightnessComponent, 0.5, "Passed brightnessComponent" );
    }

	func testInterpolation() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.5,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:1.5,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertEqual(theColorInterpolation[1.0]!.hueComponent, 0.5*1.0, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[1.0]!.saturationComponent, 0.5*0.75, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[1.0]!.brightnessComponent, 0.5*0.5, "Passed brightnessComponent" );
	}

	func testInterpolation2() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.5,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:1.5,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertEqual(theColorInterpolation[0.75]!.hueComponent, 0.25*1.0, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[0.75]!.saturationComponent, 0.25*0.75, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[0.75]!.brightnessComponent, 0.25*0.5, "Passed brightnessComponent" );
	}

	func testInterpolationWrapAround1() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.0,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:5.0,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertEqual(theColorInterpolation[0.125+1.0*5.0]!.hueComponent, theColorInterpolation[0.125]!.hueComponent, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[0.125+1.0*5.0]!.saturationComponent, theColorInterpolation[0.125]!.saturationComponent, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[0.125+1.0*5.0]!.brightnessComponent, theColorInterpolation[0.125]!.brightnessComponent, "Passed brightnessComponent" );
	}
	func testInterpolationWrapAround2() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.0,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:5.0,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertEqual(theColorInterpolation[0.25+2.0*5.0]!.hueComponent, theColorInterpolation[0.25]!.hueComponent, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[0.25+2.0*5.0]!.saturationComponent, theColorInterpolation[0.25]!.saturationComponent, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[0.25+2.0*5.0]!.brightnessComponent, theColorInterpolation[0.25]!.brightnessComponent, "Passed brightnessComponent" );
	}
	func testInterpolationWrapAround3() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.0,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:5.0,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertEqual(theColorInterpolation[3.75+3.0*5.0]!.hueComponent, theColorInterpolation[3.75]!.hueComponent, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[3.75+3.0*5.0]!.saturationComponent, theColorInterpolation[3.75]!.saturationComponent, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[3.75+3.0*5.0]!.brightnessComponent, theColorInterpolation[3.75]!.brightnessComponent, "Passed brightnessComponent" );
	}
	func testInterpolationWrapAround4() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.0,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:5.0,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertNotEqual(theColorInterpolation[4.0+1.0*5.0]!.hueComponent, 0.0, "Passed hueComponent" );
		XCTAssertNotEqual(theColorInterpolation[4.0+1.0*5.0]!.saturationComponent, 0.0, "Passed saturationComponent" );
		XCTAssertNotEqual(theColorInterpolation[4.0+1.0*5.0]!.brightnessComponent, 0.0, "Passed brightnessComponent" );
	}
	func testInterpolationWrapAround5() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.0,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:5.0,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertEqual(theColorInterpolation[4.875+4.0*5.0]!.hueComponent, theColorInterpolation[4.875]!.hueComponent, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[4.875+4.0*5.0]!.saturationComponent, theColorInterpolation[4.875]!.saturationComponent, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[4.875+4.0*5.0]!.brightnessComponent, theColorInterpolation[4.875]!.brightnessComponent, "Passed brightnessComponent" );
	}

	func testInterpolationWrapAround6() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.5,hueComponent:0.0,saturationComponent:0.0,brightnessComponent:0.0),
			(x:1.5,hueComponent:1.0,saturationComponent:0.75,brightnessComponent:0.5)
			]);
		XCTAssertEqual(theColorInterpolation[0.75+1.0]!.hueComponent, 0.25*1.0, "Passed hueComponent" );
		XCTAssertEqual(theColorInterpolation[0.75+1.0]!.saturationComponent, 0.25*0.75, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation[0.75+1.0]!.brightnessComponent, 0.25*0.5, "Passed brightnessComponent" );
	}

	func testInterpolationWrapAround7() {
		let		theColorInterpolation = ColorInterpolator(hsbaPoints:[
			(x:0.0,hueComponent:0.0,saturationComponent:1.0,brightnessComponent:1.0),
			(x:0.5,hueComponent:0.5,saturationComponent:0.0,brightnessComponent:0.0),
			(x:1.0,hueComponent:1.0,saturationComponent:1.0,brightnessComponent:1.0),
			(x:2.0,hueComponent:2.0,saturationComponent:0.0,brightnessComponent:0.0)
			]);
		let		theColour1 = theColorInterpolation.values(at: 0.0)!;
		XCTAssertEqual(theColour1.hueComponent, 0.0, "Passed hueComponent" );
		XCTAssertEqual(theColour1.saturationComponent, 1.0, "Passed saturationComponent" );
		XCTAssertEqual(theColour1.brightnessComponent, 1.0, "Passed brightnessComponent" );

		let		theColour2 = theColorInterpolation.values(at: 0.5)!;
		XCTAssertEqual(theColour2.hueComponent, 0.5, "Passed hueComponent" );
		XCTAssertEqual(theColour2.saturationComponent, 0.0, "Passed saturationComponent" );
		XCTAssertEqual(theColour2.brightnessComponent, 0.0, "Passed brightnessComponent" );

		let		theColour3 = theColorInterpolation.values(at: 1.0)!;
		XCTAssertEqual(theColour3.hueComponent, 1.0, "Passed hueComponent" );
		XCTAssertEqual(theColour3.saturationComponent, 1.0, "Passed saturationComponent" );
		XCTAssertEqual(theColour3.brightnessComponent, 1.0, "Passed brightnessComponent" );
	}

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
