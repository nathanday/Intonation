//
//  EqualTemperamentInterval.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class EqualTemperamentInterval : Interval {
	private static let	intervalNames : [UInt:[String]] = {
		var theResult = [UInt:[String]]()
		for theEntry in UserDefaults.standard.array(forKey: "intervalNames")! as! [[String:Any]] {
			if let theRatioString = theEntry["ratio"] as? String,
				let theNames = theEntry["names"] as? [String] {
				if theRatioString.contains(".") {
					if let theRatio = Double(theRatioString) {
						theResult[UInt(theRatio*4096)] = theNames;
					}
				}
			}
		}
		return theResult;
	}()
	var		steps : UInt = 12;
	var		degree : UInt = 0;
	var		interval : Interval = RationalInterval(2);
	init( degree aDegree: UInt, steps aSteps: UInt = 12, interval anInterval : Interval = RationalInterval(2), names aNames: [String] ) {
		interval = anInterval;
		steps = aSteps;
		degree = aDegree;
		super.init( names: aNames );
	}
	convenience init?( propertyList aPropertyList: [String:Any] ) {
		if let theDegree = aPropertyList["degree"] as? UInt {
			var		theEveryName : [String] = [];
			if let theNames = aPropertyList["names"] as? [String] {
				theEveryName = theNames;
			}
			self.init( degree: theDegree, steps: (aPropertyList["steps"] as? UInt) ?? 12, interval: (aPropertyList["interval"] as? Interval) ?? RationalInterval(2), names: theEveryName );
		} else {
			return nil;
		}
	}
	override var		toDouble : Double {
		return pow(interval.toDouble,Double(degree)/Double(steps));
	}
	override var toString : String {
		return "\(interval.toString)^\(degree)/\(steps)";
	}
	override var propertyList : [String:Any] {
		return [ "steps":steps, "degree":degree, "interval":interval.toString ];
	}
	override var factorsString : String {
		return "\(interval.toString)^\(degree)/\(steps)";
	}
	override var ratioString : String { return toDouble.toString(decimalPlaces:5); }
	static func == (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a.interval == b.interval && a.steps == b.steps && a.degree == b.degree; }

	static func < (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a.toDouble < b.toDouble; }
	static func <= (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a==b || a.toDouble < b.toDouble; }
	static func > (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a.toDouble > b.toDouble; }
	static func >= (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a==b || a.toDouble > b.toDouble; }
}
