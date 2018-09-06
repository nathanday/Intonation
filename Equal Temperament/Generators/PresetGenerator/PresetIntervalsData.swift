//
//  PresetGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 14/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class PresetIntervalsData : IntervalsData {
	override init() {
		super.init();
	}
	override init?(propertyList aPropertyList: [String:Any] ) {
		if let theProperties = aPropertyList["preset"] as? [String:String] {
			presetName = theProperties["name"];
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:Any] {
		var		theResult = super.propertyListValue;
		if let theName = presetName {
			theResult["preset"] = ["name":theName];
		}
		return theResult;
	}

	override var	documentType : DocumentType { return .preset; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return PresetGenerator(intervalsData:self);
	}
	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return PresetGeneratorViewController(windowController:aWindowController);
	}

	var		presetName : String?
	var		intervals : IntervalSet?;
}

class PresetGenerator: IntervalsDataGenerator {
	var	_everyIntervalEntry : [IntervalEntry]?;
	override var everyEntry : [IntervalEntry] {
		return _everyIntervalEntry!;
	}
	init( intervalsData anIntervalsData : PresetIntervalsData ) {
		var		theResult = Set<IntervalEntry>();
		if let theIntervals = anIntervalsData.intervals {
			for theInterval in theIntervals {
				let	theOctavesCount = anIntervalsData.octavesCount + (theInterval == 1 ? 1 : 0);
				for theOctave in 0..<theOctavesCount {
					let		theOctaveValue = 1<<theOctave;
					let		theEntry = IntervalEntry(interval: theInterval*theOctaveValue );
					theResult.insert(theEntry);
				}
			}
		}
		_everyIntervalEntry = theResult.sorted { return $0.toCents < $1.toCents; };
		super.init(intervalsData:anIntervalsData);
	}
}
