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

public struct Rational : CustomStringConvertible, CustomDebugStringConvertible, Hashable, RationalNumeric {

	internal(set) public var	numerator:		Int;
	internal(set) public var	denominator:	Int;

	private init(numerator aNum: Int,denominator aDen: Int) {
		numerator = aNum;
		denominator = aDen;
	}
	public init() {
		self.init(numerator:0,denominator:1);
	}
	public init( _ aRational:Rational) {
		self.init(numerator:aRational.numerator,denominator:aRational.denominator);
	}
    public init( _ aNumerator: Int, _ aDenominator: Int) {
		let		theNumerator = aDenominator < 0 ? -aNumerator : aNumerator;
		let		theDenominator = aDenominator.magnitude;
		let		theCommonDivisor = greatestCommonDivisor(UInt(labs(theNumerator)), theDenominator);
		self.init(numerator:theNumerator/Int(theCommonDivisor),denominator:Int(theDenominator)/Int(theCommonDivisor));
    }
	public init?<S>(_ aString: S) where S : StringProtocol {
		let		theComponents = String(aString).components(separatedBy: CharacterSet(charactersIn: ":/∶"));
		let		theDenom = theComponents.count > 1 ? Int( theComponents[1] ) : 1;
		if let theNum = Int(theComponents[0]) {
			self.init( theNum, theDenom ?? 1 );
		} else {
			return nil;
		}
	}

	public init?<T>(_ aSource: T) where T : BinaryInteger {
		self.init(numerator:Int(aSource),denominator:1);
	}

	public func numeratorForDenominator( _ aDenominator: Int ) -> Int? {
		return aDenominator != 0 && aDenominator%denominator == 0 ? numerator*(aDenominator/denominator) : nil;
	}

	public var ratioString: String { return "\(numerator):\(denominator)"; }

	public func hash(into aHasher: inout Hasher) {
		aHasher.combine(numerator)
		aHasher.combine(denominator)
	}
	public var description: String { return String(self); }

	public var debugDescription: String {
		return "\(numerator)∶\(denominator)";
	}
	private static func farey( _ aValue: Double, maxDenominator aMaxDenom: Int, maxError aMaxError: Double = 0.0 ) -> (numerator:Int,denominator:Int) {
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

	public init(_ aValue: Double, maxDenominator aMaxDenom: Int ) {
		let		r = Rational.farey( aValue, maxDenominator:aMaxDenom )
		self.init(numerator:r.numerator,denominator:r.denominator);
	}

	public init(_ aValue: Float, maxDenominator aMaxDenom: Int ) {
		self.init(Double(aValue), maxDenominator:aMaxDenom);
	}

	public typealias Stride = Rational
	public typealias Magnitude = Rational;

	public func distance(to anOther: Rational) -> Stride {
		return anOther - self;
	}
	public func advanced(by anOther: Stride) -> Rational {
		return self + anOther;
	}

	public init?<T>(exactly aSource: T) where T : BinaryInteger {
		self.init(numerator:Int(aSource),denominator:1);
	}

	public var magnitude: Magnitude {
		return numerator < 0 ? Rational(-numerator,denominator) : self;
	}

	public func signum() -> Int { return numerator.signum(); }

	public static func * (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.numerator,a.denominator*b.denominator);
	}

