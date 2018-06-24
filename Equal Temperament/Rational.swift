/*
    Rational.swift
    Intonation

    Created by Nathan Day on 7/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Foundation

struct Rational : CustomStringConvertible, CustomDebugStringConvertible, Hashable {
	internal(set) var	numerator:		Int;
	internal(set) var	denominator:	Int;
	var toDouble:		Double { return Double(numerator)/Double(denominator); }
	var toCents:		Double { return toDouble.toCents; }
	var toFloat:		Float { return Float(numerator)/Float(denominator); }
	var toInt:			Int { return numerator/denominator; }

	static var zero : Rational { return Rational(0,1); }
	static var one : Rational { return Rational(1,1); }
	static var max : Rational { return Rational(Int.max,1); }

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
		let		theDenominator = aDenominator.magnitude;
        let		theCommonDivisor = greatestCommonDivisor(UInt(theNumerator), theDenominator);
        numerator = theNumerator/Int(theCommonDivisor);
        denominator = Int(theDenominator)/Int(theCommonDivisor);
		precondition(theDenominator != 0, "\(numerator)/\(denominator) is not a number");
    }
	init( _ aNumerator: UInt, _ aDenominator: UInt) {
		self.init( Int(aNumerator), Int(aDenominator) );
	}
	init?( _ aString: String ) {
		let		theComponents = aString.components(separatedBy: CharacterSet(charactersIn: ":/∶"));
		let		theDenom = theComponents.count > 1 ? Int( theComponents[1] ) : 1;
		if let theNum = Int(theComponents[0]) {
			self.init( theNum, theDenom ?? 1 );
		} else {
			return nil;
		}
	}
	init( _ aTuple: (numerator:Int,denominator:Int) ) {
		self.init(aTuple.numerator,aTuple.denominator);
	}

	func numeratorForDenominator( _ aDenominator: Int ) -> Int? {
		return aDenominator != 0 && aDenominator%denominator == 0 ? numerator*(aDenominator/denominator) : nil;
	}

	var toString: String {
		return denominator != 1 ? "\(numerator)/\(denominator)" : "\(numerator)";
	}
	var ratioString: String { return "\(numerator):\(denominator)"; }

	func hash(into aHasher: inout Hasher) {
		aHasher.combine(numerator)
		aHasher.combine(denominator)
	}
	var description: String { return toString; }

	var debugDescription: String {
		return "\(numerator)∶\(denominator)";
	}
	var factorsString : String {
		return "\(UInt(numerator).factorsString)∶\(UInt(denominator).factorsString)";
	}
}

extension Rational : ExpressibleByArrayLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
	static func convertFromArrayLiteral( anElements: Int...) -> Rational {
		var     theNumerator : Int! = nil;
		var     theDenominator : Int! = nil;
		for theElement in anElements {
			if theNumerator == nil { theNumerator = theElement; }
			else if theDenominator == nil { theDenominator = theElement; }
			else { NSException(name: NSExceptionName.rangeException, reason: "Too many arguments", userInfo: nil).raise(); }
		}
		if( theNumerator == nil || theDenominator == nil ) { NSException(name: NSExceptionName.rangeException, reason: "Too few arguments", userInfo: nil).raise(); }
		return Rational( theNumerator, theDenominator );
	}

	static func convertFromIntegerLiteral( aValue: IntegerLiteralType) -> Rational { return Rational( Int(aValue), 1 ); }

	init( arrayLiteral elements: Int...) {
		self.init( elements[0], elements[1] );
	}
	init(integerLiteral aNumerator:Int) {
		self.init( aNumerator, 1 );
	}
	init(floatLiteral aValue: FloatLiteralType) { self.init( aValue, maxDenominator:UInt.max ); }
	static func convertFromFloatLiteral( aValue: FloatLiteralType) -> Rational { return Rational( aValue, maxDenominator:UInt.max ); }
}

extension Rational : FloatingPoint, SignedNumeric, Comparable {
	init<Source>(_ aSource: Source) where Source : BinaryInteger {
		self.init(Int(aSource),1);
	}

	init?<T>(exactly aSource: T) where T : BinaryInteger {
		self.init(Int(aSource),1);
	}

	var magnitude: Magnitude {
		return numerator < 0 ? negated() : self;
	}

	public mutating func addProduct(_ l: Rational, _ r: Rational) {
		numerator = numerator*l.denominator*r.denominator + denominator*l.numerator*r.numerator;
		denominator = denominator*l.denominator*r.denominator;
	}

	public func rounded(_ aRule: FloatingPointRoundingRule) -> Rational {
		var		theResult = Rational(self);
		theResult.round(aRule);
		return theResult;
	}

	public mutating func round(_ aRule: FloatingPointRoundingRule) {
		switch aRule {
		case .awayFromZero:
			numerator > 0 ? round(.up) : round(.down);
		case .down:
			numerator = numerator/denominator;
			denominator = 1;
		case .toNearestOrAwayFromZero:
			numerator = (numerator+numerator%denominator)/denominator;
			denominator = 1;
		case .toNearestOrEven:
			numerator = (numerator+denominator-1)/denominator;
			denominator = 1;
		case .towardZero:
			numerator > 0 ? round(.down) : round(.up);
		case .up:
			numerator = (numerator+denominator-1)/denominator;
			denominator = 1;
		}
	}

	public mutating func formSquareRoot() {
		(numerator,denominator) = Rational.farey( toDouble, maxDenominator:UInt.max );
	}

	/// Replaces this value with the remainder of itself divided by the given
	/// value using truncating division.
	///
	/// Performing truncating division with floating-point values results in a
	/// truncated integer quotient and a remainder. For values `x` and `y` and
	/// their truncated integer quotient `q`, the remainder `r` satisfies
	/// `x == y * q + r`.
	///
	/// The following example calculates the truncating remainder of dividing
	/// 8.625 by 0.75:
	///
	///     var x = 8.625
	///     print(x / 0.75)
	///     // Prints "11.5"
	///
	///     let q = (x / 0.75).rounded(.towardZero)
	///     // q == 11.0
	///     x.formTruncatingRemainder(dividingBy: 0.75)
	///     // x == 0.375
	///
	///     let x1 = 0.75 * q + x
	///     // x1 == 8.625
	///
	/// If this value and `other` are both finite numbers, the truncating
	/// remainder has the same sign as `other` and is strictly smaller in
	/// magnitude. The `formtruncatingRemainder(dividingBy:)` method is always
	/// exact.
	///
	/// - Parameter other: The value to use when dividing this value.
	///
	/// - SeeAlso: `truncatingRemainder(dividingBy:)`,
	///   `formRemainder(dividingBy:)`
	public mutating func formTruncatingRemainder(dividingBy anOther: Rational) {
//		code
	}

	typealias Exponent = Int32;
	typealias _BitsType = (Int,Int);
	typealias Magnitude = Rational;
	static func _fromBitPattern( aBits: _BitsType) -> Rational { return Rational(aBits.0,aBits.1); }
	func _toBitPattern() -> _BitsType { return (numerator,denominator); }

	init(sign: FloatingPointSign, exponent: Rational.Exponent, significand: Rational) {
		self.init( sign != significand.sign ? -significand.numerator : significand.numerator, significand.denominator );
	}

	init(signOf: Rational, magnitudeOf: Rational) {
		self.init(signOf.sign != magnitudeOf.sign ? -magnitudeOf.numerator : magnitudeOf.numerator, magnitudeOf.denominator);
	}

	init(_ aValue: UInt8) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: Int8) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: UInt16) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: Int16) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: UInt32) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: Int32) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: UInt64) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: Int64) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: UInt) {
		self.init(Int(aValue),1);
	}

	init(_ aValue: Int) {
		self.init(Int(aValue),1);
	}

	static func farey( _ aValue: Double, maxDenominator aMaxDenom: UInt, maxError aMaxError: Double = 0.0 ) -> (numerator:Int,denominator:Int) {
		func _farey( _ x: Double, _ M: UInt, _ E:Double ) -> (numerator:Int,denominator:Int) {
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
		var		theResult = _farey( fabs(aValue-Double(theInt)), aMaxDenom, aMaxError );
		if( theInt < 0 ) {
			theResult.numerator = -theResult.numerator;
		}
		theResult.numerator += theInt*theResult.denominator;
		return theResult;
	}

	init(_ aValue: Double, maxDenominator aMaxDenom: UInt ) {
		self.init(Rational.farey( aValue, maxDenominator:aMaxDenom ));
	}

	init(_ aValue: Float, maxDenominator aMaxDenom: UInt ) {
		self.init(Rational.farey( Double(aValue), maxDenominator:aMaxDenom ));
	}

	static var radix: Int { return 2; }
	static var nan: Rational { return Rational.zero; }
	static var signalingNaN: Rational { return nan; }

	static var infinity: Rational { return Rational(0,1); }

	static var greatestFiniteMagnitude: Rational { return Rational(Int.max,1); }

	static var pi: Rational {
#if arch(x86_64) || arch(arm64)
		return Rational(7244019458077122842,2305843009213693951);
#else
		return Rational(1686629713,536870912);
#endif
	}

	var ulp: Rational { return Rational(1,Int.max); }

	static var ulpOfOne: Rational { return Rational(Int.max,Int.max-1); }

	static var leastNormalMagnitude: Rational { return Rational(1,Int.max); }

	static var leastNonzeroMagnitude: Rational { return Rational(1,Int.max); }

	var sign: FloatingPointSign { if numerator < 0 { return .minus;} else { return .plus;} }

	var exponent: Rational.Exponent {
		var		theResult = 0;

		if denominator == 0 {
			theResult = Int.max;
		}
		else {
			theResult =  log10(numerator) - log10(denominator);
		}
		return Rational.Exponent(theResult);
	}

	var significand: Rational { return sign == .minus ? -self : self; }

	func adding( other: Rational) -> Rational {
		return Rational(numerator*other.denominator+other.numerator*denominator,denominator*other.denominator);
	}

	mutating func add( _ other: Rational) {
		numerator = numerator*other.denominator + other.numerator*denominator;
		denominator *= other.denominator;
	}

	func negated() -> Rational { return Rational(-numerator,denominator); }
	mutating func negate() { numerator = -numerator; }

	func subtracting( other: Rational) -> Rational {
		return Rational(numerator*other.denominator-other.numerator*denominator,denominator*other.denominator);
	}

	mutating func subtract( _ other: Rational) {
		numerator = numerator*other.denominator-other.numerator*denominator;
		denominator *= other.denominator;
	}

	func multiplied(by other: Rational) -> Rational { return Rational(numerator*other.numerator,denominator*other.denominator); }

	mutating func multiply(by other: Rational) {
		numerator *= other.numerator;
		denominator *= other.denominator;
	}

	func divided(dividingBy other: Rational) -> Rational { return Rational(numerator*other.denominator,denominator*other.numerator); }

	mutating func divide(by other: Rational) {
		numerator *= other.denominator;
		denominator *= other.numerator;
	}


	/// Remainder of `self` divided by `other` using truncating division.
	/// Equivalent to the C standard library function `fmod`.
	///
	/// If `self` and `other` are finite numbers, the truncating remainder
	/// `r` has the same sign as `other` and is strictly smaller in magnitude.
	/// It satisfies `r = self - other*n`, where `n` is the integral part
	/// of `self/other`.
	///
	/// `truncatingRemainder` is always exact.
	func truncatingRemainder(dividingBy anOther: Rational) -> Rational {
		var		theResult = Rational(self);
		theResult.formRemainder( dividingBy: anOther );
		return theResult;
	}

	/// Mutating form of `truncatingRemainder`.
	mutating func formRemainder(dividingBy anOther: Rational) {
		while self > anOther {
			subtract(anOther);
		}
	}

	static func minimum( _ x: Rational, _ y: Rational) -> Rational { return x <= y ? x : y; }
	static func maximum( _ x: Rational, _ y: Rational) -> Rational { return x >= y ? x : y; }

	static func minimumMagnitude( _ x: Rational, _ y: Rational) -> Rational { return abs(x) <= abs(y) ? x : y; }
	static func maximumMagnitude( _ x: Rational, _ y: Rational) -> Rational { return abs(x) >= abs(y) ? x : y; }

	var nextUp: Rational {
		if numerator < 0 && denominator == 0 {
			return Rational(Int.min,1);
		} else if numerator == Int.min && denominator == 1 {
			return Rational.zero;
		} else if self == Rational.zero {
			return Rational.leastNonzeroMagnitude;
		} else if self == Rational.greatestFiniteMagnitude {
			return Rational.infinity;
		} else if self == -Rational.infinity {
			return self;
		} else {
			return self + Rational.leastNonzeroMagnitude;
		}
	}

	var nextDown: Rational {
		if numerator > 0 && denominator == 0 {
			return Rational(Int.max,1);
		} else if numerator == Int.max && denominator == 1 {
			return Rational.zero;
		} else if self == Rational.zero {
			return -Rational.leastNonzeroMagnitude;
		} else if self == -Rational.greatestFiniteMagnitude {
			return -Rational.infinity;
		} else if self == -Rational.infinity {
			return Rational.infinity;
		} else {
			return self - Rational.leastNonzeroMagnitude;
		}
	}

	func isEqual(to other: Rational) -> Bool {
		return numerator==other.numerator && denominator==other.denominator;
	}

	func isLess(than other: Rational) -> Bool {
		return numerator*other.denominator < other.numerator*denominator;
	}

	func isLessThanOrEqualTo(_ other: Rational) -> Bool {
		return numerator*other.denominator <= other.numerator*denominator;
	}

	func isTotallyOrdered(belowOrEqualTo other: Rational) -> Bool {
		return numerator*other.denominator < other.numerator*denominator;
	}

	var isNormal: Bool { return self != Rational.zero; }
	var isFinite: Bool { return denominator != 0; }
	var isZero: Bool { return numerator == 0; }
	var isSubnormal: Bool { return self == Rational.zero; }
	var isInfinite: Bool { return denominator == 0; }
	var isNaN: Bool { return numerator == 0 && denominator == 0; }
	var isSignalingNaN: Bool { return false; }

	var floatingPointClass: FloatingPointClassification {
		if isSignalingNaN {
			return .signalingNaN;
		} else if denominator == 0 {
			if numerator < 0 {
				return .negativeInfinity;
			} else if numerator > 0 {
				return .positiveInfinity;
			} else {
				return .quietNaN;
			}
		} else {
			if numerator < 0 {
				return .negativeNormal;
			} else if numerator > 0 {
				return .positiveNormal;
			} else {
				return .positiveZero;
			}
		}
	}

	var isCanonical: Bool { return true; }

	static var quietNaN: Rational { return Rational(0,0); }

//	var isSignMinus: Bool { return (numerator < 0) != (denominator < 0); }

	typealias Stride = Rational
	func distance(to anOther: Rational) -> Stride { return self - anOther; }
	func advanced(by anOther: Stride) -> Rational { return self + anOther; }

	static func abs(_ x: Rational) -> Rational {
		return x.sign == .minus ? -x : x;
	}

	static func == (a: Rational, b: Rational) -> Bool { return a.numerator==b.numerator && a.denominator == b.denominator; }
	static func != (a: Rational, b: Rational) -> Bool { return a.numerator != b.numerator || a.denominator != b.denominator; }
	static func < (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator < b.numerator*a.denominator; }
	static func <= (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator <= b.numerator*a.denominator; }
	static func > (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator > b.numerator*a.denominator; }
	static func >= (a: Rational, b: Rational) -> Bool { return a.numerator*b.denominator >= b.numerator*a.denominator; }

	static func == (a: Rational, b: Int) -> Bool { return a.numerator == b && a.denominator == 1; }
	static func != (a: Rational, b: Int) -> Bool { return a.numerator != b || a.denominator == 1; }
	static func < (a: Rational, b: Int) -> Bool { 	return a.numerator < b*a.denominator; }
	static func <= (a: Rational, b: Int) -> Bool { return a.numerator <= b*a.denominator; }
	static func > (a: Rational, b: Int) -> Bool { return a.numerator > b*a.denominator; }
	static func >= (a: Rational, b: Int) -> Bool { return a.numerator >= b*a.denominator; }

	static func == (a: Rational, b: UInt) -> Bool { return a.numerator >= 0 && UInt(a.numerator) == b && a.denominator == 1; }
	static func != (a: Rational, b: UInt) -> Bool { return a.numerator < 0 || UInt(a.numerator) != b || a.denominator == 1; }
	static func < (a: Rational, b: UInt) -> Bool { return a < 0 || a < Int(b); }
	static func <= (a: Rational, b: UInt) -> Bool { return a < 0 || a <= Int(b); }
	static func > (a: Rational, b: UInt) -> Bool { return a >= 0 && a > Int(b); }
	static func >= (a: Rational, b: UInt) -> Bool { return a >= 0 && a >= Int(b); }
	
	static func + (a: Rational, b: Rational) -> Rational { return Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator); }
	static func - (a: Rational, b: Rational) -> Rational { return Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator); }
	static func * (a: Rational, b: Rational) -> Rational { return Rational(a.numerator*b.numerator,a.denominator*b.denominator); }

	static func / (a: Rational, b: Rational) -> Rational {
		return b.numerator >= 0
			? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
			: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
	}
	static prefix func - (a: Rational) -> Rational { return Rational(-a.numerator,a.denominator); }

	static func + (a: Rational, b: Int) -> Rational { return Rational(a.numerator+b*a.denominator,a.denominator); }
	static func - (a: Rational, b: Int) -> Rational { return Rational(a.numerator-b*a.denominator,a.denominator); }
	static func * (a: Rational, b: Int) -> Rational { return Rational(a.numerator*b,a.denominator); }

	static func / (a: Rational, b: Int) -> Rational {
		return b >= 0
			? Rational(a.numerator,a.denominator*b)
			: Rational(-a.numerator,-a.denominator*b);
	}

	static func += ( a: inout Rational, b: Rational) { a = Rational(a.numerator*b.denominator+b.numerator*a.denominator,a.denominator*b.denominator); }
	static func -= ( a: inout Rational, b: Rational) { a = Rational(a.numerator*b.denominator-b.numerator*a.denominator,a.denominator*b.denominator); }
	static func *= (a: inout Rational, b: Rational) { a = Rational(a.numerator*b.numerator,a.denominator*b.denominator); }

	static func /= ( a: inout Rational, b: Rational) {
		a = b.numerator >= 0
			? Rational(a.numerator*b.denominator,a.denominator*b.numerator)
			: Rational(-a.numerator*b.denominator,-a.denominator*b.numerator);
	}

	static func += ( a: inout Rational, b: Int) { a = Rational(a.numerator+b*a.denominator,a.denominator); }
	static func -= ( a: inout Rational, b: Int) { a = Rational(a.numerator-b*a.denominator,a.denominator); }
	static func *= ( a: inout Rational, b: Int) { a = Rational(a.numerator*b,a.denominator); }

	static func /= ( a: inout Rational, b: Int) {
		a = b >= 0
			? Rational(a.numerator,a.denominator*b)
			: Rational(-a.numerator,-a.denominator*b);
	}

	static func sum( anArray: [Rational] ) -> Rational {
		var			theResultNum = 0,
					theResultDen = 1;
		for theTerm in anArray {
			theResultNum = theResultNum*theTerm.denominator+theTerm.numerator*theResultDen;
			theResultDen *= theTerm.denominator
		}
		return Rational( theResultNum, theResultDen );
	}
}

extension String {
	func toRational() -> Rational? {
		var		theResult : Rational? = nil;
		let		theComponents = components(separatedBy: CharacterSet(charactersIn: ":/"));
		switch theComponents.count {
		case 0:
			theResult = Rational();
		case 1:
			if let theInt = Int(theComponents[0]) {
				theResult = Rational( theInt );
			}
		default:
			if let theNum = Int(theComponents[0]),
				let theDenom = Int(theComponents[0]) {
				theResult = Rational( theNum, theDenom );
			}
		}
		return theResult;
	}
}


