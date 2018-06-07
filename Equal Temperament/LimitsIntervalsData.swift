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
		numeratorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(UInt(UserDefaults.standard.integer(forKey: "numeratorPrimeLimit"))) ?? 2;
		denominatorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(UInt(UserDefaults.standard.integer(forKey: "denominatorPrimeLimit"))) ?? 2;
		separatePrimeLimit = UserDefaults.standard.bool(forKey: "separatePrimeLimit");
		oddLimit = UInt(UserDefaults.standard.integer(forKey: "oddLimit")) | 1;
		additiveDissonance = UInt(UserDefaults.standard.integer(forKey: "additiveDissonance")) | 1;
		super.init();
	}
	override init?(propertyList aPropertyList: [String:Any] ) {
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
	override var propertyListValue : [String:Any] {
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

	override var	documentType : DocumentType { return .limits; }

	@objc dynamic var		numeratorPrimeLimit : UInt {
		get {
			return PrimesSequence(end: 100)[numeratorPrimeLimitIndex];
		}
		set {
			willChangeValue(forKey: "numeratorPrimeLimitIndex");
			numeratorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(newValue) ?? 2;
			didChangeValue(forKey: "numeratorPrimeLimitIndex");
		}
	}
	@objc dynamic var		numeratorPrimeLimitIndex : Int = 2 {
		willSet {
			willChangeValue(forKey: "numeratorPrimeLimit");
		}
		didSet {
			UserDefaults.standard.set(Int(numeratorPrimeLimit), forKey:"numeratorPrimeLimit");
			didChangeValue(forKey: "numeratorPrimeLimit");
		}
	}
	@objc dynamic var		denominatorPrimeLimit : UInt {
		get {
			return PrimesSequence(end:100)[denominatorPrimeLimitIndex];
		}
		set {
			willChangeValue(forKey: "denominatorPrimeLimitIndex");
			denominatorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(newValue) ?? 2;
			didChangeValue(forKey: "denominatorPrimeLimitIndex");
		}
	}
	@objc dynamic var		denominatorPrimeLimitIndex : Int = 1 {
		willSet {
			willChangeValue(forKey: "denominatorPrimeLimit");
		}
		didSet {
			UserDefaults.standard.set(Int(denominatorPrimeLimit), forKey:"denominatorPrimeLimit");
			didChangeValue(forKey: "denominatorPrimeLimit");
		}
	}
	@objc dynamic var		separatePrimeLimit : Bool = false {
		didSet {
			UserDefaults.standard.set( separatePrimeLimit, forKey:"separatePrimeLimit");
		}
	}
	@objc dynamic var		oddLimit : UInt = 15 {
		didSet {
			if( oddLimit%2 == 0 ) { oddLimit += 1; }
			UserDefaults.standard.set( Int(oddLimit), forKey:"oddLimit");
		}
	}
	@objc dynamic var		additiveDissonance : UInt = UInt.max {
		didSet {
			UserDefaults.standard.set( Int(additiveDissonance), forKey:"additiveDissonance");
		}
	}
}

class LimitsBasedGenerator : IntervalsDataGenerator {
	var octaves : Int = 1;
	var	_everyIntervalEntry : [IntervalEntry]?;
	override var	everyEntry : [IntervalEntry] {
		get {
			if _everyIntervalEntry == nil {
				var		theResult = Set<IntervalEntry>();
				for theDenom in PrimeProducts(maxPrime: limits.denominatorPrime, range: 1..<limits.odd) {
					for theNum in PrimeProducts(maxPrime: limits.numeratorPrime, range: theDenom..<theDenom*2) {
						if theNum+theDenom <= limits.additiveDissonance {
							assert(theNum >= theDenom);
							assert( theNum <= theDenom*2 );
							for theOctaves in 0..<octaves {
								let		theRational = RationalInterval(theNum*1<<theOctaves,theDenom);
								let		theEntry = IntervalEntry(interval: theRational );
								theResult.insert(theEntry);
								if let theDegree = Scale.major.indexOf(theRational) {
									theEntry.degreeName = Scale.degreeName(theDegree);
								}
							}
						}
					}
				}
				_everyIntervalEntry = theResult.sorted { return $0.toCents < $1.toCents; };
			}
			return _everyIntervalEntry!;
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
