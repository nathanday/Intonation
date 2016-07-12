/*
	Float+Additions.swift
	Intonation

	Created by Nathan Day on 27/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

func square( _ aValue : CGFloat ) -> CGFloat {
	return aValue * aValue;
}

extension Double {
	var ratioFromCents : Double {
		return Double(pow(2.0,self/1200.0));
	}
	var toCents : Double {
		return 1200.0 * log2(self);
	}

	var ratioFromSemitone : Double {
		return Double(pow(2.0,self/12.0));
	}
	var toSemitone : Double {
		return 12.0 * log2(self);
	}

	var ratioFromOctave : Double {
		return Double(pow(2.0,self));
	}
	var toOctave : Double {
		return log2(self);
	}

	func toString(decimalPlaces aDecimalPlaces:UInt) -> String {
		return NSString(format: "%.*f", aDecimalPlaces, self) as String;
	}
}
