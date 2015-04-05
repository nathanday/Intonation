//
//  PrimeProducts.swift
//  Equal Temperament
//
//  Created by Nathan Day on 1/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Foundation

struct PrimeProducts : SequenceType {
	
	let		maxPrime : UInt;
	let		productRange : Range<UInt>;
	
	init( maxPrime aMaxPrime: UInt, range aRange: Range<UInt> ) {
		let		thePrimes = UInt.primes(upTo:aMaxPrime);
		maxPrime = thePrimes.last!;
		productRange = aRange;
	}
	
	func generate() -> GeneratorOf<UInt> {
		var		value = productRange.startIndex-1;
		return GeneratorOf<UInt> {
			do {
				value++;
				if value > self.productRange.endIndex { return nil; }
			} while value.largestPrimeFactor > self.maxPrime;
			return value;
		}
	}
}
