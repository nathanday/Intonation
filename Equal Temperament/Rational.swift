/*
    Rational.swift
    Equal Temperament

    Created by Nathan Day on 7/06/14.
    Copyright (c) 2014 Nathan Day. All rights reserved.
 */

import Foundation

struct Rational : Printable, DebugPrintable, Hashable
{
	let	numerator:		Int;
	let	denominator:	Int;
	var toDouble:		Double { return Double(numerator)/Double(denominator); }
	var toFloat:		Float { return Float(numerator)/Float(denominator); }
	var toInt:			Int { return numerator/denominator; }

    init(var _ aNumerator:Int,var _ aDenominator:Int) {
        if( aDenominator < 0 ) {
            aNumerator = -aNumerator;
            aDenominator = -aDenominator;
        }
		
        let theCommonDivisor = greatestCommonDivisor(aNumerator, aDenominator);
        numerator = aNumerator/theCommonDivisor;
        denominator = aDenominator/theCommonDivisor;
    }

	var toString: String { return "\(numerator)\\\(denominator)"; }
	var ratioString: String { return "\(numerator):\(denominator)"; }
	
	var hashValue: Int { return Int(numerator)^Int(denominator); }
	var description: String { return toString; }

	var debugDescription: String {
		return "\(numerator):\(denominator)";
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
	init(var integerLiteral aNumerator:Int) {
		numerator = aNumerator;
		denominator = 1;
	}
	init(floatLiteral aValue: FloatLiteralType) { self.init( Int(aValue*65535.0),Int(65535) ); }
	static func convertFromFloatLiteral(aValue: FloatLiteralType) -> Rational { return Rational( Int(aValue), 1 ); }
}

extension Rational : FloatingPointType, SignedNumberType
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
	
	static var infinity: Rational { get { return Rational(1,0); } }

	static var NaN: Rational { get { return Rational(0,0); } }
	static var quietNaN: Rational { get { return Rational(0,0); } }

	var floatingPointClass: FloatingPointClassification { get { return toDouble.floatingPointClass; } }
	var isSignMinus: Bool { get { return (numerator < 0) != (denominator < 0); } }
	var isNormal: Bool { get { return numerator != 0 && denominator != 0; } }
	var isFinite: Bool { get { return denominator != 0; } }
	var isZero: Bool { get { return numerator == 0 && denominator != 0; } }
	var isSubnormal: Bool { get { return toDouble.isSubnormal; } }
	var isInfinite: Bool { get { return numerator != 0 && denominator == 0; } }
	var isNaN: Bool { get { return numerator == 0 && denominator == 0; } }
	var isSignaling: Bool { get { return toDouble.isSignaling; } }

	typealias Stride = Rational
	func distanceTo(anOther: Rational) -> Stride { return self - anOther; }
	func advancedBy(anOther: Stride) -> Rational { return self + anOther; }
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


func == (a: Rational, b: Rational) -> Bool { return a.numerator==b.numerator && a.denominator == b.denominator; }
func != (a: Rational, b: Rational) -> Bool { return a.numerator != b.numerator || a.denominator != b.denominator; }
func < (a: Rational, b: Rational) -> Bool { 	return a.numerator*b.denominator < b.numerator*a.denominator; }
func <= (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator <= b.numerator*a.denominator; }
func > (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator > b.numerator*a.denominator; }
func >= (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator >= b.numerator*a.denominator; }

