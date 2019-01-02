//
//  HarmonicsDescription_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 13/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class HarmonicsDescription_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testSine() {
		let		theHarmonicsDescription = HarmonicsDescription(amount: 0.0, evenAmount: 1.0);
		XCTAssertEqual(theHarmonicsDescription.amount, 0.0);
		XCTAssertEqual(theHarmonicsDescription.evenAmount, 1.0);
		XCTAssertEqual(theHarmonicsDescription.count, 1);
		theHarmonicsDescription.enumerateHarmonics { (anHarmonic: Int, anAmplitude: Float32) in
			if anHarmonic == 1 {
				XCTAssertEqual( anAmplitude, Float32(1.0), accuracy: 0.00001 );
			} else {
				XCTAssertEqual( anAmplitude, 0.0, accuracy: 0.00001 );
			}
		}
	}

	func testSaw() {
		let		theHarmonicsDescription = HarmonicsDescription(amount: 1.0, evenAmount: 1.0);
		XCTAssertEqual(theHarmonicsDescription.amount, 1.0);
		XCTAssertEqual(theHarmonicsDescription.evenAmount, 1.0);
		XCTAssert(theHarmonicsDescription.count > 50 );
		theHarmonicsDescription.enumerateHarmonics { (anHarmonic: Int, anAmplitude: Float32) in
			XCTAssertEqual( anAmplitude, Float32(1.0)/Float32(anHarmonic), accuracy: 0.00001 );
		}
	}

	func testSquare() {
		let		theHarmonicsDescription = HarmonicsDescription(amount: 1.0, evenAmount: 0.0);
//		XCTAssertEqual(theHarmonicsDescription.amount, 0.85);
		XCTAssertEqual(theHarmonicsDescription.evenAmount, 0.0);
		XCTAssert(theHarmonicsDescription.count > 50 );
		theHarmonicsDescription.enumerateHarmonics { (anHarmonic: Int, anAmplitude: Float32) in
			if anHarmonic%2 == 1 {
				XCTAssertEqual( anAmplitude, Float32(1.0)/Float32(anHarmonic), accuracy: 0.00001 );
			} else {
				XCTAssertEqual( anAmplitude, 0.0, accuracy: 0.00001 );
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
