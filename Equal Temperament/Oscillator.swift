/*
	Oscillator.swift
	Equal Temperament

	Created by Nathan Day on 12/06/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import AudioToolbox;

enum PlaybackType : Int {
	case Unison = 0;
	case Up;
	case Down;
	case UpDown;
}

class Oscillator
{
	var				theta : Double = 0;
//	var		values : [Float32];
	var				baseFrequency: Double;
	let				ratio: Rational;
	private var		frequency: Double { get { return baseFrequency*ratio.toDouble; } }
	let				harmonics: HarmonicsDescription;

	init( baseFrequency aBaseFrequency: Double, ratio aRatio: Rational, harmonics aHarmonics: HarmonicsDescription ) {
		baseFrequency = aBaseFrequency;
		ratio = aRatio;
		harmonics = aHarmonics;
		assert(frequency < 1.0);
	}

	func generate( length aLength: UInt32, previous aPrevious: UnsafeMutableBufferPointer<Float32>, gain aGain: Float32 ) -> Float32 {
		var		theMax = Float32(1.0);

		for i : Int in 0..<Int(aLength) {
			theta += frequency;
			if theta > 1.0 {
				theta -= 1.0;
			}
			aPrevious[i] += Float32(sin(theta*M_PI))*aGain;
			
			if abs(aPrevious[i]) > theMax {
				theMax = abs(aPrevious[i]);
			}
		}
		return theMax;
	}
}
