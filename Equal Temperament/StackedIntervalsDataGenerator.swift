//
//  StackedIntervalsDataGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class StackedIntervalsDataGenerator: IntervalsDataGenerator {
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	var	stackedIntervals : Set<StackedIntervalSet>;
	var degree : UInt;
	override var	everyEntry : [EqualTemperamentEntry] {
		get {
			if _everyEqualTemperamentEntry == nil {
				var		theResult = Set<EqualTemperamentEntry>();
				for theStackInterval in stackedIntervals {
					for theInterval in theStackInterval.everyInterval {
						let		theEntry = EqualTemperamentEntry(interval: theInterval );
						theResult.insert(theEntry);
					}
				}
				_everyEqualTemperamentEntry = theResult.sort({ return $0.justIntonationCents < $1.justIntonationCents; } );
			}
			return _everyEqualTemperamentEntry!;
		}
	}
	init( intervalsData anIntervalsData : IntervalsData ) {
		stackedIntervals = anIntervalsData.stackedIntervals;
		degree = 12;
	}
	override var description: String {
		return "entries:\(everyEntry.debugDescription)";
	}

}
