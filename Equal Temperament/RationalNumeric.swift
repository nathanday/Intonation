//
//  RationalNumeric.swift
//  Intonation
//
//  Created by Nathaniel Day on 6/07/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Foundation

public protocol RationalNumeric : SignedNumeric, Strideable {

	var	numerator:		Int { get }
	var	denominator:	Int { get }
	init( _ aRational:Self);
	init( _ aNumerator: Int, _ aDenominator: Int);

	var toDouble:		Double { get }
	var toFloat:		Float { get }
	var toInt:			Int { get }
	var	isSignMinus:	Bool { get }

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
