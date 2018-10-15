//
//  EqualTemperamentGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class EqualTemperamentIntervalsData : IntervalsData {
	static let		degreesKey = "equalTemperament_degrees";
	static let		intervalKey = "equalTemperament_interval";

	override init() {
		degrees = UInt(UserDefaults.standard.integer(forKey: EqualTemperamentIntervalsData.degreesKey));
		if( degrees == 0 ) {
			degrees = 12;
		}
		interval = UserDefaults.standard.rationalIntervalForKey(EqualTemperamentIntervalsData.intervalKey) ?? RationalInterval(2);
		super.init();
	}
	override init?(propertyList aPropertyList: [String:Any] ) {
		guard let theProperties = aPropertyList["equalTemperament"] as? [String:Any] else {
			return nil;
		}
		if let theDegreesString = theProperties["degrees"] as? Int {
			degrees = UInt(theDegreesString);
		} else {
			degrees = UInt(UserDefaults.standard.integer(forKey: EqualTemperamentIntervalsData.degreesKey));
			if( degrees == 0 ) {
				degrees = 12;
			}
		}
		if let theIntervalString = theProperties["interval"] as? String {
			interval = RationalInterval.from(string:theIntervalString) ?? RationalInterval(2,1);
		} else {
			interval = UserDefaults.standard.rationalIntervalForKey(EqualTemperamentIntervalsData.intervalKey) ?? RationalInterval(2);
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:Any] {
		var		theResult = super.propertyListValue;
		theResult["equalTemperament"] = [
			"degrees":"\(degrees)",
			"interval":interval.toString];
		return theResult;
	}

	override var	documentType : DocumentType { return .equalTemperament; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return EqualTemperamentGenerator(intervalsData:self);
	}

	@objc dynamic var		degrees : UInt {
		willSet {
			willChangeValue(forKey: "degrees");
		}
		didSet {
			UserDefaults.standard.set(Int(degrees), forKey:EqualTemperamentIntervalsData.degreesKey);
			didChangeValue(forKey: "degrees");
		}
	}
	var				interval : RationalInterval {
		willSet {
			willChangeValue(forKey: "interval");
		}
		didSet {
			UserDefaults.standard.setInterval(interval, forKey:EqualTemperamentIntervalsData.intervalKey);
			didChangeValue(forKey: "interval");
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
	var	_everyIntervalEntry : [IntervalEntry]?;
	override var	everyEntry : [IntervalEntry] {
		return _everyIntervalEntry ?? [IntervalEntry]();
	}
	init( intervalsData anIntervalsData : EqualTemperamentIntervalsData ) {
		interval = anIntervalsData.interval;
		degrees = anIntervalsData.degrees;
		super.init(intervalsData:anIntervalsData);
		var		theResult = Set<IntervalEntry>();
		var		theIndex : UInt = 0;
		var		theRatio = ratioFor(note:theIndex);
		let		theMaxRatio = pow(2.0,Double(octavesCount));
		while theRatio <= theMaxRatio {
			let		theString = formulaStringFor(note:theIndex);
			let		theInterval = EqualTemperamentInterval(degree: theIndex, steps: degrees, interval: interval, names: [theString])
			let		theEntry = IntervalEntry(interval: theInterval );
			theRatio = theInterval.toDouble;
			theResult.insert(theEntry);
			theIndex += 1;
			theRatio = ratioFor(note:theIndex);
		}

		_everyIntervalEntry = theResult.sorted { return $0.toCents < $1.toCents; };
	}
}
