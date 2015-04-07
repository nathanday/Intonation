//
//  SoundGenerator.swift
//  Equal Temperament
//
//  Created by Nathan Day on 7/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

enum MusicSequenceType {
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

class RatioNote : AKNote {
	let		ratio: Rational;
	let		frequency: Double;
	init( ratio aRatio: Rational, frequency aFrequency: Double ) {
		ratio = aRatio;
		frequency = aFrequency;
		super.init();
	}
}

class SoundGenerator
{
	var		baseFrequencies : Double = 220.0 {
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
	
	var oscillator = RatiosPlayler( harmonicsDescription: HarmonicsDescription( amount:0.25, evenAmount:1.0 ), frequency:220.0 );
	
	func generateOSC() {
		oscillator = RatiosPlayler( harmonicsDescription:harmonicsDescription, frequency:baseFrequencies );
    }
	
	func play(ratios aRatios: [Rational], chord aChord: Bool)
    {
		AKOrchestra.start();
		var		thePhrase = AKPhrase();
		for theRatio in aRatios {
			if aChord {
				thePhrase.addNote(RatioNote(ratio: theRatio, frequency: baseFrequencies), atTime: 0.0);
			}
			else {
				if sequenceType == .up || sequenceType == .both {
					thePhrase.addNote(RatioNote(ratio: theRatio, frequency: baseFrequencies), atTime: Float(noteDuration) * Float(thePhrase.count) );
				}
				if sequenceType == .down || sequenceType == .both {
					thePhrase.addNote(RatioNote(ratio: theRatio, frequency: baseFrequencies), atTime: Float(noteDuration * Double(2*aRatios.count - Int(thePhrase.count))) );
				}
			}
		}
		oscillator.playPhrase(thePhrase);
    }
}


class RatiosPlayler: AKInstrument
{
	var frequency = 220.0;

	init( harmonicsDescription aHarmonicsDescription : HarmonicsDescription, frequency aFrequency : Double ) {
        super.init()
		frequency = aFrequency;
        let theOscillator = AKOscillator()
		theOscillator.frequency = AKInstrumentProperty(value: Float(aFrequency),  minimum: Float(aFrequency), maximum: Float(2.0*aFrequency));
		theOscillator.amplitude = AKInstrumentProperty(value: 0,  minimum: 0, maximum: 1.0);
		theOscillator.waveform.populateTableWithFractionalWidthFunction { (p:Float) -> Float in
			var		theResult = 0.0;
			var		theAmp = 1.0;
			for var i = 0; i < 64 && theAmp > 0.0000000001; i++ {
				let		theValue = sin(Double(i)*Double(p)*2.0*M_PI);
				theAmp = 1.0/pow(Double(i),100.0*aHarmonicsDescription.amount);
				theAmp *= i%2 == 1 ? aHarmonicsDescription.evenAmount : 1.0;
				theResult += theValue*theAmp;
			}
			return Float(theResult);
		}
		
		setAudioOutput(theOscillator);
    }

	func play(ratios aRatios : Rational ) {
	}
}

