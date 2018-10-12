//
//  PrimesSequence.swift
//  Intonation
//
//  Created by Nathan Day on 14/05/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

class PrimesSequence : Sequence {
	static var		primes : [UInt] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67];
	var endAt: UInt

	init(end:UInt){ endAt = end }
	convenience init(){ self.init(end:UInt.max); }

	@discardableResult private func extendPrimes() -> UInt? {
		var		theResult : UInt? = nil;
		var		theTestValue = PrimesSequence.primes.last!;
		testValueLoop: while theResult == nil || theResult! < 4294967293 {
			theTestValue += 2;
			for p in PrimesSequence.primes {
				if( p*p > theTestValue ) {
					PrimesSequence.primes.append(theTestValue);
					theResult = theTestValue;
					break testValueLoop;
				}
				else if theTestValue%p == 0 {
					break;
				}
			}
		}
		return theResult;
	}

	func makeIterator() -> AnyIterator<UInt> {
		var iterationIndex = 0

		return AnyIterator({
			var		theResult : UInt? = nil;
			if iterationIndex >= PrimesSequence.primes.endIndex {
				self.extendPrimes()
			}

			if PrimesSequence.primes[iterationIndex] <= self.endAt {
				theResult = PrimesSequence.primes[iterationIndex];
				iterationIndex += 1;
			} else {
				theResult = nil;
			}
			return theResult;
		})
	}

	subscript(anIndex: Int) -> UInt {
		while PrimesSequence.primes.count <= anIndex {
			extendPrimes();
		}
		return PrimesSequence.primes[anIndex];
	}
	
}
