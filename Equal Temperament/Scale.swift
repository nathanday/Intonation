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
		_everyInterval = anElements.sort { (a:Interval, b:Interval) -> Bool in return a < b; };
		super.init( name: aName );
	}

	static func degreeName( anIndex : Int ) -> String {
		var thePrefix : String
		switch anIndex % 10 {
		case 0 where anIndex%100 < 10:
			thePrefix = "st";
		case 1 where anIndex%100 < 10:
			thePrefix = "nd";
		case 2 where anIndex%100 < 10:
			thePrefix = "rd";
		default:
			thePrefix = "th";
		}
		return "\(anIndex+1)\(thePrefix)";
	}
}

class Chord  : Scale {
}
