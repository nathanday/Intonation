/*
    Rational.swift
    Equal Temperament

    Created by Nathan Day on 7/06/14.
    Copyright (c) 2014 Nathan Day. All rights reserved.
 */

import Foundation

struct Rational : ArrayLiteralConvertible, IntegerLiteralConvertible, Printable, DebugPrintable, Hashable
{
	let	numerator:		Int;
	let	denominator:	Int;
	var toDouble:		Double { return Double(numerator)/Double(denominator); }

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
    init(var _ aNumerator:Int,var _ aDenominator:Int) {
        if( aDenominator < 0 ) {
            aNumerator = -aNumerator;
            aDenominator = -aDenominator;
        }
		
        let theCommonDivisor = Rational.greatestCommonDivisor(aNumerator, aDenominator);
        numerator = aNumerator/theCommonDivisor;
        denominator = aDenominator/theCommonDivisor;
    }
    init(var integerLiteral aNumerator:Int) {
        numerator = aNumerator;
        denominator = 1;
    }
	var toString: String { return "\(numerator)\\\(denominator)"; }
	var ratioString: String { return "\(numerator):\(denominator)"; }
	
	var hashValue: Int { return Int(numerator)^Int(denominator); }
	var description: String { return toString; }

	static func greatestCommonDivisor(u: Int, _ v: Int) -> Int {
		// simple cases (termination)
		if u == v { return u; }
		if u == 0 { return v; }
		if v == 0 { return u; }

		// look for factors of 2
		if (~u & 0b1) != 0 {  // u is even
			if (v & 0b1) != 0 {		// v is odd
				return greatestCommonDivisor(u >> 1, v);
			}
			else { // both u and v are even
				return greatestCommonDivisor(u >> 1, v >> 1) << 1;
			}
		}

		if (~v & 0b1) != 0 { return greatestCommonDivisor(u, v >> 1); } // u is odd, v is even

		// reduce larger argument
		if u > v { return greatestCommonDivisor((u - v) >> 1, v); }

		return greatestCommonDivisor((v - u) >> 1, u);
	}

	var debugDescription: String {
		return "\(numerator):\(denominator)";
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


func == (a: Rational, b: Rational) -> Bool { return a.numerator==b.numerator && a.denominator == b.denominator; }
func != (a: Rational, b: Rational) -> Bool { return a.numerator != b.numerator || a.denominator != b.denominator; }
func < (a: Rational, b: Rational) -> Bool { 	return a.numerator*b.denominator < b.numerator*a.denominator; }
func <= (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator <= b.numerator*a.denominator; }
func > (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator > b.numerator*a.denominator; }
func >= (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator >= b.numerator*a.denominator; }

