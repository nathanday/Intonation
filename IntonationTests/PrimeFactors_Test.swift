//
//  PrimeFactors_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 29/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class PrimeFactors_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testIntegers() {
		for theValue in 3...1000 {
			var		theCalculate = 1;
			for theFactor in PrimeFactors(value:UInt(theValue)) {
				theCalculate *= Int(pow(theFactor.factor,UInt(theFactor.power)));
			}
			XCTAssertEqual( theValue, theCalculate );
		}
    }

	func testRationals() {
		for theNum in stride(from: 7, to: 200, by: 16) {
			for theDenom in stride(from: 8, to: 200, by: 17) {
				var		theCalculate = (numerator:1,denominator:1);
				for theFactor in PrimeFactors.factors(numerator: theNum, denominator: theDenom) {
					if theFactor.power > 0 {
						theCalculate.numerator *= Int(pow(theFactor.factor,UInt(theFactor.power)));
					} else if theFactor.power < 0 {
						theCalculate.denominator *= Int(pow(theFactor.factor,UInt(-theFactor.power)));
					}
				}
				XCTAssertEqual( Double(theNum)/Double(theDenom), Double(theCalculate.numerator)/Double(theCalculate.denominator), "\(theNum)/\(theDenom) != \(theCalculate.numerator)/\(theCalculate.denominator)" );
			}
		}
	}

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {

//            // Put the code you want to measure the time of here.
//        }
//    }

}
