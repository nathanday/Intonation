//
//  UInt+Additions.swift
//  Equal Temperament
//
//  Created by Nathan Day on 4/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Foundation

extension UInt {
	func isFactorOf(factor: UInt) -> Bool { return self % factor == 0; }
	func isFactorOf(factors: Range<UInt>) -> Bool {
		for a in factors {
			if self.isFactorOf(a) { return true; }
		}
		return false;
	}
	var largestPossibleFactor : UInt {
		let squareRoot = sqrt(Double(self))
		return UInt(floor(squareRoot))
	}
	var largestPrimeFactor : UInt {
		if self > 3 {
			for factor in 2...self.largestPossibleFactor {
				if self.isFactorOf(factor) { return (self/factor).largestPrimeFactor; }
			}
		}
		return self
	}
	var isPrime : Bool { return self > 1 && (self <= 3 || !self.isFactorOf(UInt(2)...self.largestPossibleFactor)); }
	static func primes(upTo anUpTo: UInt) -> [UInt] {
		var		theResult = [UInt(2)];
		if anUpTo > 2 {
			for a in 3...anUpTo {
				var		theIsPrime = true;
				for p in theResult {
					if( p*p > a ) {
						theResult.append(a);
						break;
					}
					else if a%p == 0 {
						break;
					}
				}
			}
		}
		return theResult;
	}
}

func greatestCommonDivisor(u: [Int] ) -> Int {
	var		theResult = 1;
	for theNumber in u {
		theResult = greatestCommonDivisor(theResult, theNumber);
	}
	return theResult;
}

func greatestCommonDivisor(u: Int, v: Int) -> Int {
	// simple cases (termination)
	if u == v { return u; }
	if u == 0 { return v; }
	if v == 0 { return u; }
	
	// look for factors of 2
	if (~u & 0b1) != 0 {  // u is even
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

