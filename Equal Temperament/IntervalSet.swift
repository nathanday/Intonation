//
//  IntervalSet.swift
//  Intonation
//
//  Created by Nathan Day on 21/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class IntervalSet : SequenceType {
	let		name : String;
	var		everyInterval : [Interval] { get { preconditionFailure("The method everyInterval must be overriden"); } }
	var		numberOfDegrees : Int { return everyInterval.count; }

	init( name aName: String ) {
		name = aName;
	}

	subscript(anIndex:Int) -> Interval! {
		get {
			return anIndex >= 0 ? everyInterval[anIndex%numberOfDegrees]*(anIndex/numberOfDegrees+1) : nil;
		}
	}

	func generate() -> AnyGenerator<Interval> {
		var		index = 0;
		return AnyGenerator {
			var		theResult : Interval? = nil;
			if index < self.numberOfDegrees {
				theResult = self[index];
				index += 1;
			}
			return theResult;
		}
	}

	func indexOf( aValue : Interval ) -> Int? {
		for i in 0..<numberOfDegrees {
			if self[i] == aValue {
				return i;
			}
		}
		return nil;
	}

	func intervalClosestTo( aValue : Double ) -> Interval? {
		var		theResult : Interval? = nil;
		var		thePrevious : Interval? = nil;
		for theInterval in everyInterval {
			if theInterval.toDouble > aValue {
				if let thePreviousValue = thePrevious {
					if abs(thePreviousValue.toDouble-aValue) < abs(theInterval.toDouble-aValue) {
						theResult = thePreviousValue;
						break;
					}
					else {
						theResult = theInterval;
						break;
					}
				}
				else {
					theResult = theInterval;
					break;
				}
			}
			thePrevious = theInterval;
		}
		return theResult;
	}

	func sortedByDifferentsTo( aValue : Double ) -> [Interval] {
		return everyInterval.sort { (a:Interval, b:Interval) -> Bool in return abs(a.toDouble-aValue) < abs(b.toDouble-aValue); };
	}

	var description: String {
		var		theResult : String?;
		for r in self {
			if theResult == nil {
				theResult = r.ratioString;
			} else {
				theResult = ", \(r.ratioString)";
			}
		}
		return "\(name) = \(theResult)]";
	}
}
