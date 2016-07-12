/*
	PrimeProducts.swift
	Intonation

	Created by Nathan Day on 1/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct PrimeProducts : Sequence {
	let		maxPrime : UInt;
	let		productRange : Range<UInt>;

	init( maxPrime aMaxPrime: UInt, range aRange: Range<UInt> ) {
		maxPrime = aMaxPrime;
		productRange = aRange;
	}

	func makeIterator() -> AnyIterator<UInt> {
		var		value : UInt = productRange.lowerBound - 1;
		return AnyIterator {
			repeat {
				value += 1;
				if value > self.productRange.upperBound { return nil; }
			} while value.largestPrimeFactor > self.maxPrime;
			return value;
		}
	}
}
