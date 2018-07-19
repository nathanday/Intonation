/*
	UInt+Additions.swift
	Intonation

	Created by Nathan Day on 4/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

extension UInt {
	var hexadecimalString : String { return String(format: "%x", self ); }

	func isFactorOf(_ factor: UInt) -> Bool { return self % factor == 0; }
	func isFactorOf(_ factors: CountableClosedRange<UInt>) -> Bool {
		for a in factors {
			if a > sqrt(self) {
				return false;
			}
			if isFactorOf(a) {
				return true;
			}
		}
		return false;
	}

	var isPrime : Bool {
		return self > 1 && (self <= 3 || !isFactorOf(2...sqrt(self)));
	}
	var everyPrimeFactor : [(factor:UInt,power:Int)] {
		var		theResult : [(factor:UInt,power:Int)];
		switch self {
		case 0:
			theResult = [];
		case 1:
			theResult = [];
		default:
			theResult = [];
			for thePrime in PrimesSequence(end:self) {
				let thePower = Int(factorCount(thePrime));
				if thePower > 0 {
					theResult.append((factor:thePrime,power:thePower));
				}
			}
		}
		return theResult;
	}
	var superScriptString : String {
		get {
			var		theResult = "";
			if self > 0 {
				let		digits = "⁰¹²³⁴⁵⁶⁷⁸⁹";
				var		theValue = Int(self);
				while theValue > 0 {
					let		theIndex = digits.index(digits.startIndex, offsetBy: (theValue%10));
					theResult = "\(digits[theIndex])\(theResult)";
					theValue /= 10;
				}
			}
			else {
				theResult = "⁰";
			}
			return theResult;
		}
	}

	func factorCount(_ factor: UInt) -> UInt {
		var		theResult : UInt = 0;
		var		theValue = self;
		while theValue.isFactorOf(factor) {
			theValue /= factor;
			theResult = theResult + 1;
		}
		return theResult;
	}
	var largestPrimeFactor : UInt {
		if self > 3 {
			for factor in 2...sqrt(self) {
				if isFactorOf(factor) { return (self/factor).largestPrimeFactor; }
			}
		}
		return self
	}
	var factorsString : String {
		get {
			var		theResult = "";
			for theFact in everyPrimeFactor {
				if theResult.startIndex != theResult.endIndex {
//                    theResult.append(Character("⋅"));
                    theResult.append(Character("⨯"));
				}
				theResult.append("\(theFact.factor)");
				if theFact.power > 1 {
					theResult.append("\(UInt(theFact.power).superScriptString)");
				}
			}
			return theResult;
		}
	}
}

extension Rational {
	var					toCents:		Double { return Double(self).toCents; }

	public var factorsString : String {
		return "\(UInt(numerator).factorsString)∶\(UInt(denominator).factorsString)";
	}
}

func pow<T : BinaryInteger, U : UnsignedInteger>( _ a: T, _ b: U ) -> T {
	return b == 0
		? 1
		: (b&0b1 == 1 ? a : 1) * pow(a,b>>1) * pow(a,b>>1);
}

func sqrt<T : BinaryInteger>( _ n : T ) -> T {
	return T(sqrt(Double(n)));
}

func log2<T : UnsignedInteger>( _ n : T ) -> T {
	return n < 2 ? T(0) : 1 + log2(n>>1);
}

func log10<T : UnsignedInteger>( _ n : T ) -> T {
	return n < 10 ? T(0) : 1 + log10(n/10);
}

//func greatestCommonDivisor<T : UnsignedInteger>(_ u: [T] ) -> T? {
//	var		theResult : T?;
//	for theNumber in u {
//		if let thePrevious = theResult {
//			theResult = greatestCommonDivisor(thePrevious, theNumber);
//		} else {
//			theResult = theNumber;
//		}
//	}
//	return theResult;
//}
//
func bitCount<T : UnsignedInteger>( _ x : T) -> Int {
	return x == 0 ? 0 : ((x&T(0x1)) == 1 ? 1 : 0) + bitCount(x>>1);
}
