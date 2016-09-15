/*
    EqualTemperamentEntry.swift
    Intonation

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Cocoa

//func ratioForCentsEquivelent( c : Double, n : UInt ) -> Double { return pow(2.0,c/(100.0*Double(n))); }

extension Rational {
	var oddLimit : UInt {
		let	theNum = UInt(numerator);
		let theDen = UInt(denominator);
		if theNum%2 == 1 && theDen%2 == 1 { return theNum > theDen ? theNum : theDen; }
		else if theNum%2 == 1 { return theNum; }
		else { return theDen; }
	}
	var primeLimit : UInt {
		let		theResult : UInt = UInt.max;
		if numerator > 0 && denominator > 0 {
			let		theNumeratorLargestPrimeFactor = UInt(numerator).largestPrimeFactor;
			let		theDenominatorLargestPrimeFactor = UInt(denominator).largestPrimeFactor;
			return theNumeratorLargestPrimeFactor > theDenominatorLargestPrimeFactor ? theNumeratorLargestPrimeFactor : theDenominatorLargestPrimeFactor;
		}
		return theResult;
	}

	var additiveDissonance  : UInt { return UInt(numerator) + UInt(denominator); }
}

class EqualTemperamentEntry : NSObject, NSPasteboardReading, NSPasteboardWriting {
	var interval : Interval
    dynamic var intervalToString : String {
		switch interval {
		case let x as RationalInterval:
			return x.toString;
		default:
			return interval.toDouble.toString(decimalPlaces:5);
		}
	}
    dynamic var intervalToDouble : Double { return interval.toDouble; }
	var name : String { return interval.ratioString; }
	var closestEqualTemperamentIntervalNumber : UInt { return UInt(12.0*Double(log2(interval.toDouble))+0.5); }
	var closestIntervalNumber : UInt { return UInt(Double(12)*Double(log2(interval.toDouble))+0.5); }
	var equalTemperamentRatio : Double { return pow(2.0,Double(self.closestEqualTemperamentIntervalNumber)/Double(12)); }
	var toRatio : Double { return interval.toDouble; }
	var toCents : Double { return interval.toCents; }
	var toOctave : Double { return interval.toOctave; }
	var justIntonationPercent : Double { return Double(12)*100.0 * log2(self.interval.toDouble); }
	var error : Double { return equalTemperamentRatio-interval.toDouble; }
	var error12ETCent : Double {
		return (interval.toDouble/Double(closestIntervalNumber).ratioFromSemitone).toCents;
	}
	var oddLimit : UInt? {
		switch interval {
		case let x as RationalInterval:
			return x.ratio.oddLimit;
		default:
			return nil;
		}
	}

	var oddLimitString : String {
		if let theOddLimit = oddLimit {
			return "\(theOddLimit)";
		}
		return "n/a";
	}

	var primeLimit : UInt? {
		switch interval {
		case let x as RationalInterval:
			return x.ratio.primeLimit;
		default:
			return nil;
		}
	}

	var primeLimitString : String {
		if let thePrimeLimit = primeLimit {
			return "\(thePrimeLimit)";
		}
		return "n/a";
	}

	var factorsString : String {
		return interval.factorsString;
	}

	var	additiveDissonance : UInt? {
		return interval.additiveDissonance;
	}

	var	additiveDissonanceString : String {
		if let theAdditiveDissonance = additiveDissonance {
			return "\(theAdditiveDissonance)";
		}
		return "n/a";
	}

	var degreeName : String = "";

	var errorNETCent : Double {
		return (interval.toDouble/Double(closestIntervalNumber).ratioFromSemitone).toCents;
	}

	var closestIntervalNumberDescription : String { return "\(closestIntervalNumber)"; }
	var closestNoteDescription : String {
		var		theResult = "";
		if true {
			let		noteForIntervalNumber = [ 1, 1, 2, 2, 3, 4, 4, 5, 5, 6, 6, 7 ];
			let		theNoteNumber = Int(closestIntervalNumber)%noteForIntervalNumber.count;
			let		theOctave = Int(closestIntervalNumber)/noteForIntervalNumber.count;
			theResult = "\(noteForIntervalNumber[theNoteNumber]+theOctave*7)";
			if theNoteNumber > 1 && noteForIntervalNumber[theNoteNumber] == noteForIntervalNumber[theNoteNumber-1] {
				theResult = "\(theResult) maj";
			}
		}
		return theResult;
	}

	var isUnison : Bool {
		switch interval {
		case let x as RationalInterval:
			return x.numerator == 1 && x.denominator == 1;
		case let x as IrrationalInterval:
			return x.ratio == 1.0;
		default:
			return false;
		}
	}
	var isPerfectFourth : Bool {
		switch interval {
		case let x as RationalInterval:
			return x.numerator == 4 && x.denominator == 3;
		case let x as IrrationalInterval:
			return x.ratio == 4.0/3.0;
		default:
			return false;
		}
	}
	var isPerfectFifth : Bool {
		switch interval {
		case let x as RationalInterval:
			return x.numerator == 3 && x.denominator == 2;
		case let x as IrrationalInterval:
			return x.ratio == 3.0/2.0;
		default:
			return false;
		}
	}
	var isOctave : Bool {
		switch interval {
		case let x as RationalInterval:
			return bitCount(x.numerator) == 1 && x.denominator == 1;
		case let x as IrrationalInterval:
			let		theLog2 = log2(x.ratio);
			return theLog2 > 0 && theLog2 == floor(theLog2);
		default:
			return false;
		}
	}
	var isFirstOctave : Bool {
		switch interval {
		case let x as RationalInterval:
			return x.numerator == 2 && x.denominator == 1;
		case let x as IrrationalInterval:
			return x.ratio == 2.0;
		default:
			return false;
		}
	}

	var absError : Double { return abs(error); }
	var absError12ETCent : Double { return abs(error12ETCent); }
	var absErrorNETCent : Double { return abs(errorNETCent); }

	init( interval anInterval: Interval ) {
		self.interval = anInterval;
		super.init();
	}

	convenience init( interval anInterval: Rational ) {
		self.init( interval: RationalInterval(anInterval) )
	}

	convenience init( numberator: UInt, denominator: UInt ) {
		let		theNum = numberator;
		let		theDen = denominator;
		self.init( interval: RationalInterval(Rational(Int(theNum),Int(theDen))) )
	}

	init?( string aString: String ) {
		if let theRatio = Interval.from(string:aString) {
			self.interval = theRatio;
			super.init();
		} else {
			return nil;
		}
	}

	override var description: String { return "ratio:\(interval), closestIntervalNumber:\(closestIntervalNumber)"; }
	public override var hashValue: Int { return interval.hashValue; }
	override public func isEqual(_ anObject: Any?) -> Bool {
		let	theObject = anObject as! EqualTemperamentEntry;
		return interval == theObject.interval;
	}
	public static func == (a: EqualTemperamentEntry, b: EqualTemperamentEntry) -> Bool {
		return a.interval == b.interval;
	}

	var everyIntervalName : [String] {
		return self.interval.names ?? [];
	}
	var intervalName : String {
		return everyIntervalName.first ?? "";
	}

// NSPasteboardWriting

	func writableTypes(for pasteboard: NSPasteboard) -> [String] {
		return ["com.godofcocoa.intonation.interval",NSPasteboardTypeString,NSPasteboardTypeTabularText];
	}

	func pasteboardPropertyList(forType aType: String) -> Any? {
		switch aType {
		case NSPasteboardTypeString:
			return interval.ratioString;
		case NSPasteboardTypeTabularText:
			return "\(interval.ratioString)\t\(interval.toDouble)\t\(toCents)\t\(intervalName)";
		case "com.godofcocoa.intonation.interval":
			return interval.propertyList;
		default:
			return nil
		}
	}

// NSPasteboardReading
	static func readableTypes(for pasteboard: NSPasteboard) -> [String] {
		return ["com.godofcocoa.intonation.interval",NSPasteboardTypeString];
	}

	static func readingOptions(forType type: String, pasteboard: NSPasteboard) -> NSPasteboardReadingOptions {
		return .asPropertyList;
	}
	required init?(pasteboardPropertyList aPropertyList: Any, ofType aType: String) {
		switch aType {
		case NSPasteboardTypeString:
			if let theString = aPropertyList as? String,
				let theRatio = Interval.from(string:theString) {
				self.interval = theRatio;
			} else {
				return nil;
			}
		case "com.godofcocoa.intonation.interval":
			if let theInterval = Interval.from(propertyList:aPropertyList) {
				self.interval = theInterval;
			} else {
				return nil;
			}
		default:
			return nil
		}
		super.init();
	}
}

