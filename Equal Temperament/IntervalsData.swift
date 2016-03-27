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
	case EqualTemperament;
	case Preset;
	case AdHoc;
	static func fromString( aStringValue : String? ) -> DocumentType? {
		var		theResult : DocumentType? = nil;
		if aStringValue == "limits" {
			theResult = .Limits;
		} else if aStringValue == "stackedIntervals" {
			theResult = .StackedIntervals;
		} else if aStringValue == "equalTemperament" {
			theResult = .EqualTemperament;
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
		case EqualTemperament:
			return "equalTemperament";
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
			return StackedIntervalsDataGenerator(intervalsData:anIntervalsData);
		case EqualTemperament:
			return EqualTemperamentGenerator(intervalsData:anIntervalsData);
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
		autoAnchor = NSUserDefaults.standardUserDefaults().boolForKey("autoAnchor");
		midiAnchor = Int(NSUserDefaults.standardUserDefaults().integerForKey("midiAnchor"));
	}

	init(withPropertyList aPropertyList: [String:AnyObject] ) {
		if let theLimits = aPropertyList["limits"] as? [String:UInt],
			theOctavesCount = aPropertyList["octavesCount"] as? UInt,
			theAutoAnchor = aPropertyList["autoAnchor"] as? Bool,
			theMidiAnchor = aPropertyList["midiAnchor"] as? Int,
			theTone = aPropertyList["tone"] as? [String:AnyObject]
		{
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
				case .EqualTemperament:
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
			case .EqualTemperament:
				theResult["limits"] = [
					"degrees":equalTemperamentDegrees,
					"interval":equalTemperamentInterval.toString
				];
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
	dynamic var		equalTemperamentDegrees : UInt = 12;
	var		equalTemperamentInterval = RationalInterval(2,1);

	var		octavesCount : UInt = 1 {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(octavesCount), forKey:"octavesCount");
		}
	}
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
	var		stackedIntervals = Set<StackedIntervalSet>();
	var		adHocEntries = Set<Interval>();

	var		autoAnchor : Bool = false {
		didSet { NSUserDefaults.standardUserDefaults().setBool( autoAnchor, forKey:"autoAnchor"); }
	}
	dynamic var		midiAnchor : Int = 60 {
		didSet { NSUserDefaults.standardUserDefaults().setInteger(midiAnchor, forKey: "midiAnchor"); }
	}

	var		baseFrequency : Double = 220.0;

	var		overtones : HarmonicsDescription = HarmonicsDescription( amount : 0.5, evenAmount: 1.0 );
	var		arpeggioInterval : Double = 0.5;
}
