/*
    EqualTemperamentEntry.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Foundation

func ratioForCentsEquivelent( c : Double, n : UInt ) -> Double { return pow(2.0,c/(100.0*Double(n))); }

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

class EqualTemperamentEntry : NSObject {
	var justIntonationRatio : Interval
	var isClose : Bool;
    dynamic var justIntonationRatioToString : String { return justIntonationRatio.toString; }
    dynamic var justIntonationRatioToDouble : Double { return justIntonationRatio.toDouble; }
	let intervalCount : UInt
	var name : String { return justIntonationRatio.toString; }
	var closestEqualTemperamentIntervalNumber : UInt { return UInt(12.0*Double(log2(justIntonationRatio.toDouble))+0.5); }
	var closestIntervalNumber : UInt { return UInt(Double(self.intervalCount)*Double(log2(justIntonationRatio.toDouble))+0.5); }
	var equalTemperamentRatio : Double { return pow(2.0,Double(self.closestEqualTemperamentIntervalNumber)/Double(self.intervalCount)); }
	var justIntonationCents : Double { return justIntonationRatio.toDouble.toCents; }
	var justIntonationPercent : Double { return Double(self.intervalCount)*100.0 * log2(self.justIntonationRatio.toDouble); }
	var error : Double { return equalTemperamentRatio-justIntonationRatio.toDouble; }
	var error12ETCent : Double {
		return (justIntonationRatio.toDouble/ratioForCentsEquivelent(Double(closestIntervalNumber)*100.0, n: self.intervalCount )).toCents;
	}
	var oddLimit : UInt {
		switch justIntonationRatio {
		case let x as RationalInterval:
			return x.ratio.oddLimit;
		default:
			return UInt.max;
		}
	}

	var primeLimit : UInt {
		switch justIntonationRatio {
		case let x as RationalInterval:
			return x.ratio.primeLimit;
		default:
			return UInt.max;
		}
	}
	var factorsString : String {
		switch justIntonationRatio {
		case let x as RationalInterval:
			return x.ratio.factorsString;
		default:
			return justIntonationRatio.toString;
		}
	}

	var	additiveDissonance : UInt {
		return justIntonationRatio.additiveDissonance;
	}

	var degreeName : String = "";

	var errorNETCent : Double {
		return (justIntonationRatio.toDouble/ratioForCentsEquivelent(Double(closestIntervalNumber)*100.0, n:intervalCount)).toCents;
	}

	var interval : Interval? {
		switch justIntonationRatio {
		case let x as RationalInterval:
			return x;
		default:
			return nil;
		}
	}

	var closestIntervalNumberDescription : String { return isClose ? "\(closestIntervalNumber)" : ""; }
	var closestNoteDescription : String {
		var		theResult = "";
		if isClose {
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
		switch justIntonationRatio {
		case let x as RationalInterval:
			return x.numerator == 1 && x.denominator == 1;
		case let x as IrrationalInterval:
			return x.ratio == 1.0;
		default:
			return false;
		}
	}
	var isPerfectFourth : Bool {
		switch justIntonationRatio {
		case let x as RationalInterval:
			return x.numerator == 4 && x.denominator == 3;
		case let x as IrrationalInterval:
			return x.ratio == 4.0/3.0;
		default:
			return false;
		}
	}
	var isPerfectFifth : Bool {
		switch justIntonationRatio {
		case let x as RationalInterval:
			return x.numerator == 3 && x.denominator == 2;
		case let x as IrrationalInterval:
			return x.ratio == 3.0/2.0;
		default:
			return false;
		}
	}
	var isOctave : Bool {
		switch justIntonationRatio {
		case let x as RationalInterval:
			return bitCount(x.numerator) == 1 && x.denominator == 1;
		case let x as IrrationalInterval:
			let		theLog2 = log2(x.ratio);
			return theLog2 == floor(theLog2);
		default:
			return false;
		}
	}
	var isFirstOctave : Bool {
		switch justIntonationRatio {
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

	init( justIntonationRatio: Interval, intervalCount : UInt, maximumError: Double ) {
		self.justIntonationRatio = justIntonationRatio;
		self.intervalCount = intervalCount;
		self.isClose = true;
		super.init();
		self.isClose = abs(self.error12ETCent) < 100.0*maximumError;
	}

	convenience init( justIntonationRatio: Rational, intervalCount : UInt, maximumError: Double ) {
		self.init( justIntonationRatio: RationalInterval(justIntonationRatio), intervalCount : intervalCount, maximumError: maximumError )
	}

	convenience init( numberator: UInt, denominator: UInt, intervalCount : UInt, maximumError: Double ) {
		let		theNum = numberator;
		let		theDen = denominator;
		self.init( justIntonationRatio: RationalInterval(Rational(Int(theNum),Int(theDen))), intervalCount : intervalCount, maximumError: maximumError )
	}

	init?( aString: String, intervalCount : UInt, maximumError: Double ) {
		if let theRatio = Interval.fromString(aString) {
			self.justIntonationRatio = theRatio;
			self.intervalCount = intervalCount;
			self.isClose = true;
			super.init();
			self.isClose = abs(self.error12ETCent) < 100.0*maximumError;
		} else {
			return nil;
		}
	}

	override var description: String { return "ratio:\(justIntonationRatio), closestIntervalNumber:\(closestIntervalNumber)"; }
	override var hashValue: Int { return justIntonationRatio.hashValue; }

	override var hash : Int { return justIntonationRatio.hashValue; }
	override func isEqual(object: AnyObject?) -> Bool {
		return self.justIntonationRatio==(object as! EqualTemperamentEntry).justIntonationRatio;
	}
}

extension EqualTemperamentEntry {
	var everyIntervalName : [String] {
		return self.justIntonationRatio.names ?? [];
	}
	var intervalName : String {
		return everyIntervalName.first ?? "";
	}
}

func ==(a: EqualTemperamentEntry, b: EqualTemperamentEntry) -> Bool { return a.justIntonationRatio==b.justIntonationRatio; }
