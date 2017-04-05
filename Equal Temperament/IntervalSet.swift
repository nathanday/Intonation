//
//  IntervalSet.swift
//  Intonation
//
//  Created by Nathan Day on 21/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class IntervalSet : Sequence {
	let		name : String;
	var		everyInterval : [Interval] { get { preconditionFailure("The method everyInterval must be overriden"); } }
	var		numberOfDegrees : Int { return everyInterval.count; }

	init( name aName: String ) {
		name = aName;
	}

	convenience init?( propertyList aPropertyList: [String:Any] ) {
		if let theName = aPropertyList["name"] as? String {
			self.init( name: theName );
		} else {
			return nil;
		}
	}

	subscript(anIndex:Int) -> Interval! {
		get {
			return anIndex >= 0 ? everyInterval[anIndex%numberOfDegrees]*(anIndex/numberOfDegrees+1) : nil;
		}
	}

	func makeIterator() -> AnyIterator<Interval> {
		var		index = 0;
		return AnyIterator {
			var		theResult : Interval? = nil;
			if index < self.numberOfDegrees {
				theResult = self[index];
				index += 1;
			}
			return theResult;
		}
	}

	func indexOf( _ aValue : Interval ) -> Int? {
		for i in 0..<numberOfDegrees {
			if self[i] == aValue {
				return i;
			}
		}
		return nil;
	}

	func intervalClosestTo( _ aValue : Double ) -> Interval? {
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

	func sortedByDifferentsTo( _ aValue : Double ) -> [Interval] {
		return everyInterval.sorted { (a:Interval, b:Interval) -> Bool in return abs(a.toDouble-aValue) < abs(b.toDouble-aValue); };
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
		return "\(name) = \(String(describing: theResult))]";
	}
}
