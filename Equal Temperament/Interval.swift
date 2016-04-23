//
//  Interval.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class Interval : Hashable {
	class func fromString( aString : String? ) -> Interval? {
		var		theResult : Interval?
		if let theString = aString {
			if theString.containsString(".") {
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
	class func fromPropertyList( aPropertyList : AnyObject ) -> Interval? {
		var		theResult : Interval?
		var		theEveryName : [String] = [];
		if let thePropertyList = aPropertyList as? [String:AnyObject] {
			if let theNames = thePropertyList["names"] as? [String] {
				theEveryName = theNames;
			}
			if let theNumerator = thePropertyList["numerator"] as? Int,
				theDenominator = thePropertyList["denominator"] as? Int {
				theResult = RationalInterval( ratio: Rational(theNumerator,theDenominator), names: theEveryName );
			}
			else if let theRatioString = thePropertyList["ratio"] as? String {
				if theRatioString.containsString(".") {
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
					theInterval = Interval.fromString(theIntervalString);
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
	var		propertyList : [String:AnyObject] {
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
	var oddLimit : UInt? { return nil; }
	var primeLimit : UInt? { return nil; }
	var factorsString : String {
		preconditionFailure("The method toString must be overriden");
	}
	var ratioString : String {
		preconditionFailure("The method toString must be overriden");
	}
	var additiveDissonance : UInt? { return nil; }
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
	override var toString : String { return ratio.toString; }
	override var propertyList : [String:AnyObject] {
		var		theResult : [String:AnyObject] = ["numerator":numerator, "denominator":denominator];
		if names?.count > 0 {
			theResult["names"] = names;
		}
		return theResult;
	}
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
	convenience init( _ anInteger: UInt ) {
		self.init( Int(anInteger), 1 );
	}
	convenience init( _ anInteger: Int ) {
		self.init( anInteger, 1 );
	}
//	convenience init?( propertyList aPropertyList: [String:AnyObject] ) {
//		var		theEveryName : [String] = [];
//		if let theNames = aPropertyList["names"] as? [String] {
//			theEveryName = theNames;
//		}
//		if let theNumerator = aPropertyList["numerator"] as? Int,
//				theDenominator = aPropertyList["denominator"] as? Int {
//			self.init( ratio: Rational(theNumerator,theDenominator), names: theEveryName );
//		} else if let theRatioString = aPropertyList["ratio"] as? String {
//			if let theRatio = Rational(theRatioString) {
//				self.init( ratio: theRatio, names: theEveryName );
//			}
//		} else {
//			return nil;
//		}
//	}
//	convenience init?( _ aString : String ) {
//		if let theValue = Rational(aString) {
//			self.init( ratio:theValue, names:nil );
//		}
//	}
	class override func fromString( aString : String? ) -> RationalInterval? {
		var		theResult : RationalInterval?
		if let theString = aString {
			if let theValue = Rational(theString) {
				theResult = RationalInterval(theValue);
			}
		}
		return theResult;
	}
	override var hashValue: Int { return ratio.hashValue; }
	override var oddLimit : UInt? { return ratio.oddLimit; }
	override var primeLimit : UInt? { return ratio.primeLimit; }
	override var factorsString : String { return ratio.factorsString; }
	override var ratioString : String { return ratio.ratioString; }
	override var additiveDissonance : UInt? { return ratio.additiveDissonance; }
	override func numeratorForDenominator( aDenominator: Int ) -> Int? {
		return ratio.numeratorForDenominator(aDenominator);
	}
}

class IrrationalInterval : Interval {
	private static let	intervalNames : [UInt:[String]] = {
		var theResult = [UInt:[String]]()
		for theEntry in NSUserDefaults.standardUserDefaults().arrayForKey("intervalNames")! as! [[String:AnyObject]] {
			if let theRatioString = theEntry["ratio"] as? String,
				theNames = theEntry["names"] as? [String] {
				if theRatioString.containsString(".") {
					if let theRatio = Double(theRatioString) {
						theResult[UInt(theRatio*4096)] = theNames;
					}
				}
				else if theRatioString.hasSuffix(":1") {
					if let theRatio = UInt( theRatioString.componentsSeparatedByString(":").first! ) {
						theResult[UInt(theRatio*4096)] = theNames;
					}
				}
			}
		}
		return theResult;
	}()
	let		ratio: Double;
	override var toDouble : Double { return ratio; }
	override var toString : String { return "\(ratio)"; }
	override var propertyList : [String:AnyObject] {
		var		theResult : [String:AnyObject] = ["value":ratio];
		if names?.count > 0 {
			theResult["names"] = names;
		}
		return theResult;
	}
	override var hashValue: Int { return Int(12000.0*log2(ratio)+0.5).hashValue; }
	init( ratio aRatio: Double, names aNames: [String]?, factorsString aFactorsString : String? = nil ) {
		ratio = aRatio;
		_factorsString = aFactorsString;
		super.init( names:aNames );
	}
	convenience init( _ aRatio: Double, factorsString aFactorsString : String? = nil ) {
		let		theNames = IrrationalInterval.intervalNames[UInt(aRatio*4096)];
		self.init( ratio: aRatio, names:theNames );
		_factorsString = aFactorsString;
	}
	convenience init?( propertyList aPropertyList: [String:AnyObject] ) {
		if let theValue = aPropertyList["ratio"] as? Double{
			var		theEveryName : [String] = [];
			if let theNames = aPropertyList["names"] as? [String] {
				theEveryName = theNames;
			}
			self.init( ratio: theValue, names: theEveryName );
		} else {
			return nil;
		}
	}
//	convenience init?( _ aString : String ) {
//		if let theValue = Double(aString) {
//			self.init( theValue );
//		}
//	}
	var	_factorsString : String? = nil;
	override var factorsString : String {
		return _factorsString != nil ? _factorsString! : "\(ratio)";
	}
	override var ratioString : String { return ratio.toString(decimalPlaces:5); }
}

class EqualTemperamentInterval : Interval {
	private static let	intervalNames : [UInt:[String]] = {
		var theResult = [UInt:[String]]()
		for theEntry in NSUserDefaults.standardUserDefaults().arrayForKey("intervalNames")! as! [[String:AnyObject]] {
			if let theRatioString = theEntry["ratio"] as? String,
				theNames = theEntry["names"] as? [String] {
				if theRatioString.containsString(".") {
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
	convenience init?( propertyList aPropertyList: [String:AnyObject] ) {
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
	override var propertyList : [String:AnyObject] {
		return [ "steps":steps, "degree":degree, "interval":interval.toString ];
	}
	override var factorsString : String {
		return "\(interval.toString)^\(degree)/\(steps)";
	}
	override var ratioString : String { return toDouble.toString(decimalPlaces:5); }
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

func equivelentRatios( a: Double, _ b: Double ) -> Bool {
	return abs(a-b) < 1.0/4096.0;
}

func == (a: Interval, b: Interval) -> Bool { return a.toDouble == b.toDouble; }
func == (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio==b.ratio; }
func == (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return equivelentRatios(a.ratio,b.ratio); }
func == (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a.interval == b.interval && a.steps == b.steps && a.degree == b.degree; }

func < (a: Interval, b: Interval) -> Bool { return a.toDouble < b.toDouble; }
func < (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio < b.ratio; }
func < (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio < b.ratio; }
func < (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a.toDouble < b.toDouble; }

func <= (a: Interval, b: Interval) -> Bool { return a.toDouble <= b.toDouble; }
func <= (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio <= b.ratio; }
func <= (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio < b.ratio || equivelentRatios(a.ratio,b.ratio); }
func <= (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a==b || a.toDouble < b.toDouble; }

func > (a: Interval, b: Interval) -> Bool { return a.toDouble > b.toDouble; }
func > (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio > b.ratio; }
func > (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio > b.ratio; }
func > (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a.toDouble > b.toDouble; }

func >= (a: Interval, b: Interval) -> Bool { return a.toDouble >= b.toDouble; }
func >= (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio >= b.ratio; }
func >= (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio > b.ratio || equivelentRatios(a.ratio,b.ratio); }
func >= (a: EqualTemperamentInterval, b: EqualTemperamentInterval) -> Bool { return a==b || a.toDouble > b.toDouble; }

func == (a: Interval, b: Int) -> Bool { return a.toDouble == Double(b); }
func == (a: RationalInterval, b: Int) -> Bool { return a.ratio==b; }

func == (a: Interval, b: UInt) -> Bool { return a.toDouble == Double(b); }
func == (a: RationalInterval, b: UInt) -> Bool { return a.ratio==b; }

extension NSUserDefaults {
	func intervalForKey(aKey: String) -> Interval? {
		var			theResult : Interval?;
		if let theIntervalString = NSUserDefaults.standardUserDefaults().stringForKey(aKey) {
			theResult = Interval.fromString(theIntervalString);
		}
		return theResult;
	}
	func rationalIntervalForKey(aKey: String) -> RationalInterval? {
		var			theResult : RationalInterval?;
		if let theIntervalString = NSUserDefaults.standardUserDefaults().stringForKey(aKey) {
			theResult = RationalInterval.fromString(theIntervalString);
		}
		return theResult;
	}
	func setInterval(aValue: Interval, forKey aKey: String) {
		setObject(aValue.toString, forKey: aKey);
	}
}
