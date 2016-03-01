/*
    Rational.swift
    Equal Temperament

    Created by Nathan Day on 7/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Foundation

struct Rational : CustomStringConvertible, CustomDebugStringConvertible, Hashable
{
	let	numerator:		Int;
	let	denominator:	Int;
	var toDouble:		Double { return Double(numerator)/Double(denominator); }
	var toFloat:		Float { return Float(numerator)/Float(denominator); }
	var toInt:			Int { return numerator/denominator; }

	init() {
		numerator = 0;
		denominator = 1;
	}
	init( _ aRational:Rational) {
		numerator = aRational.numerator;
		denominator = aRational.denominator;
	}
    init( _ aNumerator: Int, _ aDenominator: Int) {
		let		theNumerator = aDenominator < 0 ? -aNumerator : aNumerator;
		let		theDenominator = abs(aDenominator);
        let theCommonDivisor = greatestCommonDivisor(theNumerator, theDenominator);
        numerator = theNumerator/theCommonDivisor;
        denominator = theDenominator/theCommonDivisor;
    }

	func numeratorForDenominator( aDenominator: Int ) -> Int? {
		return aDenominator != 0 && aDenominator%denominator == 0 ? numerator*(aDenominator/denominator) : nil;
	}

	var toString: String { return "\(numerator)\\\(denominator)"; }
	var ratioString: String { return "\(numerator)∶\(denominator)"; }

	var hashValue: Int { return Int(numerator)^Int(denominator); }
	var description: String { return toString; }

	var debugDescription: String {
		return "\(numerator)∶\(denominator)";
	}
	var factorsString : String {
		return "\(UInt(numerator).factorsString)∶\(UInt(denominator).factorsString)";
	}
}

enum Ratio {
	case irrational(Double);
	case rational(Rational);
	var toDouble : Double {
		switch self {
		case .irrational( let x ):
			return x;
		case .rational( let x ):
			return x.toDouble;
		}
	}
	var toString : String {
		switch self {
		case .irrational( let x ):
			return "\(x)";
		case .rational( let x ):
			return "\(x.numerator)∶\(x.denominator)";
		}
	}
	var isRational : Bool {
		switch self {
		case .irrational:
			return false;
		case .rational:
			return true;
		}
	}
}

extension Rational : ArrayLiteralConvertible, IntegerLiteralConvertible, FloatLiteralConvertible
{
	static func convertFromArrayLiteral( anElements: Int...) -> Rational {
		var     theNumerator : Int! = nil;
		var     theDenominator : Int! = nil;
		for theElement in anElements {
			if theNumerator == nil { theNumerator = theElement; }
			else if theDenominator == nil { theDenominator = theElement; }
			else { NSException(name: NSRangeException, reason: "Too many arguments", userInfo: nil).raise(); }
		}
		if( theNumerator == nil || theDenominator == nil ) { NSException(name: NSRangeException, reason: "Too few arguments", userInfo: nil).raise(); }
		return Rational( theNumerator, theDenominator );
	}

	static func convertFromIntegerLiteral(aValue: IntegerLiteralType) -> Rational { return Rational( Int(aValue), 1 ); }

	init( arrayLiteral elements: Int...) {
		self.init( elements[0], elements[1] );
	}
	init(integerLiteral aNumerator:Int) {
		numerator = aNumerator;
		denominator = 1;
	}
	init(floatLiteral aValue: FloatLiteralType) { self.init( Int(aValue*65535.0),Int(65535) ); }
	static func convertFromFloatLiteral(aValue: FloatLiteralType) -> Rational { return Rational( Int(aValue), 1 ); }
}

extension Rational : FloatingPointType, Equatable, SignedNumberType
{
	typealias _BitsType = (Int,Int);
	static func _fromBitPattern(aBits: _BitsType) -> Rational { return Rational(aBits.0,aBits.1); }
	func _toBitPattern() -> _BitsType { return (numerator,denominator); }

	init(_ aValue: UInt8) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: Int8) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: UInt16) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: Int16) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: UInt32) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: Int32) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: UInt64) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: Int64) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: UInt) {
		numerator = Int(aValue);
		denominator = 1;
	}

	init(_ aValue: Int) {
		numerator = Int(aValue);
		denominator = 1;
	}

	static private func farey( aValue: Double, maxDenominator aMaxDenom: UInt ) -> (numerator:Int,denominator:Int) {
		func _farey( x: Double, _ M: UInt ) -> (numerator:Int,denominator:Int) {
			var		a = (0,1);
			var		b = (1,1);
			while( a.1 <= Int(M) && b.1 <= Int(M) ) {
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

			if( a.1 > Int(M) ) {
				return b;
			}
			else {
				return a;
			}
		}
		let		theInt = Int(aValue);
		var		theResult = _farey( fabs(aValue-Double(theInt)), aMaxDenom );
		if( theInt < 0 ) {
			theResult.numerator = -theResult.numerator;
		}
		theResult.numerator += theInt*theResult.denominator;
		return theResult;
	}

	init(_ aValue: Double, maxDenominator aMaxDenom: UInt ) {
		(numerator,denominator) = Rational.farey( aValue, maxDenominator:aMaxDenom );
	}

	init(_ aValue: Float, maxDenominator aMaxDenom: UInt ) {
		(numerator,denominator) = Rational.farey( Double(aValue), maxDenominator:aMaxDenom );
	}

	static var infinity: Rational { return Rational(1,0); }

	static var NaN: Rational { return Rational(0,0); }
	static var quietNaN: Rational { return Rational(0,0); }

	var floatingPointClass: FloatingPointClassification { return toDouble.floatingPointClass; }
	var isSignMinus: Bool { return (numerator < 0) != (denominator < 0); }
	var isNormal: Bool { return numerator != 0 && denominator != 0; }
	var isFinite: Bool { return denominator != 0; }
	var isZero: Bool { return numerator == 0 && denominator != 0; }
	var isSubnormal: Bool { return toDouble.isSubnormal; }
	var isInfinite: Bool { return numerator != 0 && denominator == 0; }
	var isNaN: Bool { return numerator == 0 && denominator == 0; }
	var isSignaling: Bool { return toDouble.isSignaling; }

	typealias Stride = Rational
	func distanceTo(anOther: Rational) -> Stride { return self - anOther; }
	func advancedBy(anOther: Stride) -> Rational { return self + anOther; }
}

extension String {
	func toRational() -> Rational? {
		var		theResult : Rational? = nil;
		let		theComponents = componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ":/"));
		switch theComponents.count {
		case 0:
			theResult = Rational();
		case 1:
			if let theInt = Int(theComponents[0]) {
				theResult = Rational( theInt );
			}
		default:
			if let theNum = Int(theComponents[0]), theDenom = Int(theComponents[0]) {
				theResult = Rational( theNum, theDenom );
			}
		}
		return theResult;
	}
}

func + (a: Rational, b: Rational) -> Rational { return Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator); }
func - (a: Rational, b: Rational) -> Rational { return Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator); }
func * (a: Rational, b: Rational) -> Rational { return Rational(a.numerator*b.numerator,a.denominator*b.denominator); }

func / (a: Rational, b: Rational) -> Rational {
	return b.numerator >= 0
		? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
		: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
}
prefix func - (a: Rational) -> Rational { return Rational(-a.numerator,a.denominator); }

func + (a: Rational, b: Int) -> Rational { return Rational(a.numerator+b*a.denominator,a.denominator); }
func - (a: Rational, b: Int) -> Rational { return Rational(a.numerator-b*a.denominator,a.denominator); }
func * (a: Rational, b: Int) -> Rational { return Rational(a.numerator*b,a.denominator); }

func / (a: Rational, b: Int) -> Rational {
	return b >= 0
		? Rational(a.numerator,a.denominator*b)
		: Rational(-a.numerator,-a.denominator*b);
}

func sum( anArray: [Rational] ) -> Rational {
	var			theResultNum = 0,
				theResultDen = 1;
	for theTerm in anArray {
		theResultNum = theResultNum*theTerm.denominator+theTerm.numerator*theResultDen;
		theResultDen *= theTerm.denominator
	}
	return Rational( theResultNum, theResultDen );
}

func == (a: Rational, b: Rational) -> Bool { return a.numerator==b.numerator && a.denominator == b.denominator; }
func != (a: Rational, b: Rational) -> Bool { return a.numerator != b.numerator || a.denominator != b.denominator; }
func < (a: Rational, b: Rational) -> Bool { 	return a.numerator*b.denominator < b.numerator*a.denominator; }
func <= (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator <= b.numerator*a.denominator; }
func > (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator > b.numerator*a.denominator; }
func >= (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator >= b.numerator*a.denominator; }


func == (a: Rational, b: Int) -> Bool { return a.numerator == b && a.denominator == 1; }
func != (a: Rational, b: Int) -> Bool { return a.numerator != b || a.denominator == 1; }
func < (a: Rational, b: Int) -> Bool { 	return a.numerator < b*a.denominator; }
func <= (a: Rational, b: Int) -> Bool { return a.numerator <= b*a.denominator; }
func > (a: Rational, b: Int) -> Bool { return a.numerator > b*a.denominator; }
func >= (a: Rational, b: Int) -> Bool { return a.numerator >= b*a.denominator; }

