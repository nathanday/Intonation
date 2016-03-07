//
//  IntervalsData.swift
//  Equal Temperament
//
//  Created by Nathan Day on 4/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class IntervalsData: NSObject {
	static let		minimumBaseFrequency = 20.0;
	static let		maximumBaseFrequency = 4_200.0;

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
		if let theSelectedMethod = aPropertyList["selectedMethod"] as? UInt,
			theIntervalCount = aPropertyList["intervalCount"] as? UInt,
			theLimits = aPropertyList["limits"] as? [String:UInt],
			theEnableInterval = aPropertyList["enableInterval"] as? Bool,
			themMaximumError = aPropertyList["maximumError"] as? Double,
			theFiltered = aPropertyList["filtered"] as? Bool,
			theOctavesCount = aPropertyList["octavesCount"] as? UInt,
			theAutoAnchor = aPropertyList["autoAnchor"] as? Bool,
			theMidiAnchor = aPropertyList["midiAnchor"] as? Int,
			theTone = aPropertyList["tone"] as? [String:AnyObject]
		{
			selectedMethod = theSelectedMethod;
			intervalCount = theIntervalCount
			if let theNumeratorPrimeLimit = theLimits["numeratorPrime"] {
				numeratorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(theNumeratorPrimeLimit) ?? 2;
			}
			if let theDenominatorPrimeLimit = theLimits["denominatorPrime"] {
				denominatorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(theDenominatorPrimeLimit) ?? 2;
			}
			if let theOddLimit = theLimits["oddLimit"] {
				oddLimit = theOddLimit;
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
		return [
			"selectedMethod":selectedMethod,
			"intervalCount":intervalCount,
			"limits":[
				"numeratorPrime":numeratorPrimeLimit,
				"denominatorPrime":denominatorPrimeLimit,
				"oddLimit":oddLimit,
				"additiveDissonance":additiveDissonance],
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
	}

	static var		primeNumber = UInt.primes(upTo: 100 );
	static func	indexForLargestPrimeLessThanOrEuqalTo( aPrime : UInt ) -> Int? {
		for i in 1...primeNumber.endIndex {
			if primeNumber[i] > aPrime { return i-1; }
		}
		return nil;
	}

	var		selectedMethod : UInt = 0;
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
	var		additiveDissonance : UInt = 256 {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger( Int(additiveDissonance), forKey:"additiveDissonance");
		}
	}

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
