//
//  PrimesSequence_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 13/10/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class PrimesSequence_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPrimesSequenceSubscript() {
		let thePrimesSequence = PrimesSequence();
		XCTAssertEqual( thePrimesSequence[0], 2 );
		XCTAssertEqual( thePrimesSequence[1], 3 );
		XCTAssertEqual( thePrimesSequence[2], 5 );
		XCTAssertEqual( thePrimesSequence[3], 7 );
		XCTAssertEqual( thePrimesSequence[4], 11 );
		XCTAssertEqual( thePrimesSequence[5], 13 );
		XCTAssertEqual( thePrimesSequence[6], 17 );
		XCTAssertEqual( thePrimesSequence[7], 19 );
		XCTAssertEqual( thePrimesSequence[8], 23 );
		XCTAssertEqual( thePrimesSequence[9], 29 );
		XCTAssertEqual( thePrimesSequence[10], 31 );
		XCTAssertEqual( thePrimesSequence[11], 37 );
		XCTAssertEqual( thePrimesSequence[12], 41 );
		XCTAssertEqual( thePrimesSequence[13], 43 );
		XCTAssertEqual( thePrimesSequence[14], 47 );
		XCTAssertEqual( thePrimesSequence[15], 53 );
		XCTAssertEqual( thePrimesSequence[16], 59 );
		XCTAssertEqual( thePrimesSequence[17], 61 );
		XCTAssertEqual( thePrimesSequence[18], 67 );
		XCTAssertEqual( thePrimesSequence[19], 71 );
		XCTAssertEqual( thePrimesSequence[20], 73 );
		XCTAssertEqual( thePrimesSequence[21], 79 );
		XCTAssertEqual( thePrimesSequence[22], 83 );
		XCTAssertEqual( thePrimesSequence[23], 89 );
		XCTAssertEqual( thePrimesSequence[24], 97 );
    }

	func testPrimesSequenceEnumeration() {
		var i = 0;
		for x in PrimesSequence(end: 127) {
			switch i {
			case 0: XCTAssertEqual( x, 2 );
			case 1: XCTAssertEqual( x, 3 );
			case 2: XCTAssertEqual( x, 5 );
			case 3: XCTAssertEqual( x, 7 );
			case 4: XCTAssertEqual( x, 11 );
			case 5: XCTAssertEqual( x, 13 );
			case 6: XCTAssertEqual( x, 17 );
			case 7: XCTAssertEqual( x, 19 );
			case 8: XCTAssertEqual( x, 23 );
			case 9: XCTAssertEqual( x, 29 );
			case 10: XCTAssertEqual( x, 31 );
			case 11: XCTAssertEqual( x, 37 );
			case 12: XCTAssertEqual( x, 41 );
			case 13: XCTAssertEqual( x, 43 );
			case 14: XCTAssertEqual( x, 47 );
			case 15: XCTAssertEqual( x, 53 );
			case 16: XCTAssertEqual( x, 59 );
			case 17: XCTAssertEqual( x, 61 );
			case 18: XCTAssertEqual( x, 67 );
			case 19: XCTAssertEqual( x, 71 );
			case 20: XCTAssertEqual( x, 73 );
			case 21: XCTAssertEqual( x, 79 );
			case 22: XCTAssertEqual( x, 83 );
			case 23: XCTAssertEqual( x, 89 );
			case 24: XCTAssertEqual( x, 97 );
			case 25: XCTAssertEqual( x, 101 );
			case 26: XCTAssertEqual( x, 103 );
			case 27: XCTAssertEqual( x, 107 );
			case 28: XCTAssertEqual( x, 109 );
			case 29: XCTAssertEqual( x, 113 );
			case 30: XCTAssertEqual( x, 127 );
			default: XCTFail();
			}
			i += 1;
		}
		XCTAssertEqual( i, 31 )
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
