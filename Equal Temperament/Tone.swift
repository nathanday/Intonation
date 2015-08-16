/*
	Tone.swift
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

class Tone
{
	var				theta : Double = 0;
//	var				values : [Float32];
	var				baseFrequency: Double;
	var				envelope = Envelope(attack: 0.1, release: 0.1);
	let				ratio: Rational;
	private var		frequency: Double { get { return baseFrequency*ratio.toDouble; } }
	let				harmonics: HarmonicsDescription;

	init( baseFrequency aBaseFrequency: Double, ratio aRatio: Rational, harmonics aHarmonics: HarmonicsDescription ) {
		baseFrequency = aBaseFrequency;
		ratio = aRatio;
		harmonics = aHarmonics;
		assert(frequency < 1.0);
	}

	final func generate( gain aGain: Float32 ) -> Float32 {
		let		theResult = Float32(sin(theta*M_PI))*aGain*envelope[Float32(theta)];
		theta += frequency;
		return theResult;
	}
}
