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

/// A type that can represent rational value.
///
/// The `RationalNumeric` protocol extends the operations defined by the
/// `SignedNumeric` protocol to include a numerator and a denominator.
public protocol RationalNumeric : SignedNumeric, Strideable {

	/// A Int representing the numerator of the rational number.
	var	numerator:		Int { get }
	/// A Int representing the denominator of the rational number.
	var	denominator:	Int { get }
	/// Creates a new instance with the same memory representation as the given
	/// value.
	///
	/// - Parameter aRational: A value to use as the source of the new instance's binary
	///   representation.
	init( _ aRational:Self);
	/// Creates an rational value from the given numerator and denominator, reducing it
	/// to its simpliest form.
	///
	/// - Parameter aNumerator: An integer numerator.
	/// - Parameter aDenominator: An integer denominator.
	init( _ aNumerator: Int, _ aDenominator: Int);

	/// The RationalNumeric representation of zero.
	static var zero:		Self { get }
	/// The RationalNumeric representation of one.
	static var one:			Self { get }
	/// The minimum representable RationalNumeric.
	static var min:			Self { get }
	/// The maximum representable RationalNumeric.
	static var max:			Self { get }
	/// A NaN ("not a number").
	///
	/// A NaN compares not equal, not greater than, and not less than every
	/// value, including itself. Passing a NaN to an operation generally results
	/// in NaN.
	///
	/// Because a NaN always compares not equal to itself, to test whether a
	/// rational value is NaN, use its `isNaN` property instead of the
	/// equal-to operator (`==`). In the following example, `y` is NaN.
	static var nan:			Self { get }
	/// Positive infinity.
	///
	/// Infinity compares greater than all finite rational numbers and equal to other
	/// infinite values.
	///
	///     let x = RationalNumeric.max
	///     let y = RationalNumeric.infinity
	///     // y > x
	static var infinity:	Self { get }
	/// The mathematical constant pi.
	///
	/// This value is a Rational approxiamation of pi,
	///
	///     print(RationalNumeric.pi)
	///     // Prints "3.141592653589793" on a 64 bit arch
	static var pi:			Self { get }

	/// The magnitude of this value.
	///
	/// For any value `x`, `x.magnitude` is the absolute value of `x`.
	var magnitude: Magnitude { get }
	/// Returns `-1` if this value is negative and `1` if it's positive;
	/// otherwise, `0`.
	///
	/// - Returns: The sign of this number, expressed as an Int type.
	func signum() -> Self;
	/// Is the value and integer.
	///
	/// Returns true is the denominator is equal to 1.
	var	isInteger: Bool { get }

	/// Returns the reciprocal of the specified value, for example
	func reciprocal() -> Self;

	/// Divides the first value by the second.
	///
	/// - Parameters:
	///   - a: The value to divide.
	///   - b: The value to divide `lhs` by. `rhs` must not be zero.
	static func / (a: Self, b: Self) -> Self;
	/// Returns the additive inverse of the specified value, for example
	///
	/// - Returns: The additive inverse of this value.
	static prefix func - (a: Self) -> Self;

	/// Divides the first value by the second and stores the quotient in the
	/// left-hand-side variable.
	///
	/// - Parameters:
	///   - a: The value to divide.
	///   - b: The value to divide `a` by. `b` must not be zero.
	static func /= ( a: inout Self, b: Self);

	/// Is the value finite.
	///
	/// Returns true is the denominator is not equal to 0.
	var isFinite: Bool { get }
	/// Is the value zero.
	///
	/// Returns true is the numerator is eual to 1 and denominator is not equal to 0.
	var isZero: Bool { get }
	/// Is the value zero.
	///
	/// Returns true is the denominator is equal to 0.
	var isInfinite: Bool { get }
	/// Is the value not a number.
	///
	/// Returns true is the numerator and denominator are noth equal to 0.
	var isNaN: Bool { get }
}

extension String {
	/// Creates a String from the given Rational value.
	///
	/// - Parameter aRational: A rations value to convert to an Double.
	public init<T>(_ aRational: T ) where T : RationalNumeric {
		self.init(aRational.denominator != 1 ? "\(aRational.numerator)/\(aRational.denominator)" : "\(aRational.numerator)");
	}
}

extension Double {
	/// Creates a Double from the given rational value.
	///
	/// - Parameter aRational: A rations value to convert to an Double.
	public init<T>(_ aRational: T ) where T : RationalNumeric {
		self.init(Double(aRational.numerator)/Double(aRational.denominator));
	}
}

extension Float {
	/// Creates a Float from the given rational value.
	///
	/// - Parameter aRational: A rations value to convert to an Double.
	public init<T>(_ aRational: T ) where T : RationalNumeric {
		self.init(Float(aRational.numerator)/Float(aRational.denominator));
	}
}
extension Int {
	/// Creates an integer from the given rational value, rounding toward
	/// zero.
	///
	/// Any fractional part of the value passed as `source` is removed, rounding
	/// the value toward zero.
	///
	/// - Parameter aRational: A floating-point value to convert to an integer.
	public init<T>(_ aRational: T ) where T : RationalNumeric {
		self.init(aRational.numerator/aRational.denominator);
	}
}
