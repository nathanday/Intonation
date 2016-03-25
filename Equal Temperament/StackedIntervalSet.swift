//
//  StackedIntervalSet.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class StackedIntervalSet : IntervalSet, Hashable {
	var		interval : Interval;
	var		steps : UInt;
	var		octaves : UInt; 
	override var	everyInterval : [Interval] { return _everyInterval; }
	var		_everyInterval : [Interval];

	init( interval anInterval : Interval, steps aSteps : UInt, octaves anOctaves : UInt ) {
		interval = anInterval;
		steps = aSteps;
		octaves = anOctaves;
		_everyInterval = [Interval]();
		switch anInterval {
		case let x as RationalInterval:
			var		theNumerator = 1;
			var		theDenominator = 1;
			for _ in UInt(0)...aSteps {
				while theDenominator*2 < theNumerator {
					theDenominator *= 2;
				}
				_everyInterval.append( RationalInterval( theNumerator, theDenominator ) );
				theNumerator *= x.ratio.numerator;
				theDenominator *= x.ratio.denominator;
			}
		case let x as IrrationalInterval:
			var		theValue = 1.0;
			for _ in UInt(1)...aSteps {
				while theValue*0.5 > 1.0 {
					theValue *= 0.5;
				}
				_everyInterval.append( IrrationalInterval( theValue ) );
				theValue *= x.ratio;
			}
		default:
			break;
		}
		super.init( name: anInterval.ratioString );
	}

	var hashValue: Int {
		return interval.hashValue;
	}
}

func ==(lhs: StackedIntervalSet, rhs: StackedIntervalSet) -> Bool {
	return lhs.everyInterval == rhs.everyInterval;
}