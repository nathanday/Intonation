//
//  PrimeFactors.swift
//  Intonation
//
//  Created by Nathaniel Day on 27/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Foundation

struct PrimeFactors<T : BinaryInteger> : Sequence, IteratorProtocol {
	let		value : T;
	var		valueDelta : T;
	var		factor : T;
	var		complete = false;

	init(value aValue:T) {
		value = aValue;
		factor = 2;
		valueDelta = value;
	}

	mutating func next() -> (factor:T,power:Int)? {
		var		theResult : (factor:T,power:Int)?;
		if complete {
			return nil;
		}
		while factor <= valueDelta / factor && theResult == nil {
			var		p = 0;
			while (valueDelta % factor == 0) {
				p += 1;
				valueDelta /= factor;
			}
			if p > 0 {
				theResult = (factor, p);
			}
			factor += 1;
		}
		if theResult == nil && valueDelta > 1 {
			theResult = (T(valueDelta),1);
			complete = true;
		}
		return theResult;
	}

	static public func factors( numerator aNumerator : T, denominator aDenominator: T ) -> [(factor:T,power:Int)] {
		var		theResult = [(factor:T,power:Int)]();
		var		theNumerator = PrimeFactors(value:aNumerator);
		var		theDenominator = PrimeFactors(value:aDenominator);
		var 	theComplete = false;
		var		a : (factor:T,power:Int)?;
		var		b : (factor:T,power:Int)?;
		while theComplete == false {
			if a == nil {
				a = theNumerator.next();
			}
			if b == nil {
				b = theDenominator.next();
			}

			if let theA = a, let theB = b {
				if theA.factor < theB.factor {
					theResult.append(theA);
					a = nil;
				} else if theA.factor > theB.factor {
					theResult.append((factor:theB.factor,power:-theB.power));
					b = nil;
				} else {
					theResult.append((factor:theA.factor,power:a!.power-theB.power));
					a = nil;
					b = nil;
				}
			} else if let theA = a, b == nil {
				theResult.append(theA);
				a = nil;
			} else if let theB = b, a == nil {
				theResult.append((factor:theB.factor,power:-theB.power));
				b = nil;
			} else {
				theComplete = true;
			}
		}

		return theResult;
	}
}
