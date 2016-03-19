//
//  AdHocGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 14/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class AdHocGenerator: IntervalsDataGenerator {
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	override var everyEntry : [EqualTemperamentEntry] {
		return _everyEqualTemperamentEntry ?? [];
	}
	init( intervalsData anIntervalsData : IntervalsData ) {
		var		theEveryEqualTemperamentEntry = [EqualTemperamentEntry]();
		for theEntry in anIntervalsData.adHocEntries {
			theEveryEqualTemperamentEntry.append(EqualTemperamentEntry(interval: theEntry, intervalCount: 12, maximumError: 18.0));
		}
		_everyEqualTemperamentEntry = theEveryEqualTemperamentEntry;
		super.init();
		octaves = anIntervalsData.octavesCount;
	}

}
