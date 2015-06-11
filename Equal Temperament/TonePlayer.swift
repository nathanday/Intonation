//
//  TonePlayer.swift
//  Equal Temperament
//
//  Created by Nathan Day on 30/05/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Foundation

func dBToPower( aDB: Double ) -> Double { return pow(10.0,aDB/10.0); }
func powerToDB( aPower: Double ) -> Double { return 10.0*log10(aPower); }

class TonePlayer {

	init() {
		harmonics = HarmonicsDescription(amount: 0.5, evenAmount: 1.0);
		baseFrequency = 220.0;
		ratios = [3,4,5];
	}

	let sampleRate : Float64 = 44100.0;
	
	var harmonics : HarmonicsDescription { didSet { generateOscillators(); } }
	var amplitude : Double = 1.0;
	
	var playing : Bool = false;
	
	var oscillatorSet : OscillatorSet {
		get {
			return OscillatorSet();
		}
	}
	
	lazy var toneUnit : AudioComponentInstance? = nil
//		{
//		var		theResult : AudioComponentInstance;
//		var		theDefaultOutputDescription = AudioComponentDescription( componentType: OSType(kAudioUnitType_Output),
//																componentSubType: OSType(kAudioUnitSubType_DefaultOutput),
//																componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
//																componentFlags: 0,
//																componentFlagsMask: 0);
//		
//		// Create a new unit based on this that we'll use for output
//		var err = AudioComponentInstanceNew( AudioComponentFindNext(nil, &theDefaultOutputDescription), &theResult);
//		
//		// Set our tone rendering function on the unit
//		var		theOscillatorSet = self.oscillatorSet;
//		var		theInput = AURenderCallbackStruct( inputProc: oscillatorCallback, inputProcRefCon: &theOscillatorSet );
//		err = AudioUnitSetProperty(theResult, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &theInput, UInt32(sizeof(AURenderCallbackStruct)));
//		
//		// Set the format to 32 bit, single channel, floating point, linear PCM
//		let		four_bytes_per_float : Int = 4;
//		let		eight_bits_per_byte : Int = 8;
//		let		theStreamFormat = AudioStreamBasicDescription( self.sampleRate, kAudioFormatLinearPCM, kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved, four_bytes_per_float, 1, four_bytes_per_float, 1, four_bytes_per_float * eight_bits_per_byte, 0)
//		err = AudioUnitSetProperty (theResult, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &theStreamFormat, sizeof(AudioStreamBasicDescription));
//		assert(err == noErr, "Error setting stream format: %hd", err);
//		err = AudioUnitInitialize(theResult);
//		assert(err == noErr, "Error starting unit: %hd", err);
//		self.playing = false;
//		return theResult;
//	}()

	private var outputPower : Double { get { return dBToPower(amplitude); } }
	
	var allRatioPrimes : Set<UInt> {
		var		theResult = Set<UInt>();
		for theRatio in ratios {
			var		theValue = theRatio;
			repeat {
				let			thePrime = theValue.largestPrimeFactor;
				theResult.insert(thePrime);
				theValue /= thePrime;
			}
			while( theValue > 1 );
		}
		return theResult;
	}
	
	var combinedRatioFrequency : UInt {
		var		theResult : UInt = 1;
		for theValue in allRatioPrimes {
			theResult *= theValue;
		}
		return theResult;
	}
	
	var baseSampleLength : UInt {
		let		theCombinedRatioFrequency = Double(self.combinedRatioFrequency);
		let		theValue = UInt(sampleRate/baseFrequency/theCombinedRatioFrequency + 0.5);
		return theValue * UInt(theCombinedRatioFrequency);
	}
	
	var baseFrequency : Double { didSet { generateOscillators(); } }
	var ratios : [UInt] { didSet { generateOscillators(); } }
	
	// 4:5:6
	
	func generateOscillators() {
		let		theBaseFreq = self.baseFrequency;
		var		theBaseRatio = 0.0;
		for theRatio in self.ratios {
			let		theValue = Double(theRatio);
			var		theFreq = theBaseFreq;
			if theBaseRatio == 0.0  {
				theBaseRatio = Double(theValue);
			}
			else {
				theFreq = theFreq * theBaseRatio / theValue;
			}
			generateOscillatorValue( [Float32(1.0)], length:UInt(sampleRate/theFreq) );
		}
	}
	
	func generateOscillatorValue( aValue : Array<Float>, length aLength: UInt )  {
		for h in 1..<64 {
			let		theAmp = 1.0/pow((Float(h)-1.0)*10.0,Float(-harmonics.amount/10.0)+1.0);
			if theAmp < pow(10.0,Float(-48.0/10.0)) {
				break;
			}
			for _ in 0..<aLength {
//				aValue[Int(n)] = sin(2.0*Float(M_PI)*Float(n*h)/Float(aLength))*theAmp;
			}
		}
	}
	
	func stop() {
		if playing  {
//			AudioOutputUnitStop(self.toneUnit );
//			playing = YES;
		}
	}
	
	func playType( aType : PlaybackType ) {
		if !self.playing {
//			OSErr		err = AudioOutputUnitStart(self.toneUnit);
//			assert1(err == noErr, "Error starting unit: %hd", err);
			self.playing = true;
		}
	}

}