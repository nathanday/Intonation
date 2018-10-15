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

	func testDefaultColors() {
		let		theColorInterpolation = ColorInterpolator();
		let		theColour1 = theColorInterpolation.values(at: 0.5)!;
		XCTAssertEqual(theColour1.hueComponent, 0.5, "Passed hueComponent" );
	}

	func testColorsArray() {
		let		theColorInterpolation = ColorInterpolator(colors: [NSColor(calibratedHue: 0.1, saturation: 0.5, brightness: 1.0, alpha: 1.0), NSColor(calibratedHue: 0.9, saturation: 1.0, brightness: 1.0, alpha: 1.0)]);
		let		theColour1 = theColorInterpolation.values(at: 0.5)!;
		XCTAssertEqual(theColour1.hueComponent, 0.5, "Passed hueComponent" );
		XCTAssertEqual(theColour1.saturationComponent, 0.75, "Passed saturationComponent" );
	}

	func testColorsAtArray() {
		let		theColorInterpolation = ColorInterpolator(points: [(x:0.1,color:NSColor(calibratedHue: 0.1, saturation: 0.5, brightness: 1.0, alpha: 1.0)), (x:0.9,color:NSColor(calibratedHue: 0.9, saturation: 1.0, brightness: 1.0, alpha: 1.0))]);
		let		theColour1 = theColorInterpolation.values(at: 0.5)!;
		XCTAssertEqual(theColour1.hueComponent, 0.5, "Passed hueComponent" );
		XCTAssertEqual(theColour1.saturationComponent, 0.75, "Passed saturationComponent" );
		XCTAssertEqual(theColorInterpolation.domainEnd!, CGFloat(0.9), "Passed domain end" );
	}

	func testNSColorValueResult() {
		let		theColors = [
			NSColor(deviceHue: 0.1, saturation: 1.0, brightness: 0.5, alpha: 1.0),
			NSColor(deviceHue: 0.9, saturation: 0.5, brightness: 1.0, alpha: 1.0)];
		let		theColorInterpolation = ColorInterpolator(colors: theColors);
		let		theColorInterpolation2 = ColorInterpolator(colors: []);
		let theColor = theColorInterpolation[0.5];
		XCTAssertNotNil(theColor, "Passed" );
		XCTAssertEqual(theColor!.hueComponent, CGFloat(0.5), "Passed" );
		XCTAssertEqual(theColor!.saturationComponent, CGFloat(0.75), "Passed" );
		XCTAssertEqual(theColor!.brightnessComponent, CGFloat(0.75), "Passed" );
		XCTAssertEqual(theColorInterpolation[1],theColors[1], "Passed" );
		XCTAssertNil(theColorInterpolation[3], "Passed" );
		XCTAssertNil(theColorInterpolation2.color(at:0.5), "Passed" );
		XCTAssertEqual(theColorInterpolation.color(at:0.5, alpha: 0.5)?.alphaComponent, 0.5, "Passed" );
	}
	func testRangeValueResult() {
		let		theColors = [
			NSColor(deviceHue: 0.0, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.1, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.2, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.3, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.4, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.6, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.7, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.8, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.9, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
		];
		let		theRange = 2...5;
		let		theColorInterpolation = ColorInterpolator(colors: theColors);
		XCTAssertEqual(theColorInterpolation[theRange], Array<NSColor>(theColors[theRange]), "Passed" );
	}

	func testEquality() {
		let		theColors = [
			NSColor(deviceHue: 0.0, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.1, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.2, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.3, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.4, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.6, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.7, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.8, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.9, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
		];
		let		theColorInterpolation = ColorInterpolator(colors: theColors);
		let		theColorInterpolation2 = ColorInterpolator(colors: theColors);
		let		theColorInterpolation3 = ColorInterpolator(colors: [
			NSColor(deviceHue: 0.0, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.1, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.2, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.3, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.4, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 1.0)]);
		let		theColorInterpolation4 = ColorInterpolator(colors: [
			NSColor(deviceHue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.6, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.7, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.8, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 0.9, saturation: 1.0, brightness: 1.0, alpha: 1.0),
			NSColor(deviceHue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)]);
		XCTAssertEqual(theColorInterpolation, theColorInterpolation2, "passed" );
		XCTAssertNotEqual(theColorInterpolation, theColorInterpolation3, "passed" );
		XCTAssertNotEqual(theColorInterpolation3, theColorInterpolation4, "passed" );
	}

	func testDescription() {
		let	theColorInterpolator = ColorInterpolator(hsbaPoints: [(0.0,1.0,1.0,1.0),(1.0,0.5,0.5,1.0)]);
		print(theColorInterpolator.description);
		XCTAssertEqual(theColorInterpolator.description, "[(x: 0.0, hueComponent: 1.0, saturationComponent: 1.0, brightnessComponent: 1.0), (x: 1.0, hueComponent: 0.5, saturationComponent: 0.5, brightnessComponent: 1.0)]", "passed" );
		XCTAssertEqual(theColorInterpolator.debugDescription, "<ColorInterpolator> [(x: 0.0, hueComponent: 1.0, saturationComponent: 1.0, brightnessComponent: 1.0), (x: 1.0, hueComponent: 0.5, saturationComponent: 0.5, brightnessComponent: 1.0)]", "passed" );
	}

	func testWithClosedHue() {
		let	theColorInterpolator = ColorInterpolator(hsbaPoints: [(0.0,1.0,1.0,1.0),(1.0,0.5,0.5,1.0)]);
		let	theColorInterpolator2 = theColorInterpolator.withClosedHue(false);
		XCTAssertNotEqual(theColorInterpolator, theColorInterpolator2, "passed" );
		XCTAssertEqual(theColorInterpolator, theColorInterpolator2.withClosedHue(true), "passed" );
	}
}
