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
	var everyPrimeFactor : [(factor:UInt,power:UInt)] {
		var		theResult : [(factor:UInt,power:UInt)];
		switch self {
		case 0:
			theResult = [];
		case 1:
			theResult = [(factor:1,power:1)];
		default:
			theResult = [];
			for thePrime in PrimesSequence(end:self) {
				let thePower = factorCount(thePrime);
				if thePower > 0 {
					theResult.append((factor:thePrime,power:thePower));
				}
			}
		}
		return theResult;
	}
	var largestPrimeLessThanOrEqualTo : UInt {
		var		theResult = self;
		while theResult > 3 && largestPrimeFactor < theResult {
			theResult = theResult - 1;
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
					theResult.append("\(theFact.power.superScriptString)");
				}
			}
			return theResult;
		}
	}
}

func pow<T : BinaryInteger, U : UnsignedInteger>( _ a: T, _ b: U ) -> T {
	if b == 0  {
		return 1
	} else {
		return (b&0b1 == 1 ? a : 1) * pow(a,b>>1) * pow(a,b>>1);
	}
}

func sqrt<T : BinaryInteger>( _ n : T ) -> T {
	return T(sqrt(Double(n)));
}

func log2<T : BinaryInteger>( _ aValue : T ) -> T {
	if aValue == 0 {
		return UInt(0) as! T;
	} else {
		return 1 + log2(aValue / 2);
	}
}

func greatestCommonDivisor<T : BinaryInteger>(_ u: [T] ) -> T {
	var		theResult : T = 1;
	for theNumber in u {
		theResult = greatestCommonDivisor(theResult, theNumber);
	}
	return theResult;
}

func greatestCommonDivisor<T : BinaryInteger>(_ u: T, _ v: T) -> T {
	// simple cases (termination)
	if u == v { return u; }
	if u == 0 { return v; }
	if v == 0 { return u; }

	// look for factors of 2
	if (~u & 0b1) != 0 {  // u is even
		if (v & 0b1) != 0 {		// v is odd
			return greatestCommonDivisor(u / 2, v);
		}
		else { // both u and v are even
			return greatestCommonDivisor(u / 2, v / 2) * 2;
		}
	}

	if (~v & 0b1) != 0 { return greatestCommonDivisor(u, v / 2); } // u is odd, v is even

	// reduce larger argument
	if u > v { return greatestCommonDivisor((u - v) / 2, v); }

	return greatestCommonDivisor((v - u) / 2, u);
}

func bitCount<T : BinaryInteger>( _ x : T) -> Int {
	var		theX = x;
	var		theCount = 0;
	while theX > 0 {
		if theX & T(0x1) == 1 { theCount += 1; }
		theX >>= 1;
	}
	return theCount;
}
