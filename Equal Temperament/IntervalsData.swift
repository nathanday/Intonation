//
//  IntervalsData.swift
//  Intonation
//
//  Created by Nathan Day on 4/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

enum DocumentType {
	case Limits;
	case StackedIntervals;
	case Preset;
	case AdHoc;
	static func fromString( aStringValue : String? ) -> DocumentType? {
		var		theResult : DocumentType? = nil;
		if aStringValue == "limits" {
			theResult = .Limits;
		} else if aStringValue == "stackedIntervals" {
			theResult = .StackedIntervals;
		} else if aStringValue == "preset" {
			theResult = .Preset;
		} else if aStringValue == "adHoc" {
			theResult = .AdHoc;
		}
		return theResult;
	}
	func toString() -> String {
		switch self {
		case Limits:
			return "limits";
		case StackedIntervals:
			return "stackedIntervals";
		case Preset:
			return "preset";
		case AdHoc:
			return "adHoc";
		}
	}
	func intervalsDataGenerator(intervalsData anIntervalsData: IntervalsData) -> IntervalsDataGenerator {
		switch self {
		case Limits:
			return LimitsBasedGenerator(intervalsData:anIntervalsData);
		case StackedIntervals:
			return LimitsBasedGenerator(intervalsData:anIntervalsData);
		case Preset:
			return LimitsBasedGenerator(intervalsData:anIntervalsData);
		case AdHoc:
			return AdHocGenerator(intervalsData:anIntervalsData);
		}
	}
}


class IntervalsData: NSObject {
	static let		minimumBaseFrequency = 16.0;
	static let		maximumBaseFrequency = 12_544.0;

	override init() {
		numeratorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(UInt(NSUserDefaults.standardUserDefaults().integerForKey("numeratorPrimeLimit"))) ?? 2;
		denominatorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(UInt(NSUserDefaults.standardUserDefaults().integerForKey("denominatorPrimeLimit"))) ?? 2;
		separatePrimeLimit = NSUserDefaults.standardUserDefaults().boolForKey("separatePrimeLimit");
		oddLimit = UInt(NSUserDefaults.standardUserDefaults().integerForKey("oddLimit")) | 1;
		additiveDissonance = UInt(NSUserDefaults.standardUserDefaults().integerForKey("additiveDissonance")) | 1;
		octavesCount = min(max(UInt(NSUserDefaults.standardUserDefaults().integerForKey("octavesCount")),1),3);
		maximumError = Double(NSUserDefaults.standardUserDefaults().doubleForKey("maximumError"));
		filtered = NSUserDefaults.standardUserDefaults().boolForKey("filtered");
		autoAnchor = NSUserDefaults.standardUserDefaults().boolForKey("autoAnchor");
		midiAnchor = Int(NSUserDefaults.standardUserDefaults().integerForKey("midiAnchor"));
	}

	init(withPropertyList aPropertyList: [String:AnyObject] ) {
		if let theIntervalCount = aPropertyList["intervalCount"] as? UInt,
			theLimits = aPropertyList["limits"] as? [String:UInt],
			theEnableInterval = aPropertyList["enableInterval"] as? Bool,
			themMaximumError = aPropertyList["maximumError"] as? Double,
			theFiltered = aPropertyList["filtered"] as? Bool,
			theOctavesCount = aPropertyList["octavesCount"] as? UInt,
			theAutoAnchor = aPropertyList["autoAnchor"] as? Bool,
			theMidiAnchor = aPropertyList["midiAnchor"] as? Int,
			theTone = aPropertyList["tone"] as? [String:AnyObject]
		{
			intervalCount = theIntervalCount
			if let theDocumentType = aPropertyList["documentType"] as? String {
				documentType = DocumentType.fromString(theDocumentType);
			if let theDocumentType = documentType {
				switch theDocumentType {
				case .Limits:
					if let theNumeratorPrimeLimit = theLimits["numeratorPrime"] {
						numeratorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(theNumeratorPrimeLimit) ?? 2;
					}
					if let theDenominatorPrimeLimit = theLimits["denominatorPrime"] {
						denominatorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(theDenominatorPrimeLimit) ?? 2;
					}
					if let theOddLimit = theLimits["oddLimit"] {
						oddLimit = theOddLimit;
					}
				case .StackedIntervals:
					break;
				case .Preset:
					break;
				case .AdHoc:
					if let theOddLimit = aPropertyList["adHoc"] as? [String] {
						var		theEntites = Set<Interval>();
						for theEntityString in theOddLimit {
							if let theInterval = Interval.fromString(theEntityString) {
								theEntites.insert(theInterval);
							}
						}
					}
					break;
				}
			}
			}
			if let theAdditiveDissonance = theLimits["additiveDissonance"] {
				additiveDissonance = theAdditiveDissonance;
			}
			enableInterval = theEnableInterval;
			maximumError = themMaximumError;
			filtered = theFiltered;
			octavesCount = theOctavesCount;
			autoAnchor = theAutoAnchor;
			midiAnchor = theMidiAnchor;
			if let theBaseFrequency = theTone["baseFrequency"] as? Double {
				baseFrequency = theBaseFrequency;
			}
			if let theAllOvertonesAmount = theTone["allOvertonesAmount"] as? Double,
				theEvenOvertonesAmount = theTone["evenOvertonesAmount"] as? Double {
				overtones = HarmonicsDescription(amount: theAllOvertonesAmount, evenAmount: theEvenOvertonesAmount);
			}
		}
	}

