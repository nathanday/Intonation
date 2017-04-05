/*
	HarmonicsDescription.swift
	Intonation

	Created by Nathan Day on 19/05/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct HarmonicsDescription {
	let		a = 2.0;
	let		maximumHarmonic = 31;
	init( ) {
		self.init( amount: 0.5, evenAmount: 1.0, spectrumStretch: 1.0 );
	}
	init( amount anAmount : Double, evenAmount anEvenAmount : Double, spectrumStretch aStretch : Double ) {
		amount = anAmount;
		evenAmount = anEvenAmount;
		spectrumStretch = aStretch;
		amplitudes.append(0.0);
		frequency.append(1.0);
		for i in 1...maximumHarmonic {
			var		theValue : Float32 = 0.0;
			if amount > 0.0 && (i%2 == 1 || evenAmount > 0.0) {
				var		theMod = (a*(1.0-amount)+1.0);
				if i%2 == 0 {
					theMod *= (a*(1.0-evenAmount)+1.0);
				}
				theValue = Float32(1.0/(pow(Double(i),theMod)));
			}
			else if i == 1 {
				theValue = 1.0;
			}
			amplitudes.append(theValue);
			frequency.append(2.0*Double.pi*pow(Double(i),spectrumStretch));
		}
	}
	var		amount : Double;
	var		evenAmount : Double;
	var		spectrumStretch : Double;
	var		amplitudes : [Float32] = [];
	var		frequency : [Double] = [];
}

