//
//  HarmonicSeriesGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class HarmonicSeriesIntervalsData : IntervalsData {
	static let		octaveKey = "harmonicSeries_octave";

	override init() {
		octave = UserDefaults.standard.integer(forKey: HarmonicSeriesIntervalsData.octaveKey);
		if( octave <= 0 ) {
			octave = 4;
		}
		super.init();
	}
	override init?(propertyList aPropertyList: [String:Any] ) {
		guard let theProperties = aPropertyList["harmonicSeries"] as? [String:Any] else {
			return nil;
		}
		if let theOctave = theProperties["octave"] as? Int {
			octave = theOctave;
		} else {
			octave = UserDefaults.standard.integer(forKey: HarmonicSeriesIntervalsData.octaveKey);
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

	override var	documentType : DocumentType { return .harmonicSeries; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return HarmonicSeriesGenerator(intervalsData:self);
	}

	@objc dynamic var		octave : Int {
		willSet {
			willChangeValue(forKey: "octave");
		}
		didSet {
			UserDefaults.standard.set(octave, forKey:HarmonicSeriesIntervalsData.octaveKey);
			didChangeValue(forKey: "octave");
		}
	}
}

class HarmonicSeriesGenerator: IntervalsDataGenerator {
	let		octave : Int;

	var	_everyIntervalEntry : [IntervalEntry]?;
	override var	everyEntry : [IntervalEntry] {
		return _everyIntervalEntry ?? [IntervalEntry]();
	}
	init( intervalsData anIntervalsData : HarmonicSeriesIntervalsData ) {
		octave = anIntervalsData.octave;
		super.init(intervalsData:anIntervalsData);
		var		theIntervals = [IntervalEntry]();
		let		theMin = 1<<(octave-1);
		let		theMax = 1<<(octave-1+octavesCount);
		for theIndex in theMin...theMax {
			theIntervals.append(IntervalEntry(interval: RationalInterval( theIndex, theMin )))
		}

		_everyIntervalEntry = theIntervals;
	}
}
