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
	let		interval : Interval;
	let		degrees : UInt;

	func ratioFor( note aNote: UInt ) -> Double {
		return pow(interval.toDouble,Double(aNote)/Double(degrees));
	}
	func formulaStringFor( note aNote: UInt ) -> String {
		return "\(interval.toString)^(\(aNote)/\(degrees))";
	}
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	override var	everyEntry : [EqualTemperamentEntry] {
		return _everyEqualTemperamentEntry!;
	}
	init( intervalsData anIntervalsData : EqualTemperamentIntervalsData ) {
		interval = anIntervalsData.interval;
		degrees = anIntervalsData.degrees;
		super.init();
		var		theResult = Set<EqualTemperamentEntry>();
		var		theIndex : UInt = 0;
		var		theRatio = ratioFor(note:theIndex);
		let		theMaxRatio = pow(2.0,Double(anIntervalsData.octavesCount));
		while theRatio < theMaxRatio {
			let		theString = formulaStringFor(note:theIndex);
			let		theInterval = EqualTemperamentInterval(degree: theIndex, steps: degrees, interval: interval, names: [theString])
			let		theEntry = EqualTemperamentEntry(interval: theInterval );
			theRatio = theInterval.toDouble;
			theResult.insert(theEntry);
			theIndex += 1;
			theRatio = ratioFor(note:theIndex);
		}

		_everyEqualTemperamentEntry = theResult.sort { return $0.toCents < $1.toCents; };
	}
}
