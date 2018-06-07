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
		steps = UInt(UserDefaults.standard.integer(forKey: "steps"));
		if( steps == 0 ) {
			steps = 12;
		}
		stepSize = UserDefaults.standard.double(forKey:"stepSize");
		if stepSize == 0.0 {
			stepSize = 1.0;
		}
		super.init();
	}
	override init?(propertyList aPropertyList: [String:Any] ) {
		guard let theProperties = aPropertyList["equalTemperament"] as? [String:String] else {
			return nil;
		}
		if let theDegreesString = theProperties["steps"] {
			steps = UInt(theDegreesString) ?? 12;
		} else {
			steps = UInt(UserDefaults.standard.integer(forKey: "steps"));
			if( steps == 0 ) {
				steps = 12;
			}
		}
		if let theStepSize = theProperties["stepSize"] {
			stepSize = Double(theStepSize) ?? 1.0;
		} else {
			stepSize = UserDefaults.standard.double(forKey:"stepSize");
			if stepSize == 0.0 {
				stepSize = 1.0;
			}
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:Any] {
		var		theResult = super.propertyListValue;
		theResult["limits"] = [
			"steps":"\(steps)",
			"stepSize":stepSize.toString];
		return theResult;
	}

	override var	documentType : DocumentType { return .equalTemperament; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return SeriesGenerator(intervalsData:self);
	}
	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return SeriesGeneratorViewController(windowController:aWindowController);
	}

	@objc dynamic var		steps : UInt {
		didSet {
			UserDefaults.standard.set(Int(steps), forKey:"steps");
		}
	}
	var				stepSize : Double {
		didSet {
			UserDefaults.standard.set(stepSize, forKey:"interval");
		}
	}
}

class SeriesGenerator: IntervalsDataGenerator {
	let		stepSize : Double;
	let		steps : UInt;

	func ratioFor( note aNote: UInt ) -> Double {
		return 1.0+stepSize*Double(aNote);
	}
	func formulaStringFor( note aNote: UInt ) -> String {
		return "\(stepSize)^(\(aNote)/\(steps))";
	}
	var	_everyIntervalEntry : [IntervalEntry]?;
	override var	everyEntry : [IntervalEntry] {
		return _everyIntervalEntry!;
	}
	init( intervalsData anIntervalsData : SeriesIntervalsData ) {
		stepSize = anIntervalsData.stepSize;
		steps = anIntervalsData.steps;
		super.init();
		var		theResult = Set<IntervalEntry>();
		var		theIndex : UInt = 0;
		var		theRatio = ratioFor(note:theIndex);
		let		theMaxRatio = pow(2.0,Double(anIntervalsData.octavesCount));
		while theRatio <= theMaxRatio {
			let		theString = formulaStringFor(note:theIndex);
			let		theInterval = IrrationalInterval( ratio: theRatio, names: [theString], factorsString: nil );
			let		theEntry = IntervalEntry(interval: theInterval);
			theResult.insert(theEntry);
			theIndex += 1;
			theRatio = ratioFor(note:theIndex);
		}

		_everyIntervalEntry = theResult.sorted { return $0.toCents < $1.toCents; };
	}
}
