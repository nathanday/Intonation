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
	private var		thetaDelta: Double { get { return baseFrequency*ratio.toDouble; } }
	let				harmonics: HarmonicsDescription;
	var				complete : Bool = false;

	init( baseFrequency aBaseFrequency: Double, ratio aRatio: Rational, harmonics aHarmonics: HarmonicsDescription ) {
		baseFrequency = aBaseFrequency;
		ratio = aRatio;
		harmonics = aHarmonics;
		assert(thetaDelta < 1.0);
	}

	final func generate( gain aGain: Float32 ) -> Float32 {
		var		theEnvelope : Float32 = 0.0;
		var		theResult : Float32 = 0.0;
		(complete,theEnvelope) = envelope[Float32(theta)];
		if !complete {
			theResult = Float32(sin(theta*M_PI))*aGain*theEnvelope;
			theta += thetaDelta;
		}
		return theResult;
	}

	func release() {
		envelope.hold = Float32(theta)-envelope.attack;
	}
}

extension Tone : Hashable {
	var hashValue: Int {
		get { return ratio.hashValue; }
	}
}

func ==(aLhs: Tone, aRhs: Tone) -> Bool {
	return aLhs.ratio == aRhs.ratio;
}

