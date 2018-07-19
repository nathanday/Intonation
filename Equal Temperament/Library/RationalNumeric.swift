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
	var	isSignMinus:	Bool { get }

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

	mutating func addProduct(_ l: Self, _ r: Self);

	static func sum( _ array: [Self] ) -> Self;

	var isFinite: Bool { get }
	var isZero: Bool { get }
	var isInfinite: Bool { get }
	var isNaN: Bool { get }
}
