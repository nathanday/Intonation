/*
	Float+Additions.swift
	Intonation

	Created by Nathan Day on 27/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

func square( aValue : CGFloat ) -> CGFloat {
	return aValue * aValue;
}

extension Double {
	static func ratioFor(cents aCents: Double ) -> Double {
		return Double(pow(2.0,aCents/1200.0));
	}
	var toCents : Double {
		return 1200.0 * log2(self);
	}
}