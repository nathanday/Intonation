//
//  MIDIToHarmonicRatio.swift
//  Intonation
//
//  Created by Nathan Day on 8/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class MIDIToHarmonicRatio {
	var		playingRatioForNote : [Int:IntervalEntry] = [Int:IntervalEntry]();
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

	func frequencyForMIDINote( _ aMidiNote : UInt ) -> Double {
		return pow(2,Double(aMidiNote)/12)*440/pow(2,Double(69)/12)
	}

	func updateAutoAnchorMIDINote() {
		anchorMIDINote = UInt(round(12.0*log2(pow(baseFrequency,69.0/12)/440.0)));
	}

	func pushRatioFor( midiNote aMIDINote: UInt8, everyInterval aEveryInterval : [IntervalEntry] ) -> IntervalEntry {
		var		theIndex = (Int(aMIDINote)-Int(anchorMIDINote));
		while theIndex < 0 {
			theIndex += aEveryInterval.count;
		}
		let	theResult = aEveryInterval[theIndex%aEveryInterval.count];
		playingRatioForNote[Int(aMIDINote)] = theResult;
		return theResult;
	}

	func peekRatioFor( midiNote aMIDINote: UInt8 ) -> IntervalEntry? {
		return playingRatioForNote[Int(aMIDINote)];
	}

	func popRatioFor( midiNote aMIDINote: UInt8 ) -> IntervalEntry? {
		let		theResult = playingRatioForNote[Int(aMIDINote)];
		if theResult != nil {
			playingRatioForNote[Int(aMIDINote)] = nil;
		}
		return theResult;
	}
}
