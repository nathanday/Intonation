/*
	TonePlayer.swift
	Intonation

	Created by Nathan Day on 30/05/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation
import AudioToolbox

func dBToPower( _ aDB: Double ) -> Double { return pow(10.0,aDB/10.0); }
func powerToDB( _ aPower: Double ) -> Double { return 10.0*log10(aPower); }

class TonePlayer {

	init() {
		harmonics = HarmonicsDescription();
		baseFrequency = 220.0;
		intervals = [];
		playing = false;
	}

	deinit {
		stop();
	}

	static let sampleRate : Float64 = 44100.0;
	static let nyquestFrequency : Float64 = sampleRate/2.0;

	var harmonics : HarmonicsDescription { didSet { updateTones(); } }
	var baseFrequency : Double { didSet { updateTones(); } }
	var intervals : [Interval] { didSet { generateTones(); } }
	var arpeggioInterval : TimeInterval = 60.0/120.0;
	private(set) var playbackType : PlaybackType = .unison;

	var amplitude : Double = 1.0;
	var playing : Bool = false;
	var playingTones : [Interval:Tone] = [:];
	private var outputPower : Double { get { return dBToPower(amplitude); } }

	private var arpeggioTriggerTimer : Timer? = nil;
	private var nextNoteIndex : Int = 0;

	func generateTones() {
		var		theUnsedRatios = Set<Interval>(playingTones.keys);
		for theInterval in intervals {
			theUnsedRatios.remove(theInterval);
			if let theTone = playingTones[theInterval] {
				theTone.baseFrequency = baseFrequency/(2.0*TonePlayer.nyquestFrequency);
				theTone.harmonics = harmonics;
				if playing && !theTone.playing { theTone.play(); }
			} else {
				let theTone = Tone(baseFrequency:baseFrequency/(2.0*TonePlayer.nyquestFrequency), interval: theInterval, harmonics:harmonics );
				playingTones[theInterval] = theTone;
				if playing && !theTone.playing { theTone.play(); }
			}
		}
		for theRatio in theUnsedRatios {
			playingTones[theRatio]?.stop();
			playingTones[theRatio] = nil;
		}
	}
	
	func updateTones() {
		for theInterval in intervals {
			if let theTone = playingTones[theInterval] {
				theTone.baseFrequency = baseFrequency/(2.0*TonePlayer.nyquestFrequency);
				theTone.harmonics = harmonics;
			}
		}
	}
	
	func stop() {
		if playing {
			for (_,theTone) in playingTones {
				theTone.stop();
			}
			playingTones.removeAll();
			playing = false;
		}
	}

	@objc private dynamic func triggerNextNote() {
		if intervals.count > 0 {
			let		theCount = playingTones.count,
					theLastIndex = theCount-1;
			if arpeggioTriggerTimer == nil {
				arpeggioTriggerTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(TonePlayer.triggerNextNote), userInfo: nil, repeats: true);
			}
			switch playbackType {
			case .up:
				nextNoteIndex = (nextNoteIndex+1)%theCount;
				break;
			case .down:
				nextNoteIndex = ((nextNoteIndex-1)%(theCount-theLastIndex)) + theLastIndex;
				break;
			case .upDown:
				nextNoteIndex = (nextNoteIndex+1)%(theCount+theLastIndex);
				break;
			default:
				break;
			}
			assert( nextNoteIndex < 2*theLastIndex+1 );
			playingTones[intervals[theLastIndex-abs(nextNoteIndex-theLastIndex)]]?.play();
		}
	}

	func resume() {
		if !playing {
			generateTones();
			switch playbackType {
			case .unison:
				for (_,theTone) in playingTones { theTone.play(); }
				break;
			default:
				break;
			}
			playing = true;
		}
	}

	func playType( _ aType : PlaybackType ) {
		if playbackType != aType {
			stop();
		}

		if arpeggioTriggerTimer != nil {
			arpeggioTriggerTimer?.invalidate();
			arpeggioTriggerTimer = nil;
		}

		playbackType = aType;
		resume();
	}
}
