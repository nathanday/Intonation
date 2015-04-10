/*
    EqualTemperamentEntry.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright (c) 2014 Nathan Day. All rights reserved.
 */

import Foundation

func centsEquivelentForRatio( r : Double, n : UInt ) -> Double { return Double(n)*100.0 * log2(r); }
func rationsForCentsEquivelent( c : Double, n : UInt ) -> Double { return pow(2.0,c/(100.0*Double(n))); }

extension Rational {
	var oddLimit : UInt {
		let	theNum = UInt(numerator);
		let theDen = UInt(denominator);
		if theNum%2 == 1 && theDen%2 == 1 { return theNum > theDen ? theNum : theDen; }
		else if theNum%2 == 1 { return theNum; }
		else { return theDen; }
	}

	var primeLimit : UInt? {
		var		theResult : UInt? = nil;
		if numerator > 0 && denominator > 0 {
			let		theNumeratorLargestPrimeFactor = UInt(numerator).largestPrimeFactor;
			let		theDenominatorLargestPrimeFactor = UInt(denominator).largestPrimeFactor;
			return theNumeratorLargestPrimeFactor > theDenominatorLargestPrimeFactor ? theNumeratorLargestPrimeFactor : theDenominatorLargestPrimeFactor;
		}
		return theResult;
	}
}

class EqualTemperamentEntry : NSObject, Printable, Hashable {
	var justIntonationRatio : Rational
	var isClose : Bool;
    dynamic var justIntonationRatioToString : String { return justIntonationRatio.ratioString; }
    dynamic var justIntonationRatioToDouble : Double { return justIntonationRatio.toDouble; }
	let intervalCount : UInt
	var name : String { return "\(justIntonationRatio.numerator):\(justIntonationRatio.denominator)"; }
	var closestEqualTemperamentIntervalNumber : UInt { return UInt(12.0*Double(log2(justIntonationRatio.toDouble))+0.5); }
	var closestIntervalNumber : UInt { return UInt(Double(self.intervalCount)*Double(log2(justIntonationRatio.toDouble))+0.5); }
	var equalTemperamentRatio : Double { return pow(2.0,Double(self.closestEqualTemperamentIntervalNumber)/Double(self.intervalCount)); }
	var justIntonationCents : Double { return centsEquivelentForRatio( self.justIntonationRatio.toDouble, 12 ); }
	var justIntonationPercent : Double { return centsEquivelentForRatio( self.justIntonationRatio.toDouble, self.intervalCount ); }
	var error : Double { return equalTemperamentRatio-justIntonationRatio.toDouble; }
	var errorCent : Double {
		return centsEquivelentForRatio( rationsForCentsEquivelent(100.0*Double(closestIntervalNumber), intervalCount), 12)-centsEquivelentForRatio( self.justIntonationRatio.toDouble, 12 );
	}
	var oddLimit : UInt { return justIntonationRatio.oddLimit; }
	
	var primeLimit : UInt { return justIntonationRatio.primeLimit ?? 1; }
	
	var degreeName : String = "";
	
	var errorPercent : Double {
		return Double(closestIntervalNumber)*100.0-centsEquivelentForRatio( justIntonationRatio.toDouble, intervalCount );
	}
	
	var closestIntervalNumberDescription : String { return isClose ? "\(closestIntervalNumber)" : ""; }

	var isUnison : Bool { return justIntonationRatio.numerator == 1 && justIntonationRatio.denominator == 1; }
	var isPerfectFourth : Bool { return justIntonationRatio.numerator == 4 && justIntonationRatio.denominator == 3; }
	var isPerfectFifth : Bool { return justIntonationRatio.numerator == 3 && justIntonationRatio.denominator == 2; }
	var isOctave : Bool { return justIntonationRatio.numerator != 1 && justIntonationRatio.denominator == 1; }
	var isFirstOctave : Bool { return justIntonationRatio.numerator == 2 && justIntonationRatio.denominator == 1; }

	var absError : Double { return abs(error); }
	var absErrorCent : Double { return abs(errorCent); }
	var absErrorPercent : Double { return abs(errorPercent); }

	init( justIntonationRatio: Rational, intervalCount : UInt, maximumError: Double ) {
		self.justIntonationRatio = justIntonationRatio
		self.intervalCount = intervalCount;
		self.isClose = true;
		super.init();
		self.isClose = abs(self.errorPercent) < 100.0*maximumError;
	}

