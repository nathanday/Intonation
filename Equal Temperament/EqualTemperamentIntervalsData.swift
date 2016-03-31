//
//  EqualTemperamentGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class EqualTemperamentIntervalsData : IntervalsData {
	override init() {
		degrees = UInt(NSUserDefaults.standardUserDefaults().integerForKey("degrees")) ?? 12;
		interval = NSUserDefaults.standardUserDefaults().rationalIntervalForKey("interval") ?? RationalInterval(2);
		super.init();
	}
	override init?(propertyList aPropertyList: [String:AnyObject] ) {
		if let theProperties = aPropertyList["equalTemperament"] as? [String:String] {
			if let theDegreesString = theProperties["degrees"] {
				degrees = UInt(theDegreesString) ?? 12;
			} else {
				degrees = UInt(NSUserDefaults.standardUserDefaults().integerForKey("degrees")) ?? 12;
			}
			if let theIntervalString = theProperties["interval"] {
				interval = RationalInterval.fromString(theIntervalString) ?? RationalInterval(2,1);
			} else {
				interval = NSUserDefaults.standardUserDefaults().rationalIntervalForKey("interval") ?? RationalInterval(2);
			}
		} else {
			degrees = UInt(NSUserDefaults.standardUserDefaults().integerForKey("degrees")) ?? 12;
			interval = NSUserDefaults.standardUserDefaults().rationalIntervalForKey("interval") ?? RationalInterval(2);
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:AnyObject] {
		var		theResult = super.propertyListValue;
		theResult["limits"] = [
			"degrees":"\(degrees)",
			"interval":interval.toString];
		return theResult;
	}

	override var	documentType : DocumentType { return .EqualTemperament; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return EqualTemperamentGenerator(intervalsData:self);
	}
	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return EqualTemperamentGeneratorViewController(windowController:aWindowController);
	}

	dynamic var		degrees : UInt {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(degrees), forKey:"degrees");
		}
	}
	var				interval : RationalInterval {
		didSet {
			NSUserDefaults.standardUserDefaults().setInterval(interval, forKey:"interval");
		}
	}
}

class EqualTemperamentGenerator: IntervalsDataGenerator {
	func ratioFor(interval anInterval: Interval, note aNote: UInt, degrees aDegrees : UInt ) -> Double {
		return pow(anInterval.toDouble,Double(aNote)/Double(aDegrees));
	}
	func formulaStringFor(interval anInterval: Interval, note aNote: UInt, degrees aDegrees : UInt ) -> String {
		return "\(anInterval.toString)^(\(aNote)/\(aDegrees))";
	}
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	override var	everyEntry : [EqualTemperamentEntry] {
		return _everyEqualTemperamentEntry!;
	}
	init( intervalsData anIntervalsData : EqualTemperamentIntervalsData ) {
		super.init();
		var		theResult = Set<EqualTemperamentEntry>();
		for theOctave in 0..<anIntervalsData.octavesCount {
			for theIndex in 0..<anIntervalsData.degrees {
				let		theString = formulaStringFor(interval:anIntervalsData.interval, note:theIndex+theOctave*12, degrees: anIntervalsData.degrees);
				let		theRatio = ratioFor(interval:anIntervalsData.interval, note:theIndex+theOctave*12, degrees:anIntervalsData.degrees);
				let		theInterval = IrrationalInterval(theRatio,factorsString:theString);
				let		theEntry = EqualTemperamentEntry(interval: theInterval );
				theResult.insert(theEntry);
			}
		}
		_everyEqualTemperamentEntry = theResult.sort { return $0.toCents < $1.toCents; };
	}
}
