/*
	PrimeProducts.swift
	Equal Temperament

	Created by Nathan Day on 1/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct PrimeProducts : SequenceType {
	let		maxPrime : UInt;
	let		productRange : Range<UInt>;

	init( maxPrime aMaxPrime: UInt, range aRange: Range<UInt> ) {
		let		thePrimes = UInt.primes(upTo:aMaxPrime);
		maxPrime = thePrimes.last!;
		productRange = aRange;
	}

	func generate() -> AnyGenerator<UInt> {
		var		value : UInt = productRange.startIndex - 1;
		return anyGenerator {
			repeat {
				value += 1;
				if value > self.productRange.endIndex { return nil; }
			} while value.largestPrimeFactor > self.maxPrime;
			return value;
		}
	}
}
