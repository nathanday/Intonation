/*
	Float+Additions.swift
	Intonation

	Created by Nathan Day on 27/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

func square<T : BinaryFloatingPoint>( _ aValue : T ) -> T {
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

func distance( from p: CGPoint, to l: (p1:CGPoint,p2:CGPoint)) -> CGFloat {
	return abs((l.p2.y-l.p1.y)*p.x - (l.p2.x-l.p1.x)*p.y + l.p2.x*l.p1.y - l.p2.y*l.p1.x)/sqrt(square(l.p2.y-l.p1.y) + square(l.p2.x-l.p1.x));
}

func linearInterpolation<T : BinaryFloatingPoint>( x: T, x0: T, x1: T, y0: T, y1: T ) -> T {
	return y0*(x-x1)/(x0-x1)+y1*(x-x0)/(x1-x0)
}
