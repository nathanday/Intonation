/*
	Rational.swift
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

///
///	A rational value type
///
/// Uses numerator and denominator of type Int to represent a rational number,
///	the numerator and denominator will always be relativly prime,
/// i.e. the rational number will be in in its simpliest form.
///
public struct Rational : CustomStringConvertible, CustomDebugStringConvertible, Hashable, RationalNumeric {

	/// A Int representing the numerator of the rational number.
	///
	/// Negative rational values will have a negative numeratorm
	/// Positive rational values will have a positive numeratorm
	internal(set) public var	numerator:		Int;
	/// A Int representing the denominator of the rational number.
	///
	/// The denominator will always be positive regardless of the sign of the rational number
	internal(set) public var	denominator:	Int;

	private init(numerator aNum: Int,denominator aDen: Int) {
		numerator = aNum;
		denominator = aDen;
	}
	/// Creates a new instance with a default value.
	///
	/// The intialized calue with have a numerator of 0 and a denominator of 1.
	public init() {
		self.init(numerator:0,denominator:1);
	}
	/// Creates a new instance with the same memory representation as the given
	/// value.
	///
	/// - Parameter aRational: A value to use as the source of the new instance's binary
	///   representation.
	public init( _ aRational:Rational) {
		self.init(numerator:aRational.numerator,denominator:aRational.denominator);
	}
	/// Creates an rational value from the given numerator and denominator, reducing it
	/// to its simpliest form.
	///
	/// The simpliest form is found by dividing the numerator and denominator
	/// by there greatest common dvisor, for example
	///
	///		let a = Rational(12,18);
	///     // a.numerator == 2
	///     // a.denominator == 3
	///
	/// - Parameter aNumerator: An integer numerator.
	/// - Parameter aDenominator: An integer denominator.
    public init( _ aNumerator: Int, _ aDenominator: Int) {
		var		theNumerator = aDenominator < 0 ? -aNumerator : aNumerator;
		var		theDenominator = Int(aDenominator.magnitude);
		if theDenominator != 0 {
			let theCommonDivisor = greatestCommonDivisor(UInt(labs(theNumerator)), UInt(theDenominator));
			theNumerator = theNumerator/Int(theCommonDivisor);
			theDenominator = theDenominator/Int(theCommonDivisor);
		} else {		// the the denominator is zero then we have +- infinity or nan
			theNumerator = theNumerator.signum();
		}
		self.init(numerator:theNumerator,denominator:theDenominator);
    }
	/// Creates a new rational value from the given string.
	///
	/// The string is one or tww strings valid for initialising an Int delimited by either : or /,
	/// If `text` is in an invalid format the result is `nil`.
	/// some example
	///
	///		let a = Rational("1/2");
	///     // a.numerator == 1
	///     // a.denominator == 2
	///
	///		let b = Rational("3:2");
	///     // b.numerator == 3
	///     // b.denominator == 2
	///
	///		let c = Rational("5");
	///     // c.numerator == 5
	///     // c.denominator == 1
	///
	///		let d = Rational("5:2:1");
	///     // d == nil
	///
	/// - Parameters:
	///   - text: The ASCII representation of a ration number
	public init?<S>(_ aString: S) where S : StringProtocol {
		let		theComponents = String(aString).components(separatedBy: CharacterSet(charactersIn: ":/∶"));
		guard theComponents.count >= 1,
			let theNum = Int(theComponents[0]) else {
				return nil;
		}
		if theComponents.count == 2, let theDenom = Int( theComponents[1] ) {
			self.init( theNum, theDenom );
		} else if theComponents.count == 1 {
			self.init( theNum, 1 );
		} else {
			return nil;
		}
	}

	/// Creates a new instance from the given integer
	///
	/// - Parameter aSource: A value to convert to a rational.
	public init<T>(_ aSource: T) where T : BinaryInteger {
		self.init(numerator:Int(aSource),denominator:1);
	}

	public func numeratorForDenominator( _ aDenominator: Int ) -> Int? {
		return aDenominator != 0 && aDenominator%denominator == 0 ? numerator*(aDenominator/denominator) : nil;
	}

	/// returns a string representing the rational number as a ratio, for example
	///
	///		let a = Rational(3,2);
	///     // a.ratioString == "3:2"
	public var ratioString: String { return "\(numerator):\(denominator)"; }

	/// Hashes the essential components of this value by feeding them into the
	/// given hasher.
	///
	/// - Parameter hasher: The hasher to use when combining the components
	///   of this instance.
	public func hash(into aHasher: inout Hasher) {
		aHasher.combine(numerator)
		aHasher.combine(denominator)
	}
	/// A textual representation of this value.
	public var description: String { return String(self); }

	/// A textual representation of this instance, suitable for debugging.
	public var debugDescription: String {
		return "{numerator=\(numerator),denominator=\(denominator)}";
	}

	/// Creates an rational value from a BinaryFloatingPoint type.
	///
	/// A rational aproximation will be created with a denominator no greator than the given maxDenominator
	/// - Parameter aValue: value to aproximate
	/// - Parameter maxDenominator: The largest possible to denominator the rational number may have in approximate aValue
	public init<T>(_ aValue: T, maxDenominator aMaxDenom: Int ) where T : BinaryFloatingPoint {
		let		r = rationalAproximation( aValue, maxDenominator:aMaxDenom )
		self.init(numerator:r.numerator,denominator:r.denominator);
	}

	public typealias Stride = Rational
	public typealias Magnitude = Rational;

	/// Returns the distance from this value to the given value, expressed as a
	/// stride.
	///
	/// For two values `x` and `y`, and a distance `n = x.distance(to: y)`,
	/// `x.advanced(by: n) == y`.
	///
	/// - Parameter anOther: The value to calculate the distance to.
	/// - Returns: The distance from this value to `other`.
	public func distance(to anOther: Rational) -> Stride {
		return anOther - self;
	}
	/// Returns a value that is offset the specified distance from this value.
	///
	/// Use the `advanced(by:)` method in generic code to offset a value by a
	/// specified distance. If you're working directly with numeric values, use
	/// the addition operator (`+`) instead of this method.
	///
	/// For a value `x`, a distance `n`, and a value `y = x.advanced(by: n)`,
	/// `x.distance(to: y) == n`.
	///
	/// - Parameter anOther: The distance to advance this value.
	/// - Returns: A value that is offset from this value by `n`.
	public func advanced(by anOther: Stride) -> Rational {
		return self + anOther;
	}

	/// Creates a new instance from the given integer, if it can be represented
	/// exactly.
	///
	/// If the value passed as `source` is not representable exactly, the result
	/// is `nil`. In the following example, the constant `x` is successfully
	/// created from a value of `100`, while the attempt to initialize the
	/// constant `y` from `1_000` fails because the `Int8` type can represent
	/// `127` at maximum:
	///
	///     let x = Int8(exactly: 100)
	///     // x == Optional(100)
	///     let y = Int8(exactly: 1_000)
	///     // y == nil
	///
	/// - Parameter source: A value to convert to this type of integer.
	public init?<T>(exactly aSource: T) where T : BinaryInteger {
		guard let v = Int(exactly:aSource) else {
			return nil;
		}
		self.init(numerator:v,denominator:1);
	}

	/// The magnitude of this value.
	///
	/// For any rational value `x`, `x.magnitude` is the absolute value of `x`.
	///
	///     let x = Rational(-3,2);
	///     // x.magnitude == Rational(3,2)
	public var magnitude: Magnitude {
		return numerator < 0 ? Rational(-numerator,denominator) : self;
	}

	/// Returns `-1` if this value is negative and `1` if it's positive;
	/// otherwise, `0`.
	///
	/// - Returns: The sign of this number, expressed as an Int type.
	public func signum() -> Rational {
		return Rational(numerator.signum());
	}

	/// Multiplies two rational value and produces their product.
	///
	/// The multiplication operator (`*`) calculates the product of its two
	/// arguments. For example:
	///
	///     let a = Ration(2,3) * Ration(5)
	///     // a == Ration(10,3)
	///
	///	The product of the two arguments will be simplified, just as a Rational number initialized
	///	with a numerator and denominator are simplified
	///
	/// The product of the two arguments can thow and overflow error as part of the calculation even if after
	/// simplification the value maybe something representable by rational number, this is because
	///	the value must be calculated in a unsimplified form before simplification and may cause an overflow exception
	///
	/// - Parameters:
	///   - a: The first value to multiply.
	///   - b: The second value to multiply.
	public static func * (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.numerator,a.denominator*b.denominator);
	}

	/// Multiplies two values and stores the result in the left-hand-side
	/// variable.
	///
	///	The product of the two arguments will be simplified, just as a Rational number initialized
	///	with a numerator and denominator are simplified
	///
	/// The product of the two arguments can thow and overflow error as part of the calculation even if after
	/// simplification the value maybe something representable by rational number, this is because
	///	the value must be calculated in a unsimplified form before simplification and may cause an overflow exception
	///
	/// - Parameters:
	///   - a: The first value to multiply.
	///   - b: The second value to multiply.
	public static func *= (a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.numerator,a.denominator*b.denominator);
	}

	/// Returns the given rational number unchanged.
	///
	/// - Returns: The given argument without any changes.
	public static prefix func + (a: Rational) -> Rational {
		return a;
	}
	/// Adds two values and produces their sum.
	///
	/// The addition operator (`+`) calculates the sum of its two arguments. For
	/// example:
	///
	///     let a = Rational(1,5) + Ration(2,5)
	///     // a == Rational(3,5)
	///
	///	The sum of the two arguments will be simplified, just as a Rational number initialized
	///	with a numerator and denominator are simplified
	///
	/// The sum of the two arguments can thow and overflow error as part of the calculation even if after
	/// simplification the value maybe something representable by rational number, this is because
	///	the value must be calculated in a unsimplified form before simplification and may cause an overflow exception
	///
	/// - Parameters:
	///   - a: The first value to add.
	///   - b: The second value to add.
	public static func + (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator);
	}
	/// Adds two rational values and stores the result in the left-hand-side variable.
	///
	/// The sum of the two arguments can thow and overflow error as part of the calculation even if after
	/// simplification the value maybe something representable by rational number, this is because
	///	the value must be calculated in a unsimplified form before simplification and may cause an overflow exception
	///
	/// - Parameters:
	///   - a: The first value to add.
	///   - b: The second value to add.
	public static func += ( a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator);
	}

	/// Subtracts one rational value from another and produces their difference.
	///
	/// The subtraction operator (`-`) calculates the difference of its two
	/// arguments. For example:
	///
	///     let		a = Ration(3,4) - Ration(1,4)
	///     //	a == Ration(1,2)
	///
	/// - Parameters:
	///   - a: A numeric value.
	///   - b: The value to subtract from `a`.
	public static func - (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator);
	}
	/// Subtracts the second value from the first and stores the difference in the
	/// left-hand-side variable.
	///
	/// - Parameters:
	///   - a: A numeric value.
	///   - b: The value to subtract from `lhs`.
	public static func -= ( a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator);
	}

	/// Returns a Boolean value indicating whether the two given values are
	/// equal.
	///
	/// - Parameters:
	///   - a: A Rational to compare.
	///   - b: Another Rational to compare.
	public static func == (a: Rational, b: Rational) -> Bool {
		return !a.isNaN && a.numerator==b.numerator && a.denominator == b.denominator;
	}
	/// Returns a Boolean value indicating whether the two given values are not
	/// equal.
	///
	/// - Parameters:
	///   - a: A Rational to compare.
	///   - b: Another Rational to compare.
	public static func != (a: Rational, b: Rational) -> Bool {
		return a.numerator != b.numerator || a.denominator != b.denominator;
	}
	/// Returns a Boolean value indicating whether the value of the first
	/// argument is less than that of the second argument.
	///
	/// - Parameters:
	///   - a: A Rational to compare.
	///   - b: Another Rational to compare.
	public static func < (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator < b.numerator*a.denominator;
	}
	/// Returns a Boolean value indicating whether the value of the first
	/// argument is less than or equal to that of the second argument.
	///
	/// - Parameters:
	///   - a: A Rational to compare.
	///   - b: Another Rational to compare.
	public static func <= (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator <= b.numerator*a.denominator;
	}
	/// Returns a Boolean value indicating whether the value of the first
	/// argument is greater than that of the second argument.
	///
	/// - Parameters:
	///   - a: A Rational to compare.
	///   - b: Another Rational to compare.
	public static func > (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator > b.numerator*a.denominator;
	}
	/// Returns a Boolean value indicating whether the value of the first
	/// argument is greater than or equal to that of the second argument.
	///
	/// - Parameters:
	///   - a: A Rational to compare.
	///   - b: Another Rational to compare.
	public static func >= (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator >= b.numerator*a.denominator;
	}

	/// Replaces this value with its additive inverse, for example
	///
	///     var a = Rational(1,2)
	///     a.negate()
	///     // x == Rational(-1,2)
	public mutating func negate() {
		numerator = -numerator;
	}

	/// The Rational representation of zero.
	///
	/// Equivelent to Rational(0,1).
	public static var zero : Rational { return Rational(numerator:0,denominator:1); }
	/// The Rational representation of one.
	///
	/// Equivelent to Rational(1,1).
	public static var one : Rational { return Rational(numerator:1,denominator:1); }
	/// The minimum representable Rational.
	///
	/// Since Rational is based on Int, min is equal to Rational(Int.min,1).
	public static var min : Rational { return Rational(numerator:Int.min,denominator:1); }
	/// The maximum representable Rational
	///
	/// Since Rational is based on Int, max is equal to Rational(Int.max,1).
	public static var max : Rational { return Rational(numerator:Int.max,denominator:1); }
	/// A NaN ("not a number").
	///
	/// A NaN compares not equal, not greater than, and not less than every
	/// value, including itself. Passing a NaN to an operation generally results
	/// in NaN.
	///
	///     let x = 1.21
	///     // x > Rational.nan == false
	///     // x < Rational.nan == false
	///     // x == Rational.nan == false
	///
	/// Because a NaN always compares not equal to itself, to test whether a
	/// rational value is NaN, use its `isNaN` property instead of the
	/// equal-to operator (`==`). In the following example, `y` is NaN.
	///
	///     let y = x + Rational.nan
	///     print(y == Rational.nan)
	///     // Prints "false"
	///     print(y.isNaN)
	///     // Prints "true"
	public static var nan: Rational { return Rational(numerator:0,denominator:0); }
	/// Positive infinity.
	///
	/// Infinity compares greater than all finite Rational numbers and equal to other
	/// infinite values.
	///
	///     let x = Rational.max
	///     let y = Rational.infinity
	///     // y > x
	public static var infinity: Rational { return Rational(numerator:1,denominator:0); }
	/// The mathematical constant pi.
	///
	/// This value is a Rational approxiamation of pi, 
	///
	///     print(Rational.pi)
	///     // Prints "3.141592653589793" on a 64 bit arch
	public static var pi: Rational {
#if arch(x86_64) || arch(arm64)
		return Rational(numerator:7244019458077122842,denominator:2305843009213693951);
#else
		return Rational(numerator:1686629713,denominator:536870911);
#endif
	}
	/// Divides the first value by the second.
	///
	/// Is equivalent to multiplying the first term  by the reciprocal of the second term
	///
	///		lat	a = Rational(1,2);
	///		let	b = a.reciprocal();
	///		// b = Rational(2)
	///
	/// - Parameters:
	///   - a: The value to divide.
	///   - b: The value to divide `lhs` by. `rhs` must not be zero.
	public static func / (a: Rational, b: Rational) -> Rational {
		return b.numerator >= 0
			? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
			: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
	}
	/// Returns the additive inverse of the specified value, for example
	///
	///     let a = Rational(3,2)
	///     let b = -a
	///     // b == Rational(-3,2)
	///
	/// - Returns: The additive inverse of this value.
	public static prefix func - (a: Rational) -> Rational { return Rational(numerator:-a.numerator,denominator:a.denominator); }

	/// Divides the first value by the second and stores the quotient in the
	/// left-hand-side variable.
	///
	/// - Parameters:
	///   - a: The value to divide.
	///   - b: The value to divide `a` by. `b` must not be zero.
	public static func /= ( a: inout Rational, b: Rational) {
		a = b.numerator >= 0
			? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
			: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
	}

	/// Returns the reciprocal of the specified value, for example
	///
	///     let a = Rational(3,2)
	///     let b = a.reciprocal()
	///     // b == Rational(2,3)
	///
	/// - Returns: The reciprocal of this value.
	public func reciprocal() -> Rational {
		return Rational(numerator:denominator,denominator:numerator);
	}

	/// Is the value finite.
	///
	/// Returns true is the denominator is not equal to 0.
	public var isFinite: Bool { return denominator != 0; }
	/// Is the value zero.
	///
	/// Returns true is the numerator is eual to 1 and denominator is not equal to 0.
	public var isZero: Bool { return numerator == 0 && denominator != 0; }
	/// Is the value zero.
	///
	/// Returns true is the denominator is equal to 0.
	public var isInfinite: Bool { return numerator != 0 && denominator == 0; }
	/// Is the value not a number.
	///
	/// Returns true is the numerator and denominator are noth equal to 0.
	public var isNaN: Bool { return numerator == 0 && denominator == 0; }
	/// Is the value and integer.
	///
	/// Returns true is the denominator is equal to 1.
	public var isInteger: Bool { return denominator == 1; }
}


extension Rational : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
	/// Creates a new rational value from the given integer literal.
	///
	/// Do not call this initializer directly. It is used by the compiler when
	/// you create a new `Rational` instance by using a floating-point literal.
	/// Instead, create a new value by using a literal.
	///
	/// In this example, the assignment to the `x` constant calls this
	/// initializer behind the scenes.
	///
	///     let a: Rational = 21
	///     // x == Rational(21,1)
	///
	/// - Parameter value: The new Rational value.
	public init(integerLiteral aNumerator:Int) {
		self.init( numerator:aNumerator, denominator:1 );
	}

	/// Creates a new rational value from the given floating-point literal.
	///
	/// Do not call this initializer directly. It is used by the compiler when
	/// you create a new `Rational` instance by using a floating-point literal.
	/// Instead, create a new value by using a literal.
	///
	/// In this example, the assignment to the `x` constant calls this
	/// initializer behind the scenes.
	///
	///     let a: Rational = 21.25
	///     // a == Rational(85,4)
	///
	/// - Parameter value: The new Rational value.
	public init(floatLiteral aValue: FloatLiteralType) {
		self.init( aValue, maxDenominator:Int(UInt32.max) );
	}
}

fileprivate func rationalAproximation<T>( _ aValue: T, maxDenominator aMaxDenom: Int, maxError aMaxError: T = 0.0 ) -> (numerator:Int,denominator:Int) where T : BinaryFloatingPoint {
	func _farey<T>( _ x: T, _ M: Int, _ E:T ) -> (numerator:Int,denominator:Int) where T : BinaryFloatingPoint {
		var		a = (0,1);
		var		b = (1,1);
		while a.1 <= M && b.1 <= M {
			let		theMediant = T(a.0+b.0)/T(a.1+b.1);
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
	var		theResult = _farey( abs(aValue-T(theInt)), aMaxDenom, aMaxError );
	if( theInt < 0 ) {
		theResult.numerator = -theResult.numerator;
	}
	theResult.numerator += theInt*theResult.denominator;
	return theResult;
}
