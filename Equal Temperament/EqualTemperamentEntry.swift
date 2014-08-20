/*
    EqualTemperamentEntry.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright (c) 2014 Nathan Day. All rights reserved.
 */

import Foundation

func centsEquivelentForRatio( r : Double, n : UInt ) -> Double { return Double(n)*100.0 * log2(r); }
func rationsForCentsEquivelent( c : Double, n : UInt ) -> Double { return pow(2.0,c/(100.0*Double(n))); }

class EqualTemperamentEntry : NSObject
{
	var justIntonationRatio : Rational
    dynamic var justIntonationRatioToString : String { return justIntonationRatio.toString; }
    dynamic var justIntonationRatioToDouble : Double { return justIntonationRatio.toDouble; }
	let numberOfIntervals : UInt
	var name : String { return "\(justIntonationRatio.numerator):\(justIntonationRatio.denominator)"; }
	var closestEqualTemperamentIntervalNumber : UInt { return UInt(12.0*Double(log2(justIntonationRatio.toDouble))+0.5); }
	var closestIntervalNumber : UInt { return UInt(Double(self.numberOfIntervals)*Double(log2(justIntonationRatio.toDouble))+0.5); }
	var equalTemperamentRatio : Double { return pow(2.0,Double(self.closestEqualTemperamentIntervalNumber)/Double(self.numberOfIntervals)); }
	var justIntonationCents : Double { return centsEquivelentForRatio( self.justIntonationRatio.toDouble, 12 ); }
	var justIntonationPercent : Double { return centsEquivelentForRatio( self.justIntonationRatio.toDouble, self.numberOfIntervals ); }
	var error : Double { return equalTemperamentRatio-justIntonationRatio.toDouble; }
	var errorCent : Double {
		return centsEquivelentForRatio( rationsForCentsEquivelent(100.0*Double(closestIntervalNumber), numberOfIntervals), 12)-centsEquivelentForRatio( self.justIntonationRatio.toDouble, 12 );
	}
	var errorPercent : Double {
		return Double(closestIntervalNumber)*100.0-centsEquivelentForRatio( justIntonationRatio.toDouble, numberOfIntervals );
	}

	var absError : Double { return abs(error); }
	var absErrorCent : Double { return abs(errorCent); }
	var absErrorPercent : Double { return abs(errorPercent); }

	init( justIntonationRatio: Rational, numberOfIntervals : UInt )
	{
		self.justIntonationRatio = justIntonationRatio
		self.numberOfIntervals = numberOfIntervals
	}
}
