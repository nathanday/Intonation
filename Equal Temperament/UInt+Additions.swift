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