	init( numberator: UInt, denominator: UInt, intervalCount : UInt, maximumError: Double ) {
		var		theNum = numberator;
		var		theDen = denominator;
		while( theNum < denominator ) {
			theNum *= 2;
		}
		while( theDen*2 < numberator ) {
			theDen *= 2;
		}
		self.justIntonationRatio = Rational(Int(theNum),Int(theDen));
		self.intervalCount = intervalCount;
		self.isClose = true;
		super.init();
		self.isClose = abs(self.errorCent) < 100.0*maximumError;
	}
	
	override var description: String { return "ratio:\(justIntonationRatio), closestIntervalNumber:\(closestIntervalNumber)"; }
	override var hashValue: Int { return justIntonationRatio.hashValue; }
	
	override var hash : Int { return justIntonationRatio.hashValue; }
	override func isEqual(object: AnyObject?) -> Bool {
		return self.justIntonationRatio==(object as! EqualTemperamentEntry).justIntonationRatio;
	}
}

func ==(a: EqualTemperamentEntry, b: EqualTemperamentEntry) -> Bool { return a.justIntonationRatio==b.justIntonationRatio; }

class EqualTemperamentCollection : Printable {
	var	everyEqualTemperamentEntry = Set<EqualTemperamentEntry>();
	var limits : (numeratorPrime:UInt,denominatorPrime:UInt,numeratorOdd:UInt,denominatorOdd:UInt);
	var maximumError : Double;
	var intervalCount : UInt;
	var filtered : Bool;

	var averageError : Double {
		var		theAverageError : Double = 0.0;
		let		theCount = Double(everyEqualTemperamentEntry.count);
		for theEntry in everyEqualTemperamentEntry {
			theAverageError += abs(theEntry.errorCent);
		}
		return theAverageError/theCount
	}
	
	var smallestError : Set<EqualTemperamentEntry> {
		var		theResult = Set<EqualTemperamentEntry>();
		var		theError = 0.0;
		for theEntry in everyEqualTemperamentEntry {
			if !theEntry.isOctave && !theEntry.isUnison {
				if theResult.isEmpty {
					theError = abs(theEntry.errorCent);
					theResult = [theEntry];
				} else {
					if abs(theError.distanceTo(abs(theEntry.errorCent))) < 0.000001 {
						theResult.insert(theEntry);
					}
					else if theError > abs(theEntry.errorCent) {
						theError = abs(theEntry.errorCent);
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
					theError = abs(theEntry.errorCent);
					theResult = [theEntry];
				} else {
					if abs(theError.distanceTo(abs(theEntry.errorCent))) < 0.000001 {
						theResult.insert(theEntry);
					}
					else if theError < abs(theEntry.errorCent) {
						theError = abs(theEntry.errorCent);
						theResult = [theEntry];
					}
				}
			}
		}
		return theResult;
	}

	init( limits aLimits : (numeratorPrime:UInt,denominatorPrime:UInt,numeratorOdd:UInt,denominatorOdd:UInt), intervalCount anIntervalCount : UInt, maximumError anMaximumError: Double, filtered aFiltered: Bool  ) {
		limits = aLimits;
		intervalCount = anIntervalCount;
		maximumError = anMaximumError;
		filtered = aFiltered;
		calculate();
	}

	private func calculate( ) {
		for theDenom in PrimeProducts(maxPrime: limits.denominatorPrime, range: Range<UInt>(start: 1, end: limits.denominatorOdd)) {
			for theNum in PrimeProducts(maxPrime: limits.numeratorPrime, range: Range<UInt>(start: theDenom, end: limits.numeratorOdd)) {
				let		theEntry = EqualTemperamentEntry(numberator: theNum, denominator:theDenom, intervalCount:intervalCount, maximumError: maximumError);
				let		theDegree = Scale.major.indexOf(theEntry.justIntonationRatio);
				add(theEntry);
				if theDegree != nil {
					theEntry.degreeName = Scale.degreeName(theDegree!);
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
			sort( &theResult, { return $0.justIntonationCents < $1.justIntonationCents; } );
			return theResult;
		}
	}
	
	var description: String {
		return "entries:\(everyEqualTemperamentEntry.debugDescription)";
	}
}