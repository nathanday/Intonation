//
//  LimitsBasedGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 12/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class LimitsBasedGenerator : IntervalsDataGenerator {
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	override var	everyEntry : [EqualTemperamentEntry] {
		get {
			if _everyEqualTemperamentEntry == nil {
				var		theResult = Set<EqualTemperamentEntry>();
				for theDenom in PrimeProducts(maxPrime: limits.denominatorPrime, range: 1..<limits.odd) {
					for theNum in PrimeProducts(maxPrime: limits.numeratorPrime, range: theDenom..<theDenom*2) {
						if theNum+theDenom <= limits.additiveDissonance {
							assert(theNum >= theDenom);
							assert( theNum <= theDenom*2 );
							for theOctaves in 0..<octaves {
								let		theRational = Rational(theNum*1<<theOctaves,theDenom);
								let		theEntry = EqualTemperamentEntry(interval: theRational, intervalCount:intervalCount, maximumError: maximumError);
								if theEntry.isClose || !filtered {
									theResult.insert(theEntry);
								}
								if let theDegree = Scale.major.indexOf(theRational) {
									theEntry.degreeName = Scale.degreeName(theDegree);
								}
							}
						}
					}
				}
				_everyEqualTemperamentEntry = theResult.sort({ return $0.justIntonationCents < $1.justIntonationCents; } );
			}
			return _everyEqualTemperamentEntry!;
		}
	}
	var limits : (numeratorPrime:UInt,denominatorPrime:UInt,odd:UInt,additiveDissonance:UInt);
	var maximumError : Double;
	var intervalCount : UInt;
	var filtered : Bool;

	init( intervalsData anIntervalsData : IntervalsData ) {
		let		theDenominatorPrimeLimit = anIntervalsData.separatePrimeLimit ? anIntervalsData.denominatorPrimeLimit : anIntervalsData.numeratorPrimeLimit;
		limits = (numeratorPrime:anIntervalsData.numeratorPrimeLimit, denominatorPrime:theDenominatorPrimeLimit, odd:anIntervalsData.oddLimit, additiveDissonance:anIntervalsData.additiveDissonance);
		intervalCount = anIntervalsData.enableInterval ? anIntervalsData.intervalCount : 0;
		maximumError = anIntervalsData.maximumError;
		filtered = anIntervalsData.filtered;
		super.init();
		octaves = anIntervalsData.octavesCount;
	}
	override var description: String {
		return "entries:\(everyEntry.debugDescription)";
	}
}