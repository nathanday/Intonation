//
//  AdHocGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 14/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class AdHocIntervalsData : IntervalsData {
	override init() {
		adHocEntries = Set<Interval>();
		super.init();
	}
	override init?(propertyList aPropertyList: [String:AnyObject] ) {
		adHocEntries = Set<Interval>();
		if let theOddLimit = aPropertyList["adHoc"] as? [String] {
			for theEntityString in theOddLimit {
				if let theInterval = Interval.fromString(theEntityString) {
					adHocEntries.insert(theInterval);
				}
			}
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:AnyObject] {
		var		theResult = super.propertyListValue;
		var		theEntires = [String]();
		for theInterval in adHocEntries {
			theEntires.append(theInterval.toString)
		}
		theResult["adHoc"] = theEntires;
		return theResult;
	}

	override var	documentType : DocumentType { return .AdHoc; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return AdHocGenerator(intervalsData:self);
	}

	var		adHocEntries : Set<Interval>;

	func addInterval( anInterval : Interval ) {
		addIntervals( [anInterval] );
	}
	func addIntervals( anIntervals : [Interval] ) {
		for theInterval in anIntervals {
			adHocEntries.insert(theInterval);
		}
//		calculateAllIntervals();
	}

	func removeInterval( anInterval : Interval ) {
		removeIntervals( [anInterval] );
	}
	func removeIntervals( anIntervals : [Interval] ) {
		for theInterval in anIntervals {
			adHocEntries.remove(theInterval);
		}
//		calculateAllIntervals();
	}
}

class AdHocGenerator: IntervalsDataGenerator {
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	override var everyEntry : [EqualTemperamentEntry] {
		return _everyEqualTemperamentEntry!;
	}
	init( intervalsData anIntervalsData : AdHocIntervalsData ) {
		var		theResult = Set<EqualTemperamentEntry>();
		super.init();
		for theOctave in 0..<anIntervalsData.octavesCount {
			let		theOctaveValue = (1<<theOctave);
			for theEntry in anIntervalsData.adHocEntries {
				theResult.insert(EqualTemperamentEntry(interval: theEntry*theOctaveValue ));
			}
		}
		_everyEqualTemperamentEntry = theResult.sort { return $0.toCents < $1.toCents; };
	}
}
