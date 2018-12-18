/*
	HarmonicsDescription.swift
	Intonation

	Created by Nathan Day on 19/05/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct HarmonicsDescription {
	let		a = 2.0;
	let		maximumHarmonic = 32;
	init( ) {
		self.init( amount: 0.5, evenAmount: 1.0 );
	}
	init( amount anAmount : Double, evenAmount anEvenAmount : Double ) {
		amount = anAmount;
		evenAmount = anEvenAmount;
		for i in 0..<maximumHarmonic {
			var		theValue : Float32 = 0.0;
			if i == 0 {
				theValue = 1.0;
			}
			else if amount > 0.0 && (i%2 == 0 || evenAmount > 0.0) {
				var		theMod = (a*(1.0-amount)+1.0);
				if i%2 == 1 {
					theMod *= (a*(1.0-evenAmount)+1.0);
				}
				let		theHarmonic = i+1;
				theValue = Float32(1.0/(pow(Double(theHarmonic),theMod)));
			}
			amplitudes.append(theValue);
		}
	}
	var		amount : Double;
	var		evenAmount : Double;
	var		amplitudes : [Float32] = [];

	func enumerateHarmonics( _ aBlock: (Int,Float32) -> Void ) {
		for (anIndex,anAmplitudes) in amplitudes.enumerated() {
			aBlock(anIndex+1,anAmplitudes);
		}
	}
}

