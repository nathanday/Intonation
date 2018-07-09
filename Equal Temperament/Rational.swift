/*
    Rational.swift
    Intonation

    Created by Nathan Day on 7/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Foundation

struct Rational : CustomStringConvertible, CustomDebugStringConvertible, Hashable, RationalNumeric {

	internal(set) var	numerator:		Int;
	internal(set) var	denominator:	Int;

	private init(numerator aNum: Int,denominator aDen: Int) {
		numerator = aNum;
		denominator = aDen;
	}
	init() {
		self.init(numerator:0,denominator:1);
	}
	init( _ aRational:Rational) {
		self.init(numerator:aRational.numerator,denominator:aRational.denominator);
	}
    init( _ aNumerator: Int, _ aDenominator: Int) {
		let		theNumerator = aDenominator < 0 ? -aNumerator : aNumerator;
		let		theDenominator = aDenominator.magnitude;
		let		theCommonDivisor = greatestCommonDivisor(UInt(labs(theNumerator)), theDenominator);
		self.init(numerator:theNumerator/Int(theCommonDivisor),denominator:Int(theDenominator)/Int(theCommonDivisor));
    }
	init?( _ aString: String ) {
		let		theComponents = aString.components(separatedBy: CharacterSet(charactersIn: ":/∶"));
		let		theDenom = theComponents.count > 1 ? Int( theComponents[1] ) : 1;
		if let theNum = Int(theComponents[0]) {
			self.init( theNum, theDenom ?? 1 );
		} else {
			return nil;
		}
	}
	init( _ aTuple: (numerator:Int,denominator:Int) ) {
		self.init(aTuple.numerator,aTuple.denominator);
	}

	func numeratorForDenominator( _ aDenominator: Int ) -> Int? {
		return aDenominator != 0 && aDenominator%denominator == 0 ? numerator*(aDenominator/denominator) : nil;
	}

	var toString: String {
		return denominator != 1 ? "\(numerator)/\(denominator)" : "\(numerator)";
	}
	var ratioString: String { return "\(numerator):\(denominator)"; }

	func hash(into aHasher: inout Hasher) {
		aHasher.combine(numerator)
		aHasher.combine(denominator)
	}
	var description: String { return toString; }

	var debugDescription: String {
		return "\(numerator)∶\(denominator)";
	}
	var factorsString : String {
		return "\(UInt(numerator).factorsString)∶\(UInt(denominator).factorsString)";
	}
	static func farey( _ aValue: Double, maxDenominator aMaxDenom: Int, maxError aMaxError: Double = 0.0 ) -> (numerator:Int,denominator:Int) {
		func _farey( _ x: Double, _ M: Int, _ E:Double ) -> (numerator:Int,denominator:Int) {
			var		a = (0,1);
			var		b = (1,1);
			while a.1 <= M && b.1 <= M {
				let		theMediant = Double(a.0+b.0)/Double(a.1+b.1);
				if x == theMediant {
					if a.1 + b.1 <= Int(M) {
						return (a.0+b.0, a.1+b.1)
					}
					else if b.1 > a.1 {
						return b;
					}
					else {
						return a;
					}
				}
				else if x > theMediant {
					a = (a.0+b.0,a.1+b.1);
				}
				else {
					b = (a.0+b.0,a.1+b.1);
				}
			}

			if( a.1 > M ) {
				return b;
			}
			else {
				return a;
			}
		}
		let		theInt = Int(aValue);
		var		theResult = _farey( fabs(aValue-Double(theInt)), aMaxDenom, aMaxError );
		if( theInt < 0 ) {
			theResult.numerator = -theResult.numerator;
		}
		theResult.numerator += theInt*theResult.denominator;
		return theResult;
	}

	init(_ aValue: Double, maxDenominator aMaxDenom: Int ) {
		let		r = Rational.farey( aValue, maxDenominator:aMaxDenom )
		self.init(numerator:r.numerator,denominator:r.denominator);
	}

	init(_ aValue: Float, maxDenominator aMaxDenom: Int ) {
		let		r = Rational.farey( Double(aValue), maxDenominator:aMaxDenom )
		self.init(numerator:r.numerator,denominator:r.denominator);
	}

	typealias Stride = Rational
	typealias Magnitude = Rational;

	func distance(to anOther: Rational) -> Stride {
		return self - anOther;
	}
	func advanced(by anOther: Stride) -> Rational {
		return self + anOther;
	}

	init?<T>(exactly aSource: T) where T : BinaryInteger {
		self.init(numerator:Int(aSource),denominator:1);
	}

	var magnitude: Magnitude {
		return numerator < 0 ? Rational(-numerator,denominator) : self;
	}

	func signum() -> Int { return numerator.signum(); }

	static func * (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.numerator,a.denominator*b.denominator);
	}

	static func *= (a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.numerator,a.denominator*b.denominator);
	}

	static prefix func + (a: Rational) -> Rational {
		return a;
	}
	static func + (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator);
	}
	static func += ( a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator);
	}

	static func - (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator);
	}
	static func -= ( a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator);
	}

	static func == (a: Rational, b: Rational) -> Bool {
		return a.numerator==b.numerator && a.denominator == b.denominator;
	}
	static func != (a: Rational, b: Rational) -> Bool {
		return a.numerator != b.numerator || a.denominator != b.denominator;
	}
	static func < (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator < b.numerator*a.denominator;
	}
	static func <= (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator <= b.numerator*a.denominator;
	}
	static func > (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator > b.numerator*a.denominator;
	}
	static func >= (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator >= b.numerator*a.denominator;
	}

	public mutating func negate() {
		numerator = -numerator;
	}

	var					toCents:		Double { return toDouble.toCents; }
	/*
	RationalNumeric
	*/
	var toDouble:		Double { return Double(numerator)/Double(denominator); }
	var toFloat:		Float { return Float(numerator)/Float(denominator); }
	var toInt:			Int { return numerator/denominator; }

	static var zero : Rational { return Rational(numerator:0,denominator:1); }
	static var one : Rational { return Rational(numerator:1,denominator:1); }
	static var min : Rational { return Rational(numerator:Int.min,denominator:1); }
	static var max : Rational { return Rational(numerator:Int.max,denominator:1); }
	static var nan: Rational { return Rational(numerator:0,denominator:0); }
	static var infinity: Rational { return Rational(numerator:1,denominator:0); }
	static var pi: Rational {
		#if arch(x86_64) || arch(arm64)
		return Rational(numerator:7244019458077122842,denominator:2305843009213693951);
		#else
		return Rational(numerator:1686629713,denominator:536870912);
		#endif
	}

	static func abs(_ x: Rational) -> Rational {
		return (x.numerator < 0) != (x.denominator < 0) ? -x : x;
	}

	static func == (a: Rational, b: Int) -> Bool { return a.numerator == b && a.denominator == 1; }
	static func != (a: Rational, b: Int) -> Bool { return a.numerator != b || a.denominator != 1; }
	static func < (a: Rational, b: Int) -> Bool { 	return a.numerator < b*a.denominator; }
	static func <= (a: Rational, b: Int) -> Bool { return a.numerator <= b*a.denominator; }
	static func > (a: Rational, b: Int) -> Bool { return a.numerator > b*a.denominator; }
	static func >= (a: Rational, b: Int) -> Bool { return a.numerator >= b*a.denominator; }

	static func / (a: Rational, b: Rational) -> Rational {
		return b.numerator >= 0
			? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
			: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
	}
	static prefix func - (a: Rational) -> Rational { return Rational(numerator:-a.numerator,denominator:a.denominator); }

	static func /= ( a: inout Rational, b: Rational) {
		a = b.numerator >= 0
			? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
			: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
	}

	var isSignMinus: Bool { return (numerator < 0) != (denominator < 0); }

	static func + (a: Rational, b: Int) -> Rational { return Rational(a.numerator+b*a.denominator,a.denominator); }
	static func - (a: Rational, b: Int) -> Rational { return Rational(a.numerator-b*a.denominator,a.denominator); }
	static func * (a: Rational, b: Int) -> Rational { return Rational(a.numerator*b,a.denominator); }

	static func / (a: Rational, b: Int) -> Rational {
		return b >= 0
			? Rational(a.numerator,a.denominator*b)
			: Rational(-a.numerator,-a.denominator*b);
	}

	static func += ( a: inout Rational, b: Int) { a = Rational(a.numerator+b*a.denominator,a.denominator); }
	static func -= ( a: inout Rational, b: Int) { a = Rational(a.numerator-b*a.denominator,a.denominator); }
	static func *= ( a: inout Rational, b: Int) { a = Rational(a.numerator*b,a.denominator); }

	static func /= ( a: inout Rational, b: Int) {
		a = b >= 0
			? Rational(a.numerator,a.denominator*b)
			: Rational(-a.numerator,-a.denominator*b);
	}

	/*
	addProduct should hanlde overflow better
	*/
	public mutating func addProduct(_ l: Rational, _ r: Rational) {
		let	theNumerator = numerator*l.denominator*r.denominator + denominator*l.numerator*r.numerator;
		let	theDenominator = denominator*l.denominator*r.denominator;
		let		theCommonDivisor = greatestCommonDivisor(UInt(labs(theNumerator)), UInt(theDenominator));
		numerator = theNumerator/Int(theCommonDivisor)
		denominator = Int(theDenominator)/Int(theCommonDivisor);
	}

	/*
	sum should hanlde overflow better
	*/
	static func sum( _ anArray: [Rational] ) -> Rational {
		var			theResultNum = 0,
		theResultDen = 1;
		for theTerm in anArray {
			theResultNum = theResultNum*theTerm.denominator+theTerm.numerator*theResultDen;
			theResultDen *= theTerm.denominator
		}
		return Rational( theResultNum, theResultDen );
	}

	var isFinite: Bool { return denominator != 0; }
	var isZero: Bool { return numerator == 0 && denominator != 0; }
	var isInfinite: Bool { return denominator == 0; }
	var isNaN: Bool { return numerator == 0 && denominator == 0; }
}


