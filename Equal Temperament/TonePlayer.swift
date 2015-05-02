//
//  TonePlayer.swift
//  Equal Temperament
//
//  Created by Nathan Day on 7/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

enum MusicSequenceType {
	case unison
	case up
	case down
	case both
}

struct HarmonicsDescription {
	let		amount : Double;
	let		evenAmount : Double;

	init( amount anAmount : Double, evenAmount anEvenAmount : Double ) {
		amount = anAmount;
		evenAmount = anEvenAmount;
	}
}

class TonePlayer
{
	var		baseFrequency : Double = 220.0 {
		didSet {
			generateOSC();
		}
	}
	var		harmonicsDescription = HarmonicsDescription( amount:0.25, evenAmount: 1.0 ) {
		didSet {
			generateOSC();
		}
	}
	var		noteDuration : Double = 0.6;
	var		sequenceType = MusicSequenceType.both;

//	var oscillator = RatiosPlayler( harmonicsDescription: HarmonicsDescription( amount:0.25, evenAmount:1.0 ), frequency:220.0 );

	func generateOSC() {
//		oscillator = RatiosPlayler( harmonicsDescription:harmonicsDescription, frequency:baseFrequency );
    }
	func play(ratios aRatios: [Rational], chord aChord: Bool) { play(ratios: aRatios, chord: aChord); }

	func play(ratios aRatios: [Double], chord aChord: Bool)
    {
    }
}