	var propertyListValue : [String:AnyObject] {
		var		theResult : [String:AnyObject] = [
			"intervalCount":intervalCount,
			"enableInterval":enableInterval,
			"maximumError":maximumError,
			"filtered":filtered,
			"autoAnchor":autoAnchor,
			"octavesCount":octavesCount,
			"midiAnchor":midiAnchor,
			"tone":[
				"baseFrequency":baseFrequency,
				"allOvertonesAmount":overtones.amount,
				"evenOvertonesAmount":overtones.evenAmount
			]
		];
		if let theDocumentType = documentType {
			theResult["documentType"] = theDocumentType.toString();
			switch theDocumentType {
			case .Limits:
				theResult["limits"] = [
					"numeratorPrime":numeratorPrimeLimit,
					"denominatorPrime":denominatorPrimeLimit,
					"oddLimit":oddLimit,
					"additiveDissonance":additiveDissonance];
			case .StackedIntervals:
				break;
			case .Preset:
				break;
			case .AdHoc:
				var		theEntires = [String]();
				for theInterval in adHocEntries {
					theEntires.append(theInterval.toString)
				}
				theResult["adHoc"] = theEntires;
			}
		}
		return theResult;
	}

	static var		primeNumber = UInt.primes(upTo: 100 );
	static func	indexForLargestPrimeLessThanOrEuqalTo( aPrime : UInt ) -> Int? {
		for i in 1...primeNumber.endIndex {
			if primeNumber[i] > aPrime { return i-1; }
		}
		return nil;
	}

	var		documentType : DocumentType?;
	var		intervalCount : UInt = 12 {
		didSet {
			enableInterval = true;
		}
	}
	var		octavesCount : UInt = 1 {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(octavesCount), forKey:"octavesCount");
		}
	}
	dynamic var		enableInterval : Bool = true
	var		numeratorPrimeLimit : UInt {
		get {
			return IntervalsData.primeNumber[numeratorPrimeLimitIndex];
		}
		set {
			willChangeValueForKey("numeratorPrimeLimitIndex");
			self.numeratorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(newValue) ?? 2;
			didChangeValueForKey("numeratorPrimeLimitIndex");
		}
	}
	var		numeratorPrimeLimitIndex : Int = 2 {
		willSet {
			willChangeValueForKey("numeratorPrimeLimit");
		}
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(numeratorPrimeLimit), forKey:"numeratorPrimeLimit");
			didChangeValueForKey("numeratorPrimeLimit");
		}
	}
	var		denominatorPrimeLimit : UInt {
		get {
			return IntervalsData.primeNumber[denominatorPrimeLimitIndex];
		}
		set {
			willChangeValueForKey("denominatorPrimeLimitIndex");
			denominatorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(newValue) ?? 2;
			didChangeValueForKey("denominatorPrimeLimitIndex");
		}
	}
	var		denominatorPrimeLimitIndex : Int = 1 {
		willSet {
			willChangeValueForKey("denominatorPrimeLimit");
		}
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(denominatorPrimeLimit), forKey:"denominatorPrimeLimit");
			didChangeValueForKey("denominatorPrimeLimit");
		}
	}
	var		separatePrimeLimit : Bool = false {
		didSet {
			NSUserDefaults.standardUserDefaults().setBool( separatePrimeLimit, forKey:"separatePrimeLimit");
		}
	}
	var		oddLimit : UInt = 15 {
		didSet {
			if( oddLimit%2 == 0 ) { oddLimit += 1; }
			NSUserDefaults.standardUserDefaults().setInteger( Int(oddLimit), forKey:"oddLimit");
		}
	}
	var		additiveDissonance : UInt = UInt.max {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger( Int(additiveDissonance), forKey:"additiveDissonance");
		}
	}
	var		adHocEntries = Set<Interval>();

	var		maximumError : Double = 0.18 {
		didSet {
			NSUserDefaults.standardUserDefaults().setDouble( maximumError, forKey:"maximumError");
		}
	}
	var		filtered : Bool = false {
		didSet {
			NSUserDefaults.standardUserDefaults().setBool( filtered, forKey:"filtered");
		}
	}
	var		autoAnchor : Bool = false {
		didSet { NSUserDefaults.standardUserDefaults().setBool( autoAnchor, forKey:"autoAnchor"); }
	}
//	var		equalTemperament : Bool = false {
//		didSet {
//			NSUserDefaults.standardUserDefaults().setBool( equalTemperament, forKey:"equalTemperament");
//			tonePlayer.equalTemperament = equalTemperament;
//		}
//	}
	dynamic var		midiAnchor : Int = 60 {
		didSet { NSUserDefaults.standardUserDefaults().setInteger(midiAnchor, forKey: "midiAnchor"); }
	}

	var		baseFrequency : Double = 220.0;

	var		overtones : HarmonicsDescription = HarmonicsDescription( amount : 0.5, evenAmount: 1.0 );
	var		arpeggioInterval : Double = 0.5;
}
