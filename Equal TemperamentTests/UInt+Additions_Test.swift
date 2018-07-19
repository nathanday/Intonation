//
//  UInt+Additions_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 7/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class UInt_Additions_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPow() {
		var		theValue : Int64 = 1;
		for x in UInt64(0)...UInt64(26) {
			XCTAssertEqual(pow(Int64(2),x), theValue, "Passed saturationComponent" );
			theValue *= 2;
		}
    }

	func testLog2() {
		let tests = [(v:9,r:3), (v:8,r:3), (v:87,r:6), (v:82,r:6), (v:891,r:9), (v:128,r:7),
					 (v:1388,r:10), (v:8644,r:13), (v:63455,r:15), (v:49041,r:15), (v:120692,r:16),
					 (v:351535,r:18), (v:9074518,r:23), (v:9188348,r:23), (v:87363902,r:26), (v:98594908,r:26),
					 (v:183824824,r:27), (v:190170315,r:27), (v:5482018156,r:32), (v:7555629521,r:32)];
		for t in tests {
			XCTAssertEqual( log2(UInt(t.v)), UInt(t.r), "log2(\(t.v)) != \(t.r)" );
		}
	}

	func testLog10() {
		let tests = [(v:9,r:0), (v:8,r:0), (v:87,r:1), (v:82,r:1), (v:891,r:2), (v:128,r:2),
					 (v:1388,r:3), (v:8644,r:3), (v:63455,r:4), (v:49041,r:4), (v:120692,r:5),
					 (v:351535,r:5), (v:9074518,r:6), (v:9188348,r:6), (v:87363902,r:7), (v:98594908,r:7),
					 (v:183824824,r:8), (v:190170315,r:8), (v:5482018156,r:9), (v:7555629521,r:9)];
		for t in tests {
			XCTAssertEqual( log10(UInt(t.v)), UInt(t.r), "log10(\(t.v)) != \(t.r)" );
		}
	}

	func testBitCount() {
		let tests = [(v:0b1011011001,r:6), (v:0b110111101,r:7)];
		for t in tests {
			XCTAssertEqual( bitCount(UInt(t.v)), t.r, "bitCount(\(t.v)) != \(t.r)" );
		}
	}

	func testGreatestCommonDivisor() {
		let tests = [
			(a:7817*4157*3137, b:3823*2467*3137, gcd:3137),
			(a:5197*1523*7589*431, b:743*2339*7589*431, gcd:7589*431),
			(a:5981*1447*2621, b:1061*887*4519*2621, gcd:2621),
			(a:3673*4457*4519*5449*421, b:4099*4519*1171*5449*421, gcd:5449*421*4519),
			(a:6263*6857*853*5807, b:5443*7103*853*5807, gcd:853*5807),
			(a:6581*2683*6691*6007, b:5749*7607*6691*6007, gcd:6691*6007),
			(a:1063*7489*2383*3347, b:2797*5749*2383*3347, gcd:2383*3347),
			(a:7187*6221*5189, b:677*5231*5189, gcd:5189),
			(a:3607*2389*7741, b:503*6217*7741, gcd:7741),
			(a:1301*1423*6053*3853, b:2557*3187*6053*3853, gcd:6053*3853),
			(a:7411*7151*1019, b:7589*6911*1019, gcd:1019),
			(a:5581*4133*6047*2543*11, b:6551*4673*6047*2543*11, gcd:6047*2543*11),
			(a:5591*1931*1933*7307*283, b:2957*1931*1933*7307*283, gcd:1931*1933*7307*283),
			(a:1699*2381*911*4561, b:2861*6863*911*4561, gcd:911*4561),
			(a:743*6073*167*2591, b:7027*2549*167*2591, gcd:167*2591),
			(a:3931*4931*4637*2273, b:6917*3259*4637*2273, gcd:4637*2273),
			(a:4567*7477*3137*769, b:317*5477*3137*769, gcd:3137*769),
			(a:6991*6971*7127*3557, b:2551*4133*7127*3557, gcd:7127*3557),
			(a:1259*4243*4801*6257, b:733*1931*4801*6257, gcd:4801*6257)
		];
		for (i,t) in tests.enumerated() {
			let		r = greatestCommonDivisor(UInt(t.a), UInt(t.b));
			XCTAssertEqual( r, UInt(t.gcd), "\(i) - greatest common divisor of \(t.a) and \(t.b)) is \(t.gcd) not \(r)" );
		}
		XCTAssertEqual( greatestCommonDivisor([UInt(3673*4457*4519*5449*421), UInt(4099*4519*1171*5449*421), UInt(2551*5449*421*4519)] ), 10366717051 );
	}

	func testRational() {
		XCTAssertEqual(Rational(2,1).toCents, 1200.000, accuracy: 0.001);
		XCTAssertEqual(Rational(3,2).toCents, 701.955, accuracy: 0.001);
		XCTAssertEqual(Rational(5,4).toCents, 386.31371386, accuracy: 0.001);
		XCTAssertEqual(Rational(1.189207115002721, maxDenominator:65536).toCents, 300.000, accuracy: 0.001);

		XCTAssertEqual(Rational(18,20).factorsString, "3²∶2⨯5");
	}

	func testPrimes() {

		XCTAssertEqual( UInt(1259*4243*4801*6257).largestPrimeFactor, 6257 );
//		XCTAssertEqual( UInt(6257+1).largestPrimeLessThanOrEqualTo, 6257 );
		
	}
}
