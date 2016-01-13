/*
    EqualTemperamentEntry.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Foundation

func centsEquivelentForRatio( r : Double, n : UInt ) -> Double { return Double(n)*100.0 * log2(r); }
func ratioForCentsEquivelent( c : Double, n : UInt ) -> Double { return pow(2.0,c/(100.0*Double(n))); }

extension Rational {
	var oddLimit : UInt {
		let	theNum = UInt(numerator);
		let theDen = UInt(denominator);
		if theNum%2 == 1 && theDen%2 == 1 { return theNum > theDen ? theNum : theDen; }
		else if theNum%2 == 1 { return theNum; }
		else { return theDen; }
	}

	var primeLimit : UInt? {
		let		theResult : UInt? = nil;
		if numerator > 0 && denominator > 0 {
			let		theNumeratorLargestPrimeFactor = UInt(numerator).largestPrimeFactor;
			let		theDenominatorLargestPrimeFactor = UInt(denominator).largestPrimeFactor;
			return theNumeratorLargestPrimeFactor > theDenominatorLargestPrimeFactor ? theNumeratorLargestPrimeFactor : theDenominatorLargestPrimeFactor;
		}
		return theResult;
	}
}

class EqualTemperamentEntry : NSObject {
	var justIntonationRatio : Rational
	var isClose : Bool;
    dynamic var justIntonationRatioToString : String { return justIntonationRatio.ratioString; }
    dynamic var justIntonationRatioToDouble : Double { return justIntonationRatio.toDouble; }
	let intervalCount : UInt
	var name : String { return "\(justIntonationRatio.numerator):\(justIntonationRatio.denominator)"; }
	var closestEqualTemperamentIntervalNumber : UInt { return UInt(12.0*Double(log2(justIntonationRatio.toDouble))+0.5); }
	var closestIntervalNumber : UInt { return UInt(Double(self.intervalCount)*Double(log2(justIntonationRatio.toDouble))+0.5); }
	var equalTemperamentRatio : Double { return pow(2.0,Double(self.closestEqualTemperamentIntervalNumber)/Double(self.intervalCount)); }
	var justIntonationCents : Double { return centsEquivelentForRatio( self.justIntonationRatio.toDouble, n: 12 ); }
	var justIntonationPercent : Double { return centsEquivelentForRatio( self.justIntonationRatio.toDouble, n: self.intervalCount ); }
	var error : Double { return equalTemperamentRatio-justIntonationRatio.toDouble; }
	var error12ETCent : Double {
		return centsEquivelentForRatio( justIntonationRatio.toDouble/ratioForCentsEquivelent(Double(closestIntervalNumber)*100.0, n: self.intervalCount ), n: 12 );
	}
	var oddLimit : UInt { return justIntonationRatio.oddLimit; }

	var primeLimit : UInt { return justIntonationRatio.primeLimit ?? 1; }

	var degreeName : String = "";

	var errorNETCent : Double {
		return centsEquivelentForRatio(justIntonationRatio.toDouble/ratioForCentsEquivelent(Double(closestIntervalNumber)*100.0, n:intervalCount), n:12);
	}

	var interval : Interval { return Interval(ratio: self.justIntonationRatio); }

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

	var isUnison : Bool { return justIntonationRatio.numerator == 1 && justIntonationRatio.denominator == 1; }
	var isPerfectFourth : Bool { return justIntonationRatio.numerator == 4 && justIntonationRatio.denominator == 3; }
	var isPerfectFifth : Bool { return justIntonationRatio.numerator == 3 && justIntonationRatio.denominator == 2; }
	var isOctave : Bool { return justIntonationRatio.numerator != 1 && justIntonationRatio.denominator == 1; }
	var isFirstOctave : Bool { return justIntonationRatio.numerator == 2 && justIntonationRatio.denominator == 1; }

	var absError : Double { return abs(error); }
	var absError12ETCent : Double { return abs(error12ETCent); }
	var absErrorNETCent : Double { return abs(errorNETCent); }

	init( justIntonationRatio: Rational, intervalCount : UInt, maximumError: Double ) {
		self.justIntonationRatio = justIntonationRatio
		self.intervalCount = intervalCount;
		self.isClose = true;
		super.init();
		self.isClose = abs(self.error12ETCent) < 100.0*maximumError;
	}

	init( numberator: UInt, denominator: UInt, intervalCount : UInt, maximumError: Double ) {
		let		theNum = numberator;
		let		theDen = denominator;
		self.justIntonationRatio = Rational(Int(theNum),Int(theDen));
		self.intervalCount = intervalCount;
		self.isClose = true;
		super.init();
		self.isClose = abs(self.error12ETCent) < 100.0*maximumError;
	}

	override var description: String { return "ratio:\(justIntonationRatio), closestIntervalNumber:\(closestIntervalNumber)"; }
	override var hashValue: Int { return justIntonationRatio.hashValue; }

	override var hash : Int { return justIntonationRatio.hashValue; }
	override func isEqual(object: AnyObject?) -> Bool {
		return self.justIntonationRatio==(object as! EqualTemperamentEntry).justIntonationRatio;
	}
}

extension EqualTemperamentEntry {
	private static let	rationNames : [Rational:[String]] = [Rational(1,1):["unison"],
		Rational(81,80):["syntonic comma"],
		Rational(128,125):["diesis", "diminished second"],
		Rational(25,24):["lesser chromatic semitone", "minor semitone", "augmented unison"],
		Rational(256,243):["Pythagorean minor second", "Pythagorean limma"],
		Rational(135,128):["greater chromatic semitone", "wide augmented unison"],
		Rational(16,15):["major semitone", "limma", "minor second"],
		Rational(27,25):["large limma", "acute minor second"],
		Rational(800,729):["grave tone", "grave major second"],
		Rational(10,9):["minor tone", "lesser major second"],
		Rational(9,8):["major tone", "Pythagorean major second", "greater major second"],
		Rational(256,225):["diminished third"],
		Rational(125,108):["semi-augmented second"],
		Rational(75,64):["augmented second"],
		Rational(32,27):["Pythagorean minor third"],
		Rational(6,5):["minor third"],
		Rational(243,200):["acute minor third"],
		Rational(100,81):["grave major third"],
		Rational(5,4):["major third"],
		Rational(81,64):["Pythagorean major third"],
		Rational(32,25):["classic diminished fourth"],
		Rational(125,96):["classic augmented third"],
		Rational(675,512):["wide augmented third"],
		Rational(4,3):["perfect fourth"],
		Rational(27,20):["acute fourth[1]"],
		Rational(25,18):["classic augmented fourth"],
		Rational(45,32):["augmented fourth"],
		Rational(64,45):["diminished fifth"],
		Rational(36,25):["classic diminished fifth"],
		Rational(40,27):["grave fifth[1]"],
		Rational(3,2):["perfect fifth"],
		Rational(1024,675):["narrow diminished sixth"],
		Rational(192,125):["classic diminished sixth"],
		Rational(25,16):["classic augmented fifth"],
		Rational(128,81):["Pythagorean minor sixth"],
		Rational(8,5):["minor sixth"],
		Rational(81,50):["acute minor sixth"],
		Rational(5,3):["major sixth"],
		Rational(27,16):["Pythagorean major sixth"],
		Rational(128,75):["diminished seventh"],
		Rational(225,128):["augmented sixth"],
		Rational(16,9):["Pythagorean minor seventh"],
		Rational(9,5):["minor seventh"],
		Rational(729,400):["acute minor seventh"],
		Rational(50,27):["grave major seventh"],
		Rational(15,8):["major seventh"],
		Rational(256,135):["narrow diminished octave"],
		Rational(243,128):["Pythagorean major seventh"],
		Rational(48,25):["diminished octave"],
		Rational(125,64):["augmented seventh"],
		Rational(160,81):["semi-diminished octave"],
		Rational(2,1):["octave"],

		Rational(20,9):["minor ninth"],
		Rational(9,4):["major ninth"],
		Rational(12,5):["minor tenth"],
		Rational(5,2):["major tenth"],
		Rational(8,3):["major eleventh"],
		Rational(3,1):["perfect twelfth"],
		Rational(16,5):["minor thirteenth"],
		Rational(10,3):["major thirteenth"],
];
	var everyIntervalName : [String] {
		get { if let theNameList = EqualTemperamentEntry.rationNames[self.justIntonationRatio] { return theNameList; } else { return []; } }
	}
	var intervalName : String {
		get { if let theName = everyIntervalName.first { return theName; } else { return ""; } }
	}
}

func ==(a: EqualTemperamentEntry, b: EqualTemperamentEntry) -> Bool { return a.justIntonationRatio==b.justIntonationRatio; }

class EqualTemperamentCollection : CustomStringConvertible {
	var	everyEqualTemperamentEntry = Set<EqualTemperamentEntry>();
	var limits : (numeratorPrime:UInt,denominatorPrime:UInt,numeratorOdd:UInt,denominatorOdd:UInt);
	var maximumError : Double;
	var intervalCount : UInt;
	var octaves : UInt;
	var filtered : Bool;

	var averageError : Double {
		var		theAverageError : Double = 0.0;
		let		theCount = Double(everyEqualTemperamentEntry.count);
		for theEntry in everyEqualTemperamentEntry {
			theAverageError += abs(theEntry.error12ETCent);
		}
		return theAverageError/theCount
	}

	var smallestError : Set<EqualTemperamentEntry> {
		var		theResult = Set<EqualTemperamentEntry>();
		var		theError = 0.0;
		for theEntry in everyEqualTemperamentEntry {
			if !theEntry.isOctave && !theEntry.isUnison {
				if theResult.isEmpty {
					theError = abs(theEntry.error12ETCent);
					theResult = [theEntry];
				} else {
					if abs(theError.distanceTo(abs(theEntry.error12ETCent))) < 0.000001 {
						theResult.insert(theEntry);
					}
					else if theError > abs(theEntry.error12ETCent) {
						theError = abs(theEntry.error12ETCent);
						theResult = [theEntry];
					}
				}
			}
		}
		return theResult;
	}

	var biggestError : Set<EqualTemperamentEntry> {
		var		theResult = Set<EqualTemperamentEntry>();
		var		theError = 0.0;
		for theEntry in everyEqualTemperamentEntry {
			if !theEntry.isOctave && !theEntry.isUnison {
				if theResult.isEmpty {
					theError = abs(theEntry.error12ETCent);
					theResult = [theEntry];
				} else {
					if abs(theError.distanceTo(abs(theEntry.error12ETCent))) < 0.000001 {
						theResult.insert(theEntry);
					}
					else if theError < abs(theEntry.error12ETCent) {
						theError = abs(theEntry.error12ETCent);
						theResult = [theEntry];
					}
				}
			}
		}
		return theResult;
	}

	init( limits aLimits : (numeratorPrime:UInt,denominatorPrime:UInt,numeratorOdd:UInt,denominatorOdd:UInt), intervalCount anIntervalCount : UInt, octaves anOctaves : UInt, maximumError anMaximumError: Double, filtered aFiltered: Bool  ) {
		limits = aLimits;
		intervalCount = anIntervalCount;
		maximumError = anMaximumError;
		filtered = aFiltered;
		octaves = anOctaves;
		calculate();
	}

	private func calculate( ) {
		for theDenom in PrimeProducts(maxPrime: limits.denominatorPrime, range: Range<UInt>(start: 1, end: limits.denominatorOdd)) {
			for theNum in PrimeProducts(maxPrime: limits.numeratorPrime, range: Range<UInt>(start: theDenom, end: min(limits.numeratorOdd,theDenom*2))) {
				assert(theNum >= theDenom);
				assert( theNum <= theDenom*2 );
				for theOctaves in 0..<octaves {
					let		theEntry = EqualTemperamentEntry(numberator: theNum*1<<theOctaves, denominator:theDenom, intervalCount:intervalCount, maximumError: maximumError);
					let		theDegree = Scale.major.indexOf(theEntry.justIntonationRatio);
					add(theEntry);
					if theDegree != nil {
						theEntry.degreeName = Scale.degreeName(theDegree!);
					}
				}
			}
		}
	}

	func add( anEntry : EqualTemperamentEntry ) {
		if anEntry.isClose || !filtered {
			everyEqualTemperamentEntry.insert(anEntry);
		}
	}

	var everyEntry : [EqualTemperamentEntry] {
		get {
			var		theResult = Array<EqualTemperamentEntry>();
			for theEntry in everyEqualTemperamentEntry {
				theResult.append(theEntry as EqualTemperamentEntry);
			}
			theResult.sortInPlace({ return $0.justIntonationCents < $1.justIntonationCents; } );
			return theResult;
		}
	}

	var description: String {
		return "entries:\(everyEqualTemperamentEntry.debugDescription)";
	}
}