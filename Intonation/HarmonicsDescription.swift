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
		var		theAmplitudes = [Float32]();
		var		theLastNoneZeroHarmonic = 0;
		for i in 0..<maximumHarmonic {
			var		theValue : Float32 = 0.0;
			if i == 0 {
				theValue = 1.0;
			}
			else if anAmount > 0.0 && (i%2 == 0 || anEvenAmount > 0.0) {
				var		theMod = (2.0*(1.0-anAmount)+1.0);
				if i%2 == 1 {
					theMod *= (2.0*(1.0-anEvenAmount)+1.0);
				}
				let		theHarmonic = i+1;
				theValue = Float32(1.0/(pow(Double(theHarmonic),theMod)));
			}
			if theValue > threshold {
				theLastNoneZeroHarmonic = i;
			}
			theAmplitudes.append(theValue);
		}
		/*
		 remove trailing zero harmonics
		 */
		theAmplitudes.removeLast(theAmplitudes.count-theLastNoneZeroHarmonic-1);
		amplitudes = theAmplitudes
		amount = anAmount;
		evenAmount = anEvenAmount;
	}
	let		amount : Double;
	let		evenAmount : Double;
	let		amplitudes : [Float32];
	var		count: Int { return amplitudes.count; };

	func enumerateHarmonics( _ aBlock: (Int,Float32) -> Void ) {
		for (anIndex,anAmplitudes) in amplitudes.enumerated() {
			aBlock(anIndex+1,anAmplitudes);
		}
	}
}

