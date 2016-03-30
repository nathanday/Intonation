//
//  StackedIntervalsDataGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class StackedIntervalsIntervalsData : IntervalsData {
	override init() {
		// XXXXX
		super.init();
	}
	override init?(propertyList aPropertyList: [String:AnyObject] ) {
		// XXXXX
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:AnyObject] {
		var		theResult = super.propertyListValue;
		// XXXXX
		return theResult;
	}

	override var	documentType : DocumentType { return .StackedIntervals; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return StackedIntervalsDataGenerator(intervalsData:self);
	}

	var		stackedIntervals = Set<StackedIntervalSet>();

	func insertStackedInterval( a : StackedIntervalSet ) {
		stackedIntervals.insert(a);
	}

	func removeStackedInterval( a : StackedIntervalSet ) {
		stackedIntervals.remove(a);
	}
}

class StackedIntervalsDataGenerator: IntervalsDataGenerator {
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	override var	everyEntry : [EqualTemperamentEntry] {
		return _everyEqualTemperamentEntry!;
	}
	init( intervalsData anIntervalsData : StackedIntervalsIntervalsData ) {
		super.init();
		var		theResult = Set<EqualTemperamentEntry>();
		for theOctave in 0..<anIntervalsData.octavesCount {
			let		theOctaveValue = 1<<theOctave;
			for theStackInterval in anIntervalsData.stackedIntervals {
				for theInterval in theStackInterval.everyInterval {
					let		theEntry = EqualTemperamentEntry(interval: theInterval*theOctaveValue );
					theResult.insert(theEntry);
				}
			}
		}
		_everyEqualTemperamentEntry = theResult.sort { return $0.toCents < $1.toCents; };
	}
}
