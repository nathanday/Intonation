/*
	RationalNumeric.swift
	Created by Nathan Day on 06.07.18 under a MIT-style license.
	Copyright (c) 2018 Nathaniel Day
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

import Foundation

public protocol RationalNumeric : SignedNumeric, Strideable {

	var	numerator:		Int { get }
	var	denominator:	Int { get }
	init( _ aRational:Self);
	init( _ aNumerator: Int, _ aDenominator: Int);

	static var zero:		Self { get }
	static var one:			Self { get }
	static var min:			Self { get }
	static var max:			Self { get }
	static var nan:			Self { get }
	static var infinity:	Self { get }
	static var pi:			Self { get }

	static func abs(_ x: Self) -> Self;
	var magnitude: Magnitude { get }
	func signum() -> Int;
	var	isSignMinus:	FloatingPointSign { get }
	var	isInteger:		Bool { get }


	static func == (a: Self, b: Int) -> Bool;
	static func != (a: Self, b: Int) -> Bool;
	static func < (a: Self, b: Int) -> Bool;
	static func <= (a: Self, b: Int) -> Bool;
	static func > (a: Self, b: Int) -> Bool;
	static func >= (a: Self, b: Int) -> Bool;

	static func / (a: Self, b: Self) -> Self;
	static prefix func - (a: Self) -> Self;

	static func /= ( a: inout Self, b: Self);

	static func + (a: Self, b: Int) -> Self;
	static func - (a: Self, b: Int) -> Self;
	static func * (a: Self, b: Int) -> Self;

	static func / (a: Self, b: Int) -> Self;

	static func += ( a: inout Self, b: Int);
	static func -= ( a: inout Self, b: Int);
	static func *= ( a: inout Self, b: Int);

	static func /= ( a: inout Self, b: Int);

	var isFinite: Bool { get }
	var isZero: Bool { get }
	var isInfinite: Bool { get }
	var isNaN: Bool { get }
}

func rationalAproximation( _ aValue: Double, maxDenominator aMaxDenom: Int, maxError aMaxError: Double = 0.0 ) -> (numerator:Int,denominator:Int) {
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
