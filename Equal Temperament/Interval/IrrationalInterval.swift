//
//  Interval.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class IrrationalInterval : Interval {
	private static let	intervalNames : [UInt:[String]] = {
		var theResult = [UInt:[String]]()
		for theEntry in UserDefaults.standard.array(forKey: "intervalNames")! as! [[String:Any]] {
			if let theRatioString = theEntry["ratio"] as? String,
				let theNames = theEntry["names"] as? [String] {
				if theRatioString.contains(".") {
					if let theRatio = Double(theRatioString) {
						theResult[UInt(theRatio*4096)] = theNames;
					}
				}
				else if theRatioString.hasSuffix(":1") {
					if let theRatio = UInt( theRatioString.components(separatedBy: ":").first! ) {
						theResult[UInt(theRatio*4096)] = theNames;
					}
				}
			}
		}
		return theResult;
	}()
	let		ratio: Double;
	override var toDouble : Double { return ratio; }
	override var toString : String { return "\(ratio)"; }
	override var propertyList : [String:Any] {
		var		theResult : [String:Any] = ["value":ratio];
		if (names?.count)! > 0 {
			theResult["names"] = names;
		}
		return theResult;
	}
	static func == (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return equivelentRatios(a.ratio,b.ratio); }
	init( ratio aRatio: Double, names aNames: [String]?, factorsString aFactorsString : String? = nil ) {
		ratio = aRatio;
		_factorsString = aFactorsString;
		super.init( names:aNames );
	}
	convenience init( _ aRatio: Double, factorsString aFactorsString : String? = nil ) {
		let		theNames = IrrationalInterval.intervalNames[UInt(aRatio*4096)];
		self.init( ratio: aRatio, names:theNames );
		_factorsString = aFactorsString;
	}
	convenience init?( propertyList aPropertyList: [String:Any] ) {
		if let theValue = aPropertyList["ratio"] as? Double{
			var		theEveryName : [String] = [];
			if let theNames = aPropertyList["names"] as? [String] {
				theEveryName = theNames;
			}
			self.init( ratio: theValue, names: theEveryName );
		} else {
			return nil;
		}
	}
//	convenience init?( _ aString : String ) {
//		if let theValue = Double(aString) {
//			self.init( theValue );
//		}
//	}
	var	_factorsString : String? = nil;
	override var factorsString : String {
		return _factorsString != nil ? _factorsString! : "\(ratio)";
	}
	override var ratioString : String { return ratio.toString(decimalPlaces:5); }

	static func < (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio < b.ratio; }
	static func <= (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio < b.ratio || equivelentRatios(a.ratio,b.ratio); }
	static func > (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio > b.ratio; }
	static func >= (a: IrrationalInterval, b: IrrationalInterval) -> Bool { return a.ratio > b.ratio || equivelentRatios(a.ratio,b.ratio); }
}
