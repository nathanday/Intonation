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

		XCTAssertEqual(Rational(3,7).signum(), 1);
		XCTAssertEqual(Rational().signum(), 0);
		XCTAssertEqual(Rational(-3,7).signum(), -1);

		XCTAssertEqual(Rational.abs(Rational(3,7)), Rational(3,7));
		XCTAssertEqual(Rational.abs(Rational(-3,7)), Rational(3,7));

		XCTAssert(Rational(-3,7).isSignMinus);
		XCTAssertEqual(Rational(3,7).isSignMinus, false);
		XCTAssert(Rational.one.isFinite);
		XCTAssert(Rational.infinity.isInfinite);
		XCTAssert(Rational.nan.isNaN);
		XCTAssert(Rational.zero.isZero);

		var		a3 = Rational(3,7);
		a3.addProduct(Rational(2,3), Rational(5,2))
		XCTAssertEqual(a3, Rational(44,21));

		XCTAssertEqual(Rational.sum([Rational(3,2),Rational(4,3),Rational(5,4),Rational(6,5)] ), Rational(317,60));
	}

	func testConvert() {
		XCTAssertEqual(Rational(2,1).toCents, 1200.000, accuracy: 0.001);
		XCTAssertEqual(Rational(3,2).toCents, 701.955, accuracy: 0.001);
		XCTAssertEqual(Rational(5,4).toCents, 386.31371386, accuracy: 0.001);
		XCTAssertEqual(Rational(1.189207115002721, maxDenominator:65536).toCents, 300.000, accuracy: 0.001);

		XCTAssertEqual(Rational(3,2).toDouble, 1.5, accuracy: 0.00001);
		XCTAssertEqual(Rational(3,2).toFloat, 1.5, accuracy: 0.00001);
		XCTAssertEqual(Rational(3,2).toInt, 1);

		XCTAssertEqual(3 as Rational, Rational(3));
		XCTAssertEqual((3.141592653589793 as Rational).toDouble, Rational.pi.toDouble, accuracy:0.00000000000001);
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

		XCTAssertEqual(Rational(7,2)>3, true);
		XCTAssertEqual(Rational(7,2)<3, false);
		XCTAssertEqual(Rational(1,2)<3, true);
		XCTAssertEqual(Rational(1,2)>3, false);

		XCTAssertEqual(Rational(7,2)>=3, true);
		XCTAssertEqual(Rational(7,2)<=3, false);
		XCTAssertEqual(Rational(1,2)<=3, true);
		XCTAssertEqual(Rational(1,2)>=3, false);

		XCTAssertEqual(Rational(7,3)>=2, true);
		XCTAssertEqual(Rational(3,7)<=3, true);

		XCTAssertEqual(Rational(3,1)==3, true);
		XCTAssertEqual(Rational(3,7)==3, false);
		XCTAssertEqual(Rational(3,7) != 3, true);
		XCTAssertEqual(Rational(3,1) != 3, false);
	}

	func testString() {
		let		theRational3_2 = Rational("3:2");
		XCTAssertNotEqual(theRational3_2, nil);
		XCTAssertEqual(theRational3_2!.numerator, 3);
		XCTAssertEqual(theRational3_2!.denominator, 2);

		XCTAssertEqual(Rational("a"), nil);

		XCTAssertEqual(Rational(3,7).toString, "3/7");
		XCTAssertEqual(Rational(3,1).toString, "3");
		XCTAssertEqual(Rational(3,7).ratioString, "3:7");

		XCTAssertEqual(Rational(3,7).description, Rational(3,7).toString);
		XCTAssertEqual(Rational(3,1).description, Rational(3,1).toString);

		XCTAssertEqual(Rational(3,7).debugDescription, "3∶7");

		XCTAssertEqual(Rational(18,20).factorsString, "3²∶2⨯5");
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
		XCTAssertEqual(Rational.min.toInt, Int.min);
		XCTAssertEqual(Rational.max.toInt, Int.max);
		XCTAssertEqual(Rational.nan.numerator, 0);
		XCTAssertEqual(Rational.nan.denominator, 0);
		XCTAssertEqual(Rational.infinity.numerator, 1);
		XCTAssertEqual(Rational.infinity.denominator, 0);
		XCTAssertEqual(Rational.pi.toDouble, 3.141592653589793, accuracy:0.00000000000001);
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