	public static func *= (a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.numerator,a.denominator*b.denominator);
	}

	public static prefix func + (a: Rational) -> Rational {
		return a;
	}
	public static func + (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator);
	}
	public static func += ( a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator);
	}

	public static func - (a: Rational, b: Rational) -> Rational {
		return Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator);
	}
	public static func -= ( a: inout Rational, b: Rational) {
		a = Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator);
	}

	public static func == (a: Rational, b: Rational) -> Bool {
		return a.numerator==b.numerator && a.denominator == b.denominator;
	}
	public static func != (a: Rational, b: Rational) -> Bool {
		return a.numerator != b.numerator || a.denominator != b.denominator;
	}
	public static func < (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator < b.numerator*a.denominator;
	}
	public static func <= (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator <= b.numerator*a.denominator;
	}
	public static func > (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator > b.numerator*a.denominator;
	}
	public static func >= (a: Rational, b: Rational) -> Bool {
		return a.numerator*b.denominator >= b.numerator*a.denominator;
	}

	public mutating func negate() {
		numerator = -numerator;
	}

	/*
	RationalNumeric
	*/
	public static var zero : Rational { return Rational(numerator:0,denominator:1); }
	public static var one : Rational { return Rational(numerator:1,denominator:1); }
	public static var min : Rational { return Rational(numerator:Int.min,denominator:1); }
	public static var max : Rational { return Rational(numerator:Int.max,denominator:1); }
	public static var nan: Rational { return Rational(numerator:0,denominator:0); }
	public static var infinity: Rational { return Rational(numerator:1,denominator:0); }
	public static var pi: Rational {
#if arch(x86_64) || arch(arm64)
		return Rational(numerator:7244019458077122842,denominator:2305843009213693951);
#else
		return Rational(numerator:1686629713,denominator:536870912);
#endif
	}

	public static func abs(_ x: Rational) -> Rational {
		return (x.numerator < 0) != (x.denominator < 0) ? -x : x;
	}

	public static func == (a: Rational, b: Int) -> Bool { return a.numerator == b && a.denominator == 1; }
	public static func != (a: Rational, b: Int) -> Bool { return a.numerator != b || a.denominator != 1; }
	public static func < (a: Rational, b: Int) -> Bool { 	return a.numerator < b*a.denominator; }
	public static func <= (a: Rational, b: Int) -> Bool { return a.numerator <= b*a.denominator; }
	public static func > (a: Rational, b: Int) -> Bool { return a.numerator > b*a.denominator; }
	public static func >= (a: Rational, b: Int) -> Bool { return a.numerator >= b*a.denominator; }

	public static func / (a: Rational, b: Rational) -> Rational {
		return b.numerator >= 0
			? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
			: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
	}
	public static prefix func - (a: Rational) -> Rational { return Rational(numerator:-a.numerator,denominator:a.denominator); }

	public static func /= ( a: inout Rational, b: Rational) {
		a = b.numerator >= 0
			? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
			: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
	}

	public var isSignMinus: Bool { return (numerator < 0) != (denominator < 0); }

	public static func + (a: Rational, b: Int) -> Rational { return Rational(a.numerator+b*a.denominator,a.denominator); }
	public static func - (a: Rational, b: Int) -> Rational { return Rational(a.numerator-b*a.denominator,a.denominator); }
	public static func * (a: Rational, b: Int) -> Rational { return Rational(a.numerator*b,a.denominator); }

	public static func / (a: Rational, b: Int) -> Rational {
		return b >= 0
			? Rational(a.numerator,a.denominator*b)
			: Rational(-a.numerator,-a.denominator*b);
	}

	public static func += ( a: inout Rational, b: Int) { a = Rational(a.numerator+b*a.denominator,a.denominator); }
	public static func -= ( a: inout Rational, b: Int) { a = Rational(a.numerator-b*a.denominator,a.denominator); }
	public static func *= ( a: inout Rational, b: Int) { a = Rational(a.numerator*b,a.denominator); }

	public static func /= ( a: inout Rational, b: Int) {
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
	public static func sum( _ anArray: [Rational] ) -> Rational {
		var			theResultNum = 0,
		theResultDen = 1;
		for theTerm in anArray {
			theResultNum = theResultNum*theTerm.denominator+theTerm.numerator*theResultDen;
			theResultDen *= theTerm.denominator
		}
		return Rational( theResultNum, theResultDen );
	}

	public var isFinite: Bool { return denominator != 0; }
	public var isZero: Bool { return numerator == 0 && denominator != 0; }
	public var isInfinite: Bool { return denominator == 0; }
	public var isNaN: Bool { return numerator == 0 && denominator == 0; }
}


extension Rational : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
	public init(integerLiteral aNumerator:Int) {
		self.init( numerator:aNumerator, denominator:1 );
	}

	public init(floatLiteral aValue: FloatLiteralType) {
		self.init( aValue, maxDenominator:Int(UInt32.max) );
	}
}

extension String {
	public init(_ aRational: Rational ) {
		self.init(aRational.denominator != 1 ? "\(aRational.numerator)/\(aRational.denominator)" : "\(aRational.numerator)");
	}
}

extension Double {
	public init(_ aRational: Rational ) {
		self.init(Double(aRational.numerator)/Double(aRational.denominator));
	}
}

extension Float {
	public init(_ aRational: Rational ) {
		self.init(Float(aRational.numerator)/Float(aRational.denominator));
	}
}
extension Int {
	public init(_ aRational: Rational ) {
		self.init(aRational.numerator/aRational.denominator);
	}
}
