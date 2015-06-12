//
//  Oscillator.swift
//  Equal Temperament
//
//  Created by Nathan Day on 12/06/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import AudioToolbox;

enum PlaybackType : Int {
	case Unison = 0;
	case Up;
	case Down;
	case UpDown;
}

class Oscillator
{
	var				theta : UInt = 0;
	var				values : [Float32];

	init( samples aSamples: UInt, cycles aCycles: UInt, harmonics aHarmonics: HarmonicsDescription ) {
		let		theSamples = Double(aSamples);
		let		theNyquestCycles = aSamples>>1;
		var		theValues = [Float32]();
		for i in 0..<Int(aSamples) {
			var		theValue : Float32 = 0.0;
			let		theBase = 2.0*Double(i)*M_PI/theSamples;
			var		theH = 1.0;
			for c in aCycles...theNyquestCycles {
				theValue += Float32(sin(theBase*Double(c))/theH);
				theH += 1.0;
			}
			theValues.append(theValue);
		}
		values = theValues;
	}
}
