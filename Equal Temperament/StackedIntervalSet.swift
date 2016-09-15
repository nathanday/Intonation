//
//  StackedIntervalSet.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class StackedIntervalSet : IntervalSet, Hashable {
	let		interval : Interval;
	var		steps : UInt {
		didSet { calculateIntervals(); }
	}
	var		octaves : UInt {
		didSet { calculateIntervals(); }
	}
	override var	everyInterval : [Interval] { return _everyInterval; }
	var		_everyInterval : [Interval];

	init( interval anInterval : Interval, steps aSteps : UInt, octaves anOctaves : UInt ) {
		interval = anInterval;
		steps = aSteps;
		octaves = anOctaves;
		_everyInterval = [Interval]();
		super.init( name: anInterval.ratioString );
		calculateIntervals();
	}
	convenience init?(propertyList aPropertyList : [String:String] ) {
		if let theInterval = Interval.from(string:aPropertyList["interval"]) {
			let theStepsString = aPropertyList["steps"] ?? "2";
			let theOctavesString = aPropertyList["octaves"] ?? "2";
			self.init(interval : theInterval, steps : UInt(theStepsString) ?? 2, octaves: UInt(theOctavesString) ?? 2);
		} else {
			return nil;
		}
	}

	func contains( _ anInterval: Interval ) -> Bool {
		for theInterval in everyInterval {
			if theInterval == anInterval {
				return true;
			}
		}
		return false;
	}

	func contains( _ anInterval: UInt ) -> Bool { return contains( RationalInterval(anInterval) ); }
	func contains( _ anInterval: Rational ) -> Bool { return contains( RationalInterval(anInterval) ); }
	func contains( _ anInterval: Double ) -> Bool { return contains( IrrationalInterval(anInterval) ); }

	var propertyList : [String:String] {
		return ["interval":interval.toString,"steps":"\(steps)","octaves":"\(octaves)"];
	}

	private func calculateIntervals() {
		let		theOctaveValue = 1<<(octaves-1);
		_everyInterval.removeAll();
		switch interval {
		case let x as RationalInterval:
			var		theValue : Rational = 1;
			for _ in UInt(0)..<steps {
				var		theNormalizedValue = theValue;
				while theNormalizedValue/2 > 1 {
					theNormalizedValue /= 2;
				}
				_everyInterval.append( RationalInterval( theNormalizedValue ) );
				theValue *= x.ratio;
				if theValue > theOctaveValue {
					break;
				}
			}
		case let x as IrrationalInterval:
			var		theValue = 1.0;
			for _ in UInt(0)..<steps {
				var		theNormalizedValue = theValue;
				while theNormalizedValue*0.5 > 1.0 {
					theNormalizedValue *= 0.5;
				}
				_everyInterval.append( IrrationalInterval( theNormalizedValue ) );
				theValue *= x.ratio;
				if theValue > Double(theOctaveValue) {
					break;
				}
			}
		default:
			break;
		}
	}

	var hashValue: Int {
		return interval.hashValue;
	}

	static func == (lhs: StackedIntervalSet, rhs: StackedIntervalSet) -> Bool {
		return lhs.interval == rhs.interval;
	}
}

