/*
	UInt+Additions.swift
	Equal Temperament

	Created by Nathan Day on 4/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

extension Int {
	var hexadecimalString : String { get { return String(format: "%x", self ); } }

	var superScriptString : String {
		get {
			var		theResult = "";
			if self > 0 {
				let		digits = "⁰¹²³⁴⁵⁶⁷⁸⁹";
				var		theValue = UInt(abs(self));
				while theValue > 0 {
					let		theIndex = digits.startIndex.advancedBy(Int(theValue%10));
					theResult = "\(digits[theIndex])\(theResult)";
					theValue /= 10;
				}
				if self < 0 {
					theResult = "⁻\(theResult)";
				}
			}
			else {
				theResult = "⁰";
			}
			return theResult;
		}
	}

	var factorsString : String {
		get {
			var		theResult = "";
			for theFact in UInt(self).everyPrimeFactor {
				if theResult.startIndex != theResult.endIndex {
					theResult.append(Character("∙"));
				}
				theResult.appendContentsOf("\(theFact.factor)");
				if theFact.power > 1 {
					theResult.appendContentsOf("\(theFact.power.superScriptString)");
				}
			}
			return theResult;
		}
	}
}
