//
//  MIDIToHarmonicRatio.swift
//  Equal Temperament
//
//  Created by Nathan Day on 8/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class MIDIToHarmonicRatio {
	var		playingRatioForNote : [Int:EqualTemperamentEntry] = [Int:EqualTemperamentEntry]();
	var		anchorMIDINote : UInt = 60;
	var		baseFrequency : Double = 0.0 {
		didSet {
			if autoAnchorMIDINote {
				updateAutoAnchorMIDINote();
			}
		}
	}
	var		autoAnchorMIDINote : Bool = false {
		didSet {
			if autoAnchorMIDINote {
				updateAutoAnchorMIDINote();
			}
		}
	}

	func frequencyForMIDINote( aMidiNote : UInt ) -> Double {
		return pow(2,Double(aMidiNote)/12)*440/pow(2,Double(69)/12)
	}

	func updateAutoAnchorMIDINote() {
		anchorMIDINote = UInt(round(12.0*log2(pow(baseFrequency,69.0/12)/440.0)));
	}

	func pushRatioFor( midiNote aMIDINote: UInt, everyInterval aEveryInterval : [EqualTemperamentEntry] ) -> EqualTemperamentEntry {
		var		theIndex = (Int(aMIDINote)-Int(anchorMIDINote));
		if theIndex < 0 {
			theIndex += aEveryInterval.count;
		}
		let	theResult = aEveryInterval[theIndex%aEveryInterval.count];
		playingRatioForNote[Int(aMIDINote)] = theResult;
		return theResult;
	}

	func peekRatioFor( midiNote aMIDINote: UInt ) -> EqualTemperamentEntry? {
		return playingRatioForNote[Int(aMIDINote)];
	}

	func popRatioFor( midiNote aMIDINote: UInt ) -> EqualTemperamentEntry? {
		let		theResult = playingRatioForNote[Int(aMIDINote)];
		if theResult != nil {
			playingRatioForNote[Int(aMIDINote)] = nil;
		}
		return theResult;
	}
}
