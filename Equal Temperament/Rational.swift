/*
    Rational.swift
    Equal Temperament

    Created by Nathan Day on 7/06/14.
    Copyright (c) 2014 Nathan Day. All rights reserved.
 */

import Foundation

struct Rational : ArrayLiteralConvertible, IntegerLiteralConvertible
{
	let	numerator:		Int64;
	let	denominator:	Int64;
	var toDouble:		Double { return Double(numerator)/Double(denominator); }

    static func convertFromArrayLiteral( anElements: Int64...) -> Rational
    {
        var     theNumerator : Int64! = nil;
        var     theDenominator : Int64! = nil;
        for theElement in anElements
        {
            if theNumerator == nil { theNumerator = theElement; }
            else if theDenominator == nil { theDenominator = theElement; }
            else { NSException(name: NSRangeException, reason: "Too many arguments", userInfo: nil).raise(); }
        }
        if( theNumerator == nil || theDenominator == nil ) { NSException(name: NSRangeException, reason: "Too few arguments", userInfo: nil).raise(); }
        return Rational( theNumerator, theDenominator );
    }

    static func convertFromIntegerLiteral(aValue: IntegerLiteralType) -> Rational { return Rational( Int64(aValue), 1 ); }

    init(var _ aNumerator:Int64,var _ aDenominator:Int64)
    {
        if( aDenominator < 0 )
        {
            aNumerator = -aNumerator;
            aDenominator = -aDenominator;
        }
        
        let theCommonDivisor = Rational.greatestCommonDivisor(aNumerator, aDenominator);
        numerator = aNumerator/theCommonDivisor;
        denominator = aDenominator/theCommonDivisor;
    }
    init(var _ aNumerator:Int64)
    {
        numerator = aNumerator;
        denominator = 1;
    }
	var toString: String { return "\(numerator)\\\(denominator)"; }

	var hashValue: Int { return Int(numerator)^Int(denominator); }
	var description: String { return toString; }

	static func greatestCommonDivisor(u: Int64, _ v: Int64) -> Int64
	{
		// simple cases (termination)
		if u == v { return u; }
		if u == 0 { return v; }
		if v == 0 { return u; }

		// look for factors of 2
		if (~u & 0b1) != 0  // u is even
		{
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
func + (a: Rational, b: Int64) -> Rational { return Rational(a.numerator+b*a.denominator,a.denominator); }
func - (a: Rational, b: Int64) -> Rational { return Rational(a.numerator-b*a.denominator,a.denominator); }
func * (a: Rational, b: Int64) -> Rational { return Rational(a.numerator*b,a.denominator); }

func / (a: Rational, b: Int64) -> Rational {
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

