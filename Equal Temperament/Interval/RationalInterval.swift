//
//  Interval.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class RationalInterval : Interval {
	private static let	intervalNames : [Rational:[String]] = {
		var theResult = [Rational:[String]]()
		guard let theIntervalNames = UserDefaults.standard.array(forKey: "intervalNames") else {
			return theResult;
		}
		for theEntry in theIntervalNames as! [[String:Any]] {
			if let theRatioString = theEntry["ratio"] as? String,
				let theNames = theEntry["names"] as? [String] {
				if !theRatioString.contains(".") {
					if let theRatio = Rational(theRatioString) {
						precondition(theResult[theRatio] == nil, "Already have \(theRatio)=\(String(describing: theResult[theRatio]))" );
						theResult[theRatio] = theNames;
					}
				}
			}
		}
		return theResult;
	}()
	let		ratio: Rational;
	override var toDouble : Double { return Double(ratio); }
	override var toString : String { return String(ratio); }
	override var propertyList : [String:Any] {
		var		theResult : [String:Any] = ["numerator":numerator, "denominator":denominator];
		if names != nil && names!.count > 0 {
			theResult["names"] = names;
		}
		return theResult;
	}
//	var		justInternation : Double { return Double(ratio); }
	var		numerator: Int { return ratio.numerator; }
	var		denominator: Int { return ratio.denominator; }
	init( ratio aRatio: Rational, names aNames: [String]? ) {
		ratio = aRatio;
		super.init( names:aNames );
	}
	convenience init( _ aRatio: Rational ) {
		let		theNames = RationalInterval.intervalNames[aRatio];
		self.init( ratio: aRatio, names:theNames );
	}
	convenience init( _ aNumerator: Int, _ aDenominator : Int ) {
		let		theRational = Rational(aNumerator,aDenominator);
		let		theNames = RationalInterval.intervalNames[theRational];
		self.init( ratio: theRational, names:theNames );
	}
	convenience init( _ aNumerator: UInt, _ aDenominator : UInt ) {
		self.init( Int(aNumerator), Int(aDenominator) );
	}
	convenience init( _ anInteger: UInt ) {
		self.init( Int(anInteger), 1 );
	}
	convenience init( _ anInteger: Int ) {
		self.init( anInteger, 1 );
	}
//	convenience init?( propertyList aPropertyList: [String:Any] ) {
//		var		theEveryName : [String] = [];
//		if let theNames = aPropertyList["names"] as? [String] {
//			theEveryName = theNames;
//		}
//		if let theNumerator = aPropertyList["numerator"] as? Int,
//				theDenominator = aPropertyList["denominator"] as? Int {
//			self.init( ratio: Rational(theNumerator,theDenominator), names: theEveryName );
//		} else if let theRatioString = aPropertyList["ratio"] as? String {
//			if let theRatio = Rational(theRatioString) {
//				self.init( ratio: theRatio, names: theEveryName );
//			}
//		} else {
//			return nil;
//		}
//	}
//	convenience init?( _ aString : String ) {
//		if let theValue = Rational(aString) {
//			self.init( ratio:theValue, names:nil );
//		}
//	}
	class override func from( string aString : String? ) -> RationalInterval? {
		var		theResult : RationalInterval?
		if let theString = aString {
			if let theValue = Rational(theString) {
				theResult = RationalInterval(theValue);
			}
		}
		return theResult;
	}
	static func == (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio==b.ratio; }
	override var oddLimit : UInt? { return ratio.oddLimit; }
	override var primeLimit : UInt? { return ratio.primeLimit; }
	override var factorsString : String { return ratio.factorsString; }
	override var ratioString : String { return ratio.ratioString; }
	override var additiveDissonance : UInt? { return ratio.additiveDissonance; }
	override func numeratorForDenominator( _ aDenominator: Int ) -> Int? {
		return ratio.numeratorForDenominator(aDenominator);
	}

	static func < (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio < b.ratio; }
	static func < (a: RationalInterval, b: Int) -> Bool { return a.ratio < b; }
	static func <= (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio <= b.ratio; }
	static func > (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio > b.ratio; }
	static func > (a: RationalInterval, b: Int) -> Bool { return a.ratio > b; }
	static func >= (a: RationalInterval, b: RationalInterval) -> Bool { return a.ratio >= b.ratio; }
	static func == (a: RationalInterval, b: Int) -> Bool { return a.ratio==b; }
	static func * (a: RationalInterval, b: RationalInterval) -> RationalInterval { return RationalInterval(a.ratio * b.ratio); }
	static func * (a: RationalInterval, b: Int) -> RationalInterval { return RationalInterval(a.ratio * b); }
	static func *= (a: inout RationalInterval, b: RationalInterval) { a = RationalInterval(a.ratio*b.ratio); }
	static func *= (a: inout RationalInterval, b: Int) { a = RationalInterval(a.ratio*b); }
}
