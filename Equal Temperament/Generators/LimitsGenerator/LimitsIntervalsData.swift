//
//  LimitsBasedGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 12/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class LimitsIntervalsData : IntervalsData {
	static let		numeratorPrimeLimitKey = "limits_numeratorPrimeLimit";
	static let		denominatorPrimeLimitKey = "limits_denominatorPrimeLimit";
	static let		separatePrimeLimitKey = "limits_separatePrimeLimit";
	static let		oddLimitKey = "limits_oddLimit";
	static let		additiveDissonanceKey = "limits_additiveDissonance";
	override init() {
		numeratorPrimeLimitIndex = UserDefaults.standard.integer(forKey: LimitsIntervalsData.numeratorPrimeLimitKey);
		denominatorPrimeLimitIndex = UserDefaults.standard.integer(forKey: LimitsIntervalsData.denominatorPrimeLimitKey);
		separatePrimeLimit = UserDefaults.standard.bool(forKey: LimitsIntervalsData.separatePrimeLimitKey);
		oddLimit = UInt(UserDefaults.standard.integer(forKey: LimitsIntervalsData.oddLimitKey)) | 1;
		additiveDissonance = UInt(UserDefaults.standard.integer(forKey: LimitsIntervalsData.additiveDissonanceKey)) | 1;
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
			willChangeValue(forKey: "numeratorPrimeLimit");
			numeratorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(newValue) ?? 2;
			didChangeValue(forKey: "numeratorPrimeLimit");
		}
	}
	@objc dynamic var		numeratorPrimeLimitIndex : Int = 2 {
		willSet {
			willChangeValue(forKey: "numeratorPrimeLimit");
		}
		didSet {
			UserDefaults.standard.set(Int(numeratorPrimeLimitIndex), forKey:LimitsIntervalsData.numeratorPrimeLimitKey);
			didChangeValue(forKey: "numeratorPrimeLimit");
		}
	}
	@objc dynamic var		denominatorPrimeLimit : UInt {
		get {
			return PrimesSequence(end:100)[denominatorPrimeLimitIndex];
		}
		set {
			willChangeValue(forKey: "denominatorPrimeLimit");
			denominatorPrimeLimitIndex = IntervalsData.indexForLargestPrimeLessThanOrEuqalTo(newValue) ?? 2;
			didChangeValue(forKey: "denominatorPrimeLimit");
		}
	}
	@objc dynamic var		denominatorPrimeLimitIndex : Int = 1 {
		willSet {
			willChangeValue(forKey: "denominatorPrimeLimit");
		}
		didSet {
			UserDefaults.standard.set(Int(denominatorPrimeLimitIndex), forKey:LimitsIntervalsData.denominatorPrimeLimitKey);
			didChangeValue(forKey: "denominatorPrimeLimit");
		}
	}
	@objc dynamic var		separatePrimeLimit : Bool = false {
		didSet {
			UserDefaults.standard.set( separatePrimeLimit, forKey:LimitsIntervalsData.separatePrimeLimitKey);
		}
	}
	@objc dynamic var		oddLimit : UInt = 15 {
		didSet {
			if( oddLimit%2 == 0 ) { oddLimit += 1; }
			UserDefaults.standard.set( Int(oddLimit), forKey:LimitsIntervalsData.oddLimitKey);
		}
	}
	@objc dynamic var		additiveDissonance : UInt = UInt.max {
		didSet {
			UserDefaults.standard.set( Int(additiveDissonance), forKey:LimitsIntervalsData.additiveDissonanceKey);
		}
	}
}

class LimitsBasedGenerator : IntervalsDataGenerator {
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
							for theOctaves in 0..<octavesCount {
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
//		octaves = anIntervalsData.octavesCount;
		limits = (numeratorPrime:anIntervalsData.numeratorPrimeLimit, denominatorPrime:theDenominatorPrimeLimit, odd:anIntervalsData.oddLimit, additiveDissonance:anIntervalsData.additiveDissonance);
		super.init(intervalsData:anIntervalsData);
	}
}