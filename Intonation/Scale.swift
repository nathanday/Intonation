/*
	Scale.swift
	Intonation

	Created by Nathan Day on 20/03/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

class Scale : IntervalSet {
	static let major : Scale = Scale(name:"major", elements:[RationalInterval(1,1), RationalInterval(9,8), RationalInterval(5,4), RationalInterval(4,3), RationalInterval(3,2), RationalInterval(5,3), RationalInterval(15,8)]);
	static let minor : Scale = Scale(name:"minor", elements:[RationalInterval(1,1), RationalInterval(9,8), RationalInterval(6,5), RationalInterval(4,3), RationalInterval(3,2), RationalInterval(8,5), RationalInterval(9,5)]);

	override var		everyInterval : [Interval] { return _everyInterval; }

	var		_everyInterval : [Interval];

	init(name aName: String, elements anElements: [Interval] ) {
		_everyInterval = anElements.sorted { (a:Interval, b:Interval) -> Bool in return a < b; };
		super.init( name: aName );
	}
	convenience init?( propertyList aPropertyList: [String:Any] ) {
		if let theName = aPropertyList["name"] as? String,
			let theEveryInterval = aPropertyList["everyInterval"] as? [[String:Any]] {
			var		theIntervals = [Interval]();
			for theIntervalPropertyList in theEveryInterval {
				if let theInterval = Interval.from(propertyList:theIntervalPropertyList) {
					theIntervals.append(theInterval);
				} else {
					return nil;
				}
			}
			self.init( name: theName, elements: theIntervals );
		} else {
			return nil;
		}
	}
}

class Chord  : Scale {
}
