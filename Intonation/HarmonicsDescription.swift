/*
	HarmonicsDescription.swift
	Intonation

	Created by Nathan Day on 19/05/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct HarmonicsDescription {
	private let		maximumHarmonic = 64;
	private let		threshold = powf(2.0,-12.0);
	init( ) {
		self.init( amount: 0.5, evenAmount: 1.0 );
	}
	init( amount anAmount : Double, evenAmount anEvenAmount : Double ) {
		amount = anAmount;
		evenAmount = anEvenAmount;
		var		theLastNoneZeroHarmonic = 0;
		for i in 0..<maximumHarmonic {
			var		theValue : Float32 = 0.0;
			if i == 0 {
				theValue = 1.0;
			}
			else if amount > 0.0 && (i%2 == 0 || evenAmount > 0.0) {
				var		theMod = (2.0*(1.0-amount)+1.0);
				if i%2 == 1 {
					theMod *= (2.0*(1.0-evenAmount)+1.0);
				}
				let		theHarmonic = i+1;
				theValue = Float32(1.0/(pow(Double(theHarmonic),theMod)));
			}
			if theValue > threshold {
				theLastNoneZeroHarmonic = i;
			}
			amplitudes.append(theValue);
		}
		/*
		 remove trailing zero harmonics
		 */
		amplitudes.removeLast(amplitudes.count-theLastNoneZeroHarmonic-1);
	}
	var		amount : Double;
	var		evenAmount : Double;
	var		amplitudes : [Float32] = [];
	var		count: Int { return amplitudes.count; };

	func enumerateHarmonics( _ aBlock: (Int,Float32) -> Void ) {
		for (anIndex,anAmplitudes) in amplitudes.enumerated() {
			aBlock(anIndex+1,anAmplitudes);
		}
	}
}

