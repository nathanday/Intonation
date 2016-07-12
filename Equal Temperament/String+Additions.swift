//
//  String+Additions.swift
//  Intonation
//
//  Created by Nathan Day on 2/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

extension String {
	func stringByReplacingOccurrencesOfStrings(_ aTargets: [String], withString aReplacement: String, options aMask: NSString.CompareOptions = NSString.CompareOptions(rawValue: 0), range aSearchRange: Range<Index>? = nil, locale aLocale: Locale? = nil) -> String {
		var		theResult = self;
		for theTarget in aTargets {
			theResult.replacingOccurrencesOfString( theTarget, withString: aReplacement, options: aMask, range: aSearchRange, locale: aLocale );
		}
		return theResult;
	}

	mutating func replacingOccurrencesOfStrings( _ aTarget: [String], withString aReplacement: String ) {
		for theTarget in aTarget {
			replacingOccurrencesOfString( theTarget, withString: aReplacement );
		}
	}

	mutating func replacingOccurrencesOfString( _ aTarget: String, withString aReplacement: String, options aMask: NSString.CompareOptions = NSString.CompareOptions(rawValue: 0), range aSearchRange: Range<Index>? = nil, locale aLocale: Locale? = nil ) {
		while let theRange = range(of: aTarget, options: aMask, range: aSearchRange, locale: aLocale) {
			replaceSubrange(theRange, with: aReplacement);
		}
	}
}
