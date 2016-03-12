//
//  LimitsBasedGenerator.swift
//  Equal Temperament
//
//  Created by Nathan Day on 12/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class LimitsBasedGenerator : IntervalsDataGenerator {
	var	_everyEqualTemperamentEntry : Set<EqualTemperamentEntry>?;
	var	everyEqualTemperamentEntry : Set<EqualTemperamentEntry> {
		get {
			if _everyEqualTemperamentEntry == nil {
				var		theResult = Set<EqualTemperamentEntry>();
				for theDenom in PrimeProducts(maxPrime: limits.denominatorPrime, range: 1..<limits.odd) {
					for theNum in PrimeProducts(maxPrime: limits.numeratorPrime, range: theDenom..<theDenom*2) {
						if theNum+theDenom <= limits.additiveDissonance {
							assert(theNum >= theDenom);
							assert( theNum <= theDenom*2 );
							for theOctaves in 0..<octaves {
								let		theEntry = EqualTemperamentEntry(numberator: theNum*1<<theOctaves, denominator:theDenom, intervalCount:intervalCount, maximumError: maximumError);
								let		theDegree = Scale.major.indexOf(theEntry.justIntonationRatio);
								if theEntry.isClose || !filtered {
									theResult.insert(theEntry);
								}
								if theDegree != nil {
									theEntry.degreeName = Scale.degreeName(theDegree!);
								}
							}
						}
					}
				}
				_everyEqualTemperamentEntry = theResult;
			}
			return _everyEqualTemperamentEntry!;
		}
	}
	var limits : (numeratorPrime:UInt,denominatorPrime:UInt,odd:UInt,additiveDissonance:UInt);
	var maximumError : Double;
	var intervalCount : UInt;
	var octaves : UInt;
	var filtered : Bool;

	var averageError : Double {
		var		theAverageError : Double = 0.0;
		let		theCount = Double(everyEqualTemperamentEntry.count);
		for theEntry in everyEqualTemperamentEntry {
			theAverageError += abs(theEntry.error12ETCent);
		}
		return theAverageError/theCount
	}

	var smallestError : Set<EqualTemperamentEntry> {
		var		theResult = Set<EqualTemperamentEntry>();
		var		theError = 0.0;
		for theEntry in everyEqualTemperamentEntry {
			if !theEntry.isOctave && !theEntry.isUnison {
				if theResult.isEmpty {
					theError = abs(theEntry.error12ETCent);
					theResult = [theEntry];
				} else {
					if abs(theError.distanceTo(abs(theEntry.error12ETCent))) < 0.000001 {
						theResult.insert(theEntry);
					}
					else if theError > abs(theEntry.error12ETCent) {
						theError = abs(theEntry.error12ETCent);
						theResult = [theEntry];
					}
				}
			}
		}
		return theResult;
	}

	var biggestError : Set<EqualTemperamentEntry> {
		var		theResult = Set<EqualTemperamentEntry>();
		var		theError = 0.0;
		for theEntry in everyEqualTemperamentEntry {
			if !theEntry.isOctave && !theEntry.isUnison {
				if theResult.isEmpty {
					theError = abs(theEntry.error12ETCent);
					theResult = [theEntry];
				} else {
					if abs(theError.distanceTo(abs(theEntry.error12ETCent))) < 0.000001 {
						theResult.insert(theEntry);
					}
					else if theError < abs(theEntry.error12ETCent) {
						theError = abs(theEntry.error12ETCent);
						theResult = [theEntry];
					}
				}
			}
		}
		return theResult;
	}

	init( intervalsData anIntervalsData : IntervalsData ) {
		let		theDenominatorPrimeLimit = anIntervalsData.separatePrimeLimit ? anIntervalsData.denominatorPrimeLimit : anIntervalsData.numeratorPrimeLimit;
		limits = (numeratorPrime:anIntervalsData.numeratorPrimeLimit, denominatorPrime:theDenominatorPrimeLimit, odd:anIntervalsData.oddLimit, additiveDissonance:anIntervalsData.additiveDissonance);
		intervalCount = anIntervalsData.enableInterval ? anIntervalsData.intervalCount : 0;
		maximumError = anIntervalsData.maximumError;
		filtered = anIntervalsData.filtered;
		octaves = anIntervalsData.octavesCount;
	}
	var everyEntry : [EqualTemperamentEntry] {
		get {
			var		theResult = Array<EqualTemperamentEntry>();
			for theEntry in everyEqualTemperamentEntry {
				theResult.append(theEntry as EqualTemperamentEntry);
			}
			theResult.sortInPlace({ return $0.justIntonationCents < $1.justIntonationCents; } );
			return theResult;
		}
	}

	var description: String {
		return "entries:\(everyEqualTemperamentEntry.debugDescription)";
	}
}