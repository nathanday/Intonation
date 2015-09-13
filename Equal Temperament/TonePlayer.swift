/*
	TonePlayer.swift
	Equal Temperament

	Created by Nathan Day on 30/05/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation
import AudioToolbox

func dBToPower( aDB: Double ) -> Double { return pow(10.0,aDB/10.0); }
func powerToDB( aPower: Double ) -> Double { return 10.0*log10(aPower); }

var currentTonePlayer : TonePlayer? = nil;

class TonePlayer {

	init() {
		harmonics = HarmonicsDescription(amount: 0.5, evenAmount: 1.0);
		baseFrequency = 110.0;
		intervals = [];
		playing = false;
		assert( currentTonePlayer == nil, "canot create multiple TonePlayers" );
		currentTonePlayer = self;
	}

	static let sampleRate : Float64 = 44100.0;
	static let nyquestFrequency : Float64 = sampleRate/2.0;

	var harmonics : HarmonicsDescription { didSet { updateTones(); } }
	var baseFrequency : Double { didSet { updateTones(); } }
	var intervals : [Interval] { didSet { generateTones(); } }
	var equalTemperament : Bool = false {
		didSet {
			for (_,theTone) in playingTones { theTone.equalTemperament = equalTemperament; }
		}
	}

	var amplitude : Double = 1.0;
	var playing : Bool = false;
	var playingTones : [Rational:Tone] = [:];
	private var outputPower : Double { get { return dBToPower(amplitude); } }

	func generateTones() {
		var		theUnsedRatios = Set<Rational>(playingTones.keys);
		for theInterval in self.intervals {
			theUnsedRatios.remove(theInterval.ratio);
			if let theTone = playingTones[theInterval.ratio] {
				theTone.baseFrequency = baseFrequency/TonePlayer.nyquestFrequency;
				theTone.harmonics = harmonics;
				if playing && !theTone.playing { theTone.play(); }
			} else {
				let theTone = Tone(baseFrequency:baseFrequency/TonePlayer.nyquestFrequency, interval: theInterval, harmonics:harmonics);
				playingTones[theInterval.ratio] = theTone;
				if playing && !theTone.playing { theTone.play(); }
			}
		}
		for theRatio in theUnsedRatios {
			playingTones[theRatio]?.stop();
			playingTones[theRatio] = nil;
		}
	}
	
	func updateTones() {
		for theInterval in self.intervals {
			if let theTone = playingTones[theInterval.ratio] {
				theTone.baseFrequency = baseFrequency/TonePlayer.nyquestFrequency;
				theTone.harmonics = harmonics;
			}
		}
	}
	
	func stop() {
		if playing {
			for (_,theTone) in self.playingTones {
				theTone.stop();
			}
			playingTones.removeAll();
			playing = false;
		}
	}
	
	func playType( aType : PlaybackType ) {
		if !playing {
			generateTones();
			for (_,theTone) in self.playingTones {
				theTone.play();
			}
			playing = true;
		}
	}
}