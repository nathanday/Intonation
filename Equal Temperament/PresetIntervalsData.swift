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
//		XXXXX
		super.init();
	}
	override init?(propertyList aPropertyList: [String:AnyObject] ) {
		if let theProperties = aPropertyList["preset"] as? [String:String] {
			presetName = theProperties["name"];
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:AnyObject] {
		var		theResult = super.propertyListValue;
		if let theName = presetName {
			theResult["preset"] = ["name":theName];
		}
		return theResult;
	}

	override var	documentType : DocumentType { return .Preset; }

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
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	override var everyEntry : [EqualTemperamentEntry] {
		return _everyEqualTemperamentEntry!;
	}
	init( intervalsData anIntervalsData : PresetIntervalsData ) {
		var		theResult = Set<EqualTemperamentEntry>();
		if let theIntervals = anIntervalsData.intervals {
			for theInterval in theIntervals {
				let	theOctavesCount = anIntervalsData.octavesCount + (theInterval == 1 ? 1 : 0);
				for theOctave in 0..<theOctavesCount {
					let		theOctaveValue = 1<<theOctave;
					let		theEntry = EqualTemperamentEntry(interval: theInterval*theOctaveValue );
					theResult.insert(theEntry);
				}
			}
		}
		super.init();
		_everyEqualTemperamentEntry = theResult.sort { return $0.toCents < $1.toCents; };
	}
}
