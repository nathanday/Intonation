//
//  Oscillator_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 18/12/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class Oscillator_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testSineWave() {
		let		theOscillator = Oscillator(harmonicsDescription: HarmonicsDescription(amount: 0.0, evenAmount: 1.0));
		let		theMult = 2.0*Float32.pi/Float32(theOscillator.values.count);
		for (anIndex,aValue) in theOscillator.values.enumerated() {
			let		x = Float32(anIndex)*theMult;
			XCTAssertEqual( aValue, sin(x), accuracy: 0.00001, "values[\(anIndex)] = \(aValue) != \(sin(x))" );
		}
	}

	func testSawToothWave() {
		let		theOscillator = Oscillator(harmonicsDescription: HarmonicsDescription(amount: 1.0, evenAmount: 1.0));
		let		theMult = 2.0*Float32.pi/Float32(theOscillator.values.count);
		for (anIndex,aValue) in theOscillator.values.enumerated() {
			let		x = Float32(anIndex)*theMult;
			var		y = Float32(0.0);
			for i in 1...32 {
				y += 1.0/Float32(i)*sin(Float32(i)*x);
			}
			XCTAssertEqual( aValue, y, accuracy: 0.0001, "values[\(anIndex)] = \(aValue) != \(sin(x))" );
		}
	}

    func testPerformanceSawToothWave() {
		let			theHarmonicsDescription = HarmonicsDescription(amount: 1.0, evenAmount: 1.0);
        self.measure {
			let		_ = Oscillator(harmonicsDescription: theHarmonicsDescription);
        }
    }

}
