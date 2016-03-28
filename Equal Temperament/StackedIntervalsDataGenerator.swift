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
	var octave : UInt = 1;
	override var	everyEntry : [EqualTemperamentEntry] {
		get {
			if _everyEqualTemperamentEntry == nil {
				var		theResult = Set<EqualTemperamentEntry>();
				for theOctave in 0..<octave {
					let		theOctaveValue = 1<<theOctave;

					for theStackInterval in stackedIntervals {
						for theInterval in theStackInterval.everyInterval {
							let		theEntry = EqualTemperamentEntry(interval: theInterval*theOctaveValue );
							theResult.insert(theEntry);
						}
					}
				}
				_everyEqualTemperamentEntry = theResult.sort { return $0.toCents < $1.toCents; };
			}
			return _everyEqualTemperamentEntry!;
		}
	}
	init( intervalsData anIntervalsData : IntervalsData ) {
		stackedIntervals = anIntervalsData.stackedIntervals;
		octave = anIntervalsData.octavesCount;
	}
	override var description: String {
		return "entries:\(everyEntry.debugDescription)";
	}

}
