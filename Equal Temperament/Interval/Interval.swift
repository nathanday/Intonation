//
//  Interval.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class Interval : Hashable {
	class func from( string aString : String? ) -> Interval? {
		var		theResult : Interval?
		if let theString = aString {
			if theString.contains(".") {
				if let theValue = Double(theString) {
					theResult = IrrationalInterval(theValue);
				}
			} else {
				if let theValue = Rational(theString) {
					theResult = RationalInterval(theValue);
				}
			}
		}
		return theResult;
	}
	class func from( propertyList aPropertyList : Any ) -> Interval? {
		var		theResult : Interval?
		var		theEveryName : [String] = [];
		if let thePropertyList = aPropertyList as? [String:Any] {
			if let theNames = thePropertyList["names"] as? [String] {
				theEveryName = theNames;
			}
			if let theNumerator = thePropertyList["numerator"] as? Int,
				let theDenominator = thePropertyList["denominator"] as? Int {
				theResult = RationalInterval( ratio: Rational(theNumerator,theDenominator), names: theEveryName );
			}
			else if let theRatioString = thePropertyList["ratio"] as? String {
				if theRatioString.contains(".") {
					if let theRatio = Double(theRatioString) {
						theResult = IrrationalInterval( ratio: theRatio, names: theEveryName );
					}
				} else {
					if let theRatio = Rational(theRatioString) {
						theResult = RationalInterval( ratio: theRatio, names: theEveryName );
					}
				}
			}
			else if let theRatio = thePropertyList["ratio"] as? Double {
				theResult = IrrationalInterval( ratio: theRatio, names: theEveryName );
			}
			else if let theDegree = thePropertyList["degree"] as? UInt {
				let theSteps = thePropertyList["steps"] as? UInt;
				var theInterval : Interval? = nil;
				if let theIntervalString = thePropertyList["interval"] as? String {
					theInterval = Interval.from(string:theIntervalString);
				}
				theResult = EqualTemperamentInterval( degree: theDegree, steps:theSteps ?? 12, interval:theInterval ?? RationalInterval(2), names: theEveryName );
			}
		}
		return theResult;
	}
	var		names: [String]?
	var		toDouble : Double {
		preconditionFailure("The method toDouble must be overriden");
	}
	var		toCents : Double { return toDouble.toCents; }
	var		toOctave : Double { return toDouble.toOctave; }
	var		toString : String {
		preconditionFailure("The method toString must be overriden");
	}
	var		propertyList : [String:Any] {
		preconditionFailure("The method propertyList must be overriden");
	}
	func	equalTemperamentValue( forIntervalCount anIntervals: UInt ) -> Double {
		return floor(Double(anIntervals)*log2(toDouble)+0.5);
	}
	func	equalTemperamentRatio( forIntervalCount anIntervals: UInt ) -> Double {
		return pow(2.0,equalTemperamentValue(forIntervalCount:anIntervals)/Double(anIntervals));
	}
	init( names aNames: [String]? ) {
		names = aNames;
	}
	var hashValue: Int {
		return toDouble.hashValue;
	}
	static func == (a: Interval, b: Interval) -> Bool {
		return a.toDouble == b.toDouble;
	}
	var oddLimit : UInt? { return nil; }
	var primeLimit : UInt? { return nil; }
	var factorsString : String {
		preconditionFailure("The method toString must be overriden");
	}
	var ratioString : String {
		preconditionFailure("The method toString must be overriden");
	}
	var additiveDissonance : UInt? { return nil; }
	func numeratorForDenominator( _ aDenominator: Int ) -> Int? {
		return nil;
	}

	static func < (a: Interval, b: Interval) -> Bool { return a.toDouble < b.toDouble; }
	static func < (a: Interval, b: Int) -> Bool { return a.toDouble < Double(b); }
	static func <= (a: Interval, b: Interval) -> Bool { return a.toDouble <= b.toDouble; }
	static func > (a: Interval, b: Interval) -> Bool { return a.toDouble > b.toDouble; }
	static func >= (a: Interval, b: Interval) -> Bool { return a.toDouble >= b.toDouble; }
	static func == (a: Interval, b: Int) -> Bool { return a.toDouble == Double(b); }
	static func == (a: Interval, b: UInt) -> Bool { return a.toDouble == Double(b); }
	static func * (a: Interval, b: Interval) -> Interval { return IrrationalInterval(a.toDouble * b.toDouble); }
	static func *= (a: inout Interval, b: Interval) { a = IrrationalInterval(a.toDouble*b.toDouble); }
	static func *= (a: inout Interval, b: Int) { a = IrrationalInterval(a.toDouble*Double(b)); }
	static func > (a: Interval, b: Int) -> Bool { return a.toDouble > Double(b); }
}

func * (a: Interval, b: Int) -> Interval {
	switch a {
	case let x as RationalInterval:
		return RationalInterval(x.ratio.numerator*b,x.ratio.denominator);
	case let x as IrrationalInterval:
		return IrrationalInterval(x.ratio*Double(b));
	case let x as EqualTemperamentInterval:
		return IrrationalInterval(x.toDouble*Double(b));
	default:
		preconditionFailure("Unexpected type \(a)");
	}
}

func * (a: Interval, b: UInt) -> Interval {
	switch a {
	case let x as RationalInterval:
		return RationalInterval(x.ratio.numerator*Int(b),x.ratio.denominator);
	case let x as IrrationalInterval:
		return IrrationalInterval(x.ratio*Double(b));
	case let x as EqualTemperamentInterval:
		return IrrationalInterval(x.toDouble*Double(b));
	default:
		preconditionFailure("Unexpected type \(a)");
	}
}

func equivelentRatios( _ a: Double, _ b: Double ) -> Bool {
	return abs(a-b) < 1.0/4096.0;
}

extension UserDefaults {
	func intervalForKey(_ aKey: String) -> Interval? {
		var			theResult : Interval?;
		if let theIntervalString = UserDefaults.standard.string(forKey: aKey) {
			theResult = Interval.from(string:theIntervalString);
		}
		return theResult;
	}
	func rationalIntervalForKey(_ aKey: String) -> RationalInterval? {
		var			theResult : RationalInterval?;
		if let theIntervalString = UserDefaults.standard.string(forKey: aKey) {
			theResult = RationalInterval.from(string:theIntervalString);
		}
		return theResult;
	}
	func setInterval(_ aValue: Interval, forKey aKey: String) {
		set(aValue.toString, forKey: aKey);
	}
}
