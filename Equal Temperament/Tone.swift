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
	var				baseFrequency: Double;
	var				envelope = Envelope(attack: 0.1, release: 0.1);
	let				interval: Interval;
	private var		thetaDelta: Double {
		get {
			return equalTemperament
					? baseFrequency*interval.equalTemperament
					: baseFrequency*interval.ratio.toDouble;
		}
	}
	var				harmonics: HarmonicsDescription;
	var				complete : Bool = false;
	var				equalTemperament : Bool = false;

	init( baseFrequency aBaseFrequency: Double, interval anInterval: Interval, harmonics aHarmonics: HarmonicsDescription ) {
		baseFrequency = aBaseFrequency;
		interval = anInterval;
		harmonics = aHarmonics;
		assert(thetaDelta < 1.0);
	}

	final func generate( gain aGain: Float32 ) -> Float32 {
		var		theEnvelope : Float32 = 0.0;
		var		theResult : Float32 = 0.0;
		(complete,theEnvelope) = envelope[Float32(theta)];
		if !complete {
			var		theTotal : Float32 = 0.0;
			for i in 1...min(harmonics.maximumHarmonic,Int(0.5/thetaDelta)) {
				if i%2 == 1 && harmonics.amplitudes[i] < pow(2.0,-7.0) { break; }
				theTotal += harmonics.amplitudes[i]*Float32(sin(2.0*theta*Double(i)*M_PI));
			}
			theResult = Float32(theTotal)*aGain*theEnvelope;
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
		get { return interval.ratio.hashValue; }
	}
}

func ==(aLhs: Tone, aRhs: Tone) -> Bool {
	return aLhs.interval.ratio == aRhs.interval.ratio;
}

