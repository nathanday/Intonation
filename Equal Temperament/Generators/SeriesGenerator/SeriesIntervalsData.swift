//
//  SeriesGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class SeriesIntervalsData : IntervalsData {
	override init() {
		octave = UserDefaults.standard.integer(forKey: "octave");
		if( octave == 0 ) {
			octave = 12;
		}
		super.init();
	}
	override init?(propertyList aPropertyList: [String:Any] ) {
		guard let theProperties = aPropertyList["equalTemperament"] as? [String:String] else {
			return nil;
		}
		if let theDegreesString = theProperties["octave"] {
			octave = Int(theDegreesString) ?? 12;
		} else {
			octave = UserDefaults.standard.integer(forKey: "octave");
			if( octave == 0 ) {
				octave = 4;
			}
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:Any] {
		var		theResult = super.propertyListValue;
		theResult["octave"] = octave;
		return theResult;
	}

	override var	documentType : DocumentType { return .equalTemperament; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return SeriesGenerator(intervalsData:self);
	}
	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return SeriesGeneratorViewController(windowController:aWindowController);
	}

	@objc dynamic var		octave : Int {
		didSet {
			UserDefaults.standard.set(octave, forKey:"octave");
		}
	}
}

class SeriesGenerator: IntervalsDataGenerator {
	let		octave : Int;

	var	_everyIntervalEntry : [IntervalEntry]?;
	override var	everyEntry : [IntervalEntry] {
		return _everyIntervalEntry!;
	}
	init( intervalsData anIntervalsData : SeriesIntervalsData ) {
		octave = anIntervalsData.octave;
		super.init();
		var		theIntervals = [IntervalEntry]();
		let		theMin = 1<<(octave-1);
		let		theMax = 1<<octave;
		for theIndex in theMin...theMax {
			theIntervals.append(IntervalEntry(interval: RationalInterval( theIndex, theMin )))
		}

		_everyIntervalEntry = theIntervals;
	}
}
