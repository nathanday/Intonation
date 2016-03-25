//
//  Interval.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class Interval : Hashable {
	static func fromString( aString : String ) -> Interval? {
		var		theResult : Interval?
		if aString.containsString(".") {
			if let theValue = Double(aString) {
				theResult = IrrationalInterval(theValue);
			}
		} else {
			if let theValue = Rational(aString) {
				theResult = RationalInterval(theValue);
			}
		}
		return theResult;
	}
	var		names: [String]?
	var		toDouble : Double {
		preconditionFailure("The method toDouble must be overriden");
	}
	var		toString : String {
		preconditionFailure("The method toString must be overriden");
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
	var oddLimit : UInt {
		return UInt.max;
	}
	var primeLimit : UInt {
		return UInt.max;
	}
	var factorsString : String {
		preconditionFailure("The method toString must be overriden");
	}
	var ratioString : String {
		preconditionFailure("The method toString must be overriden");
	}
	var additiveDissonance : UInt {
		return UInt.max;
	}
	func numeratorForDenominator( aDenominator: Int ) -> Int? {
		return nil;
	}
}

class RationalInterval : Interval {
	private static let	intervalNames : [Rational:[String]] = {
		var theResult = [Rational:[String]]()
		for theEntry in NSUserDefaults.standardUserDefaults().arrayForKey("intervalNames")! as! [[String:AnyObject]] {
			if let theRatioString = theEntry["ratio"] as? String,
				theNames = theEntry["names"] as? [String] {
				if !theRatioString.containsString(".") {
					if let theRatio = Rational(theRatioString) {
						precondition(theResult[theRatio] == nil, "Already have \(theRatio)=\(theResult[theRatio])" );
						theResult[theRatio] = theNames;
					}
				}
			}
		}
		return theResult;
	}()
	let		ratio: Rational;
	override var toDouble : Double { return ratio.toDouble; }
	override var toString : String { return ratio.ratioString; }
	var		justInternation : Double { return ratio.toDouble; }
	var		numerator: Int { return ratio.numerator; }
	var		denominator: Int { return ratio.denominator; }
	init( ratio aRatio: Rational, names aNames: [String]? ) {
		ratio = aRatio;
		super.init( names:aNames );
	}
	convenience init( _ aRatio: Rational ) {
		let		theNames = RationalInterval.intervalNames[aRatio];
		self.init( ratio: aRatio, names:theNames );
	}
	convenience init( _ aNumerator: Int, _ aDenominator : Int ) {
		let		theRational = Rational(aNumerator,aDenominator);
		let		theNames = RationalInterval.intervalNames[theRational];
		self.init( ratio: theRational, names:theNames );
	}
	convenience init( _ aNumerator: UInt, _ aDenominator : UInt ) {
		self.init( Int(aNumerator), Int(aDenominator) );
	}
	override var hashValue: Int { return ratio.hashValue; }
	override var oddLimit : UInt { return ratio.oddLimit; }
	override var primeLimit : UInt { return ratio.primeLimit; }
	override var factorsString : String { return ratio.factorsString; }
	override var ratioString : String { return ratio.ratioString; }
	override var additiveDissonance : UInt { return ratio.additiveDissonance; }
	override func numeratorForDenominator( aDenominator: Int ) -> Int? {
		return ratio.numeratorForDenominator(aDenominator);
	}
}

class IrrationalInterval : Interval {
	private static let	intervalNames : [Double:[String]] = {
		var theResult = [Double:[String]]()
		for theEntry in NSUserDefaults.standardUserDefaults().arrayForKey("intervalNames")! as! [[String:AnyObject]] {
			if let theRatioString = theEntry["ratio"] as? String,
				theNames = theEntry["names"] as? [String] {
				if theRatioString.containsString(".") {
					if let theRatio = Double(theRatioString) {
						theResult[theRatio] = theNames;
					}
				}
			}
		}
		return theResult;
	}()
	let		ratio: Double;
	override var		toDouble : Double { return ratio; }
	override var toString : String { return "\(ratio)"; }
	override var hashValue: Int { return ratio.hashValue; }
	init( ratio aRatio: Double, names aNames: [String]? ) {
		ratio = aRatio;
		super.init( names:aNames );
	}
	convenience init( _ aRatio: Double ) {
		let		theNames = IrrationalInterval.intervalNames[aRatio];
		self.init( ratio: aRatio, names:theNames );
	}
	override var factorsString : String { return "\(ratio)"; }
	override var ratioString : String { return "\(ratio)"; }
}

func * (a: Interval, b: Int) -> Interval {
	switch a {
	case let x as RationalInterval:
		return RationalInterval(x.ratio.numerator*b,x.ratio.denominator);
	case let x as IrrationalInterval:
		return IrrationalInterval(x.ratio*Double(b));
	default:
		preconditionFailure("Unexpected type \(a)");
	}
}

func == (a: Interval, b: Interval) -> Bool { return a.toDouble == b.toDouble; }
func == (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio==b.ratio; }
func == (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio==b.ratio; }

func < (a: Interval, b: Interval) -> Bool { return a.toDouble < b.toDouble; }
func < (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio < b.ratio; }
func < (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio < b.ratio; }

func <= (a: Interval, b: Interval) -> Bool { return a.toDouble <= b.toDouble; }
func <= (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio <= b.ratio; }
func <= (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio <= b.ratio; }

func > (a: Interval, b: Interval) -> Bool { return a.toDouble > b.toDouble; }
func > (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio > b.ratio; }
func > (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio > b.ratio; }


func >= (a: Interval, b: Interval) -> Bool { return a.toDouble >= b.toDouble; }
func >= (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio >= b.ratio; }
func >= (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio >= b.ratio; }

func == (a: Interval, b: Int) -> Bool { return a.toDouble == Double(b); }
func == (a: RationalInterval, b: Int) -> Bool { return a.ratio==b; }
