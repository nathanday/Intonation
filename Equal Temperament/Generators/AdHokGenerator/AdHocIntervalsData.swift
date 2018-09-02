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
	override init?(propertyList aPropertyList: [String:Any] ) {
		adHocEntries = Set<Interval>();
		guard let theOddLimit = aPropertyList["adHoc"] as? [String] else {
			return nil;
		}
		for theEntityString in theOddLimit {
			if let theInterval = Interval.from(string:theEntityString) {
				adHocEntries.insert(theInterval);
			}
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:Any] {
		var		theResult = super.propertyListValue;
		var		theEntires = [String]();
		for theInterval in adHocEntries {
			theEntires.append(theInterval.toString)
		}
		theResult["adHoc"] = theEntires;
		return theResult;
	}

	override var	documentType : DocumentType { return .adHoc; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return AdHocGenerator(intervalsData:self);
	}
	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return AdHokGeneratorViewController(windowController:aWindowController);
	}
	var		adHocEntries : Set<Interval>;

	func addInterval( _ anInterval : Interval ) {
		addIntervals( [anInterval] );
	}
	func addIntervals( _ anIntervals : [Interval] ) {
		for theInterval in anIntervals {
			adHocEntries.insert(theInterval);
		}
	}

	func removeInterval( _ anInterval : Interval ) {
		removeIntervals( [anInterval] );
	}
	func removeIntervals( _ anIntervals : [Interval] ) {
		for theInterval in anIntervals {
			adHocEntries.remove(theInterval);
		}
	}
}

class AdHocGenerator: IntervalsDataGenerator {
	var	_everyIntervalEntry : [IntervalEntry]?;
	override var everyEntry : [IntervalEntry] {
		return _everyIntervalEntry!;
	}
	init( intervalsData anIntervalsData : AdHocIntervalsData ) {
		var		theResult = Set<IntervalEntry>();
		super.init(intervalsData:anIntervalsData);
		for theOctave in 0..<octavesCount {
			let		theOctaveValue = (1<<theOctave);
			for theEntry in anIntervalsData.adHocEntries {
				theResult.insert(IntervalEntry(interval: theEntry*theOctaveValue ));
			}
		}
		_everyIntervalEntry = theResult.sorted { return $0.toRatio < $1.toRatio; };
	}
}
