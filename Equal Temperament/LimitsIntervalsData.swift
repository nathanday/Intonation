//
//  LimitsBasedGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 12/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class LimitsIntervalsData : IntervalsData {
	override init() {
		numeratorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(UInt(NSUserDefaults.standardUserDefaults().integerForKey("numeratorPrimeLimit"))) ?? 2;
		denominatorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(UInt(NSUserDefaults.standardUserDefaults().integerForKey("denominatorPrimeLimit"))) ?? 2;
		separatePrimeLimit = NSUserDefaults.standardUserDefaults().boolForKey("separatePrimeLimit");
		oddLimit = UInt(NSUserDefaults.standardUserDefaults().integerForKey("oddLimit")) | 1;
		additiveDissonance = UInt(NSUserDefaults.standardUserDefaults().integerForKey("additiveDissonance")) | 1;
		super.init();
	}
	override init?(propertyList aPropertyList: [String:AnyObject] ) {
		if let theLimits = aPropertyList["limits"] as? [String:UInt] {
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
		}
		super.init(propertyList:aPropertyList);
	}
	override var propertyListValue : [String:AnyObject] {
		var		theResult = super.propertyListValue;
		theResult["limits"] = [
			"numeratorPrime":numeratorPrimeLimit,
			"denominatorPrime":denominatorPrimeLimit,
			"oddLimit":oddLimit,
			"additiveDissonance":additiveDissonance];
		return theResult;
	}

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return LimitsBasedGenerator(intervalsData:self);
	}

	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return LimitsGeneratorViewController(windowController:aWindowController);
	}

	override var	documentType : DocumentType { return .Limits; }

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
}

class LimitsBasedGenerator : IntervalsDataGenerator {
	var octaves : UInt = 1;
	var	_everyEqualTemperamentEntry : [EqualTemperamentEntry]?;
	override var	everyEntry : [EqualTemperamentEntry] {
		get {
			if _everyEqualTemperamentEntry == nil {
				var		theResult = Set<EqualTemperamentEntry>();
				for theDenom in PrimeProducts(maxPrime: limits.denominatorPrime, range: 1..<limits.odd) {
					for theNum in PrimeProducts(maxPrime: limits.numeratorPrime, range: theDenom..<theDenom*2) {
						if theNum+theDenom <= limits.additiveDissonance {
							assert(theNum >= theDenom);
							assert( theNum <= theDenom*2 );
							for theOctaves in 0..<octaves {
								let		theRational = RationalInterval(theNum*1<<theOctaves,theDenom);
								let		theEntry = EqualTemperamentEntry(interval: theRational );
								theResult.insert(theEntry);
								if let theDegree = Scale.major.indexOf(theRational) {
									theEntry.degreeName = Scale.degreeName(theDegree);
								}
							}
						}
					}
				}
				_everyEqualTemperamentEntry = theResult.sort { return $0.toCents < $1.toCents; };
			}
			return _everyEqualTemperamentEntry!;
		}
	}
	var limits : (numeratorPrime:UInt,denominatorPrime:UInt,odd:UInt,additiveDissonance:UInt);

	init( intervalsData anIntervalsData : LimitsIntervalsData ) {
		let		theDenominatorPrimeLimit = anIntervalsData.separatePrimeLimit ? anIntervalsData.denominatorPrimeLimit : anIntervalsData.numeratorPrimeLimit;
		octaves = anIntervalsData.octavesCount;
		limits = (numeratorPrime:anIntervalsData.numeratorPrimeLimit, denominatorPrime:theDenominatorPrimeLimit, odd:anIntervalsData.oddLimit, additiveDissonance:anIntervalsData.additiveDissonance);
		super.init();
	}
}