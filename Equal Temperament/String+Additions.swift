//
//  String+Additions.swift
//  Equal Temperament
//
//  Created by Nathan Day on 2/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

extension String {
	func stringByReplacingOccurrencesOfStrings(aTargets: [String], withString aReplacement: String, options aMask: NSStringCompareOptions = NSStringCompareOptions(rawValue: 0), range aSearchRange: Range<Index>? = nil, locale aLocale: NSLocale? = nil) -> String {
		var		theResult = self;
		for theTarget in aTargets {
			theResult.replacingOccurrencesOfString( theTarget, withString: aReplacement, options: aMask, range: aSearchRange, locale: aLocale );
		}
		return theResult;
	}

	mutating func replacingOccurrencesOfStrings( aTarget: [String], withString aReplacement: String ) {
		for theTarget in aTarget {
			replacingOccurrencesOfString( theTarget, withString: aReplacement );
		}
	}

	mutating func replacingOccurrencesOfString( aTarget: String, withString aReplacement: String, options aMask: NSStringCompareOptions = NSStringCompareOptions(rawValue: 0), range aSearchRange: Range<Index>? = nil, locale aLocale: NSLocale? = nil ) {
		while let theRange = rangeOfString(aTarget, options: aMask, range: aSearchRange, locale: aLocale) {
			replaceRange(theRange, with: aReplacement);
		}
	}
}