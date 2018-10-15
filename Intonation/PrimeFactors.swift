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

			if a != nil && b != nil {
				if a!.factor < b!.factor {
					theResult.append(a!);
					a = nil;
				} else if a!.factor > b!.factor {
					theResult.append((factor:b!.factor,power:-b!.power));
					b = nil;
				} else {
					theResult.append((factor:a!.factor,power:a!.power-b!.power));
					a = nil;
					b = nil;
				}
			} else if a != nil && b == nil {
				theResult.append(a!);
				a = nil;
			} else if a == nil && b != nil {
				theResult.append((factor:b!.factor,power:-b!.power));
				b = nil;
			} else {
				theComplete = true;
			}
		}

		return theResult;
	}
}