extension Rational : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
	static func convertFromIntegerLiteral( aValue: IntegerLiteralType) -> Rational { return Rational( Int(aValue), 1 ); }

	init(integerLiteral aNumerator:Int) {
		self.init( numerator:aNumerator, denominator:1 );
	}
	init(floatLiteral aValue: FloatLiteralType) {
		self.init( aValue, maxDenominator:Int.max );
	}
	static func convertFromFloatLiteral( aValue: FloatLiteralType) -> Rational {
		return Rational( aValue, maxDenominator:Int.max );
	}

	init(_ aValue: UInt8) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: Int8) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: UInt16) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: Int16) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: UInt32) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: Int32) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: UInt64) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: Int64) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: UInt) { self.init(numerator:Int(aValue),denominator:1); }
	init(_ aValue: Int) { self.init(numerator:Int(aValue),denominator:1); }
}

extension String {
	func toRational() -> Rational? {
		var		theResult : Rational? = nil;
		let		theComponents = components(separatedBy: CharacterSet(charactersIn: ":/"));
		switch theComponents.count {
		case 0:
			theResult = Rational();
		case 1:
			if let theInt = Int(theComponents[0]) {
				theResult = Rational( theInt, 1 );
			}
		default:
			if let theNum = Int(theComponents[0]),
				let theDenom = Int(theComponents[0]) {
				theResult = Rational( theNum, theDenom );
			}
		}
		return theResult;
	}
}


