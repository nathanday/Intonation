//
//  Rational_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 5/07/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class Rational_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreation() {
		let		theRationalZero = Rational();
		XCTAssertEqual(theRationalZero.numerator, 0);
		XCTAssertEqual(theRationalZero.denominator, 1);

		let		theRational3_10 = Rational( 3, 10);
		XCTAssertEqual(theRational3_10.numerator, 3);
		XCTAssertEqual(theRational3_10.denominator, 10);

		let		theRational5_4 = Rational(1.75, maxDenominator:100);
		XCTAssertEqual(theRational5_4.numerator, 7);
		XCTAssertEqual(theRational5_4.denominator, 4);

		let		theRational_5_4 = Rational(-1.75, maxDenominator:100);
		XCTAssertEqual(theRational_5_4.numerator, -7);
		XCTAssertEqual(theRational_5_4.denominator, 4);

		let		theRationalF5_4 = Rational(Float(1.75), maxDenominator:100);
		XCTAssertEqual(theRationalF5_4.numerator, 7);
		XCTAssertEqual(theRationalF5_4.denominator, 4);

		let		theRational_F5_4 = Rational(Float(-1.75), maxDenominator:100);
		XCTAssertEqual(theRational_F5_4.numerator, -7);
		XCTAssertEqual(theRational_F5_4.denominator, 4);

		let		theRational2_10 = Rational( 2, 10);
		XCTAssertEqual(theRational2_10.numerator, 1);
		XCTAssertEqual(theRational2_10.denominator, 5);

		XCTAssertEqual(Rational(Rational(2,3)), Rational(2,3));

	}

	func testMath() {
		XCTAssertEqual(Rational(1,2)*Rational(3,7), Rational(3,14));
		XCTAssertEqual(Rational(1,2)/Rational(3,7), Rational(7,6));
		XCTAssertEqual(Rational(3,7)+Rational(1,2), Rational(13,14));
		XCTAssertEqual(Rational(3,7)-Rational(1,2), Rational(-1,14));

		XCTAssertEqual(Rational(1,2)*7, Rational(7,2));
		XCTAssertEqual(Rational(1,2)/7, Rational(1,14));
		XCTAssertEqual(Rational(3,7)+2, Rational(17,7));
		XCTAssertEqual(Rational(3,7)-2, Rational(-11,7));

		var		a = Rational(1,2);
		a *= Rational(3,7);
		XCTAssertEqual(a, Rational(3,14));

		var		b = Rational(1,2);
		b /= Rational(3,7);
		XCTAssertEqual(b, Rational(7,6));

		var		c = Rational(3,7);
		c += Rational(1,2);
		XCTAssertEqual(c, Rational(13,14));

		var		d = Rational(3,7);
		d -= Rational(1,2);
		XCTAssertEqual(d, Rational(-1,14));

		var		a2 = Rational(1,2);
		a2 *= 7;
		XCTAssertEqual(a2, Rational(7,2));

		var		b2 = Rational(1,2);
		b2 /= 7;
		XCTAssertEqual(b2, Rational(1,14));

		var		c2 = Rational(3,7);
		c2 += 2;
		XCTAssertEqual(c2, Rational(17,7));

		var		d2 = Rational(3,7);
		d2 -= 2;
		XCTAssertEqual(d2, Rational(-11,7));

		XCTAssertEqual(-Rational(3,7), Rational(-3,7));

		var		e = Rational(3,7);
		e.negate();
		XCTAssertEqual(e, Rational(-3,7));

		XCTAssertEqual(Rational(3,7).numeratorForDenominator(21), 9);

		XCTAssertEqual((-Rational(3,7)).magnitude, Rational(3,7));
		XCTAssertEqual(-Rational(3,7), Rational(-3,7));
		XCTAssertEqual(+Rational(3,7), Rational(3,7));

		XCTAssertEqual(Rational(3,7).signum(), Rational.one);
		XCTAssertEqual(Rational.zero.signum(), Rational.zero);

		XCTAssertEqual(Rational(-3,7).signum(), Rational(-1));
		XCTAssertEqual(Rational(-3,7).numerator, -3);
		XCTAssertEqual(Rational(-3,7).denominator, 7);

		XCTAssertEqual(Rational(3,-7).signum(), Rational(-1));
		XCTAssertEqual(Rational(3,-7).numerator, -3);
		XCTAssertEqual(Rational(3,-7).denominator, 7);

		XCTAssertEqual(Rational(-3,-7).signum(), Rational.one);
		XCTAssertEqual(Rational(-3,-7).numerator, 3);
		XCTAssertEqual(Rational(-3,-7).denominator, 7);

		XCTAssertEqual(abs(Rational(3,7)), Rational(3,7));
		XCTAssertEqual(abs(Rational(-3,7)), Rational(3,7));

		XCTAssertEqual(-Rational.one, Rational(-1));
		XCTAssertEqual(+Rational.one, Rational(1));

		XCTAssert(Rational.one.isFinite);
		XCTAssert(Rational.infinity.isInfinite);
		XCTAssert(Rational.nan.isNaN);
		XCTAssert(Rational.zero.isZero);

		XCTAssertEqual(Rational(5,3).reciprocal(), Rational(3,5));
	}

	func testConvert() {
		XCTAssertEqual(Double(Rational(3,2)), 1.5, accuracy: 0.00001);
		XCTAssertEqual(Float(Rational(3,2)), 1.5, accuracy: 0.00001);
		XCTAssertEqual(Int(Rational(3,2)), 1);

		XCTAssertEqual(3 as Rational, Rational(3));
		XCTAssertEqual(Double(3.141592653589793 as Rational), 3.141592653589793, accuracy:0.000000000000001 );

		XCTAssertEqual(Double(Rational(0.2)), 0.2, accuracy: 0.001);

		let		r1 : Rational = 2;
		XCTAssertEqual(r1, Rational(2,1));

		let		r2 : Rational = 3.25;
		XCTAssertEqual(r2, Rational(13,4));

		XCTAssertEqual(Rational(exactly:UInt8(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:Int8(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:UInt16(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:Int16(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:UInt32(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:Int32(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:UInt64(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:Int64(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:UInt(12)), Rational(12,1));
		XCTAssertEqual(Rational(exactly:Int(12)), Rational(12,1));
	}

	func testCompare() {
		XCTAssertEqual(Rational(1,2)>Rational(3,7), true);
		XCTAssertEqual(Rational(3,7)<Rational(1,2), true);
		XCTAssertEqual(Rational(1,2)<Rational(3,7), false);
		XCTAssertEqual(Rational(3,7)>Rational(1,2), false);

		XCTAssertEqual(Rational(1,2)>=Rational(3,7), true);
		XCTAssertEqual(Rational(3,7)>=Rational(1,2), false);
		XCTAssertEqual(Rational(3,7)<=Rational(1,2), true);
		XCTAssertEqual(Rational(1,2)<=Rational(3,7), false);

		XCTAssertEqual(Rational(3,7)>=Rational(3,7), true);
		XCTAssertEqual(Rational(3,7)<=Rational(3,7), true);

		XCTAssertEqual(Rational(3,7)==Rational(9,21), true);
		XCTAssertEqual(Rational(3,7)==Rational(9,20), false);
		XCTAssertEqual(Rational(3,7) != Rational(9,20), true);
		XCTAssertEqual(Rational(3,7) != Rational(9,21), false);
	}

	func testStride() {
		let		a = Rational(4,5);
		let		s = a.distance(to: Rational(1));
		XCTAssertEqual(s,Rational(1,5));
		XCTAssertEqual(a.advanced(by: s),Rational(1));
		XCTAssertEqual(a.advanced(by: s).advanced(by: s),Rational(6,5));
	}

	func testString() {
		let		theRational3_2 = Rational("3:2");
		XCTAssertNotEqual(theRational3_2, nil);
		XCTAssertEqual(theRational3_2!.numerator, 3);
		XCTAssertEqual(theRational3_2!.denominator, 2);
		let		theRational1_2 = Rational("1/2");
		XCTAssertNotEqual(theRational1_2, nil);
		XCTAssertEqual(theRational1_2!.numerator, 1);
		XCTAssertEqual(theRational1_2!.denominator, 2);
		let		theRational5 = Rational("5");
		XCTAssertNotEqual(theRational5, nil);
		XCTAssertEqual(theRational5!.numerator, 5);
		XCTAssertEqual(theRational5!.denominator, 1);

		XCTAssertEqual(Rational("5:3:2"), nil);
		XCTAssertEqual(Rational("a"), nil);

		XCTAssertEqual(String(Rational(3,7)), "3/7");
		XCTAssertEqual(String(Rational(3,1)), "3");
		XCTAssertEqual(Rational(3,7).ratioString, "3:7");

		XCTAssertEqual(Rational(3,7).description, String(Rational(3,7)));
		XCTAssertEqual(Rational(3,1).description, String(Rational(3,1)));

		XCTAssertEqual(Rational(3,7).debugDescription, "{numerator=3,denominator=7}");
	}

	func testHash() {
		var		theHasher = Hasher();
		var		theHasher2 = Hasher();
		let		r = Rational(2,3);
		theHasher.combine(2);
		theHasher.combine(3);
		r.hash(into: &theHasher2 );
		XCTAssertEqual(theHasher.finalize(), theHasher2.finalize() );
	}

	func testValues() {
		XCTAssertEqual(Rational.zero, Rational(0,1));
		XCTAssertEqual(Rational.one, Rational(1,1));
		XCTAssertEqual(Rational.min, Rational(Int.min));
		XCTAssertEqual(Rational.max, Rational(Int.max));
		XCTAssertEqual(Rational.nan.numerator, 0);
		XCTAssertEqual(Rational.nan.denominator, 0);
		XCTAssertEqual(Rational.infinity.numerator, 1);
		XCTAssertEqual(Rational.infinity.denominator, 0);
#if arch(x86_64) || arch(arm64)
		XCTAssertEqual(Double(Rational.pi), Double.pi, accuracy:0.00000000000001);
#else
		XCTAssertEqual(Float(Rational.pi), Float.pi, accuracy:0.00005);
#endif
	}

	func testNaN() {
		let		a = Rational.nan;
		XCTAssertFalse(a == Rational.nan);
		XCTAssertFalse(a == Rational(0,0));
		XCTAssertFalse(a < Rational.one);
		XCTAssertFalse(a > Rational.one);
		XCTAssertTrue(a.isNaN);
		XCTAssertFalse(a.isInfinite);
		XCTAssertFalse(a.isInfinite);
		XCTAssertFalse(a.isInteger);
		XCTAssertFalse(a.isZero);
		XCTAssertFalse(Rational(3,2).isNaN);
	}

	func testInfinity() {
		let		a = Rational.infinity;
		let		b = -a;
		XCTAssertTrue( a == Rational.infinity );
		XCTAssertFalse( a == -Rational.infinity );
		XCTAssertFalse( a == Rational.one );
		XCTAssertTrue( a == Rational(1,0) );
		XCTAssertTrue( a == Rational(100,0) );
		XCTAssertTrue( a.isInfinite );
		XCTAssertFalse( a.isNaN );
		XCTAssertFalse( a.isFinite );
		XCTAssertFalse(a.isInteger);
		XCTAssertFalse(a.isZero);

		XCTAssertTrue( b == -Rational.infinity );
		XCTAssertFalse( b == Rational.infinity );
		XCTAssertFalse( b == -Rational.one );
		XCTAssertTrue( b == Rational(-1,0) );
		XCTAssertTrue( b == Rational(-100,0) );
		XCTAssertTrue( b.isInfinite );
		XCTAssertFalse( b.isNaN );
		XCTAssertFalse( b.isFinite );
		XCTAssertFalse( b.isInteger );
		XCTAssertFalse( b.isZero );
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
