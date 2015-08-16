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
		ratios = [1,[5,4],[3,2]];
		toneUnit = TonePlayer.createAudioComponentInstance();
		playing = false;
		assert( currentTonePlayer == nil, "canot create multiple TonePlayers" );
		currentTonePlayer = self;
	}

	static let sampleRate : Float64 = 44100.0;
	static let nyquestFrequency : Float64 = sampleRate/2.0;

	var harmonics : HarmonicsDescription { didSet { generateOscillators(); } }
	var baseFrequency : Double { didSet { generateOscillators(); } }
	var ratios : [Rational] { didSet { generateOscillators(); } }
	
	var amplitude : Double = 1.0;
	
	var playing : Bool = false;
	
	var everyOscillator : [Oscillator] = [];

	func outputAudio( aSamples: UnsafeMutableBufferPointer<Float32>, numberFrames anInNumberFrames: UInt32 ) -> OSStatus {
		let		theResult : OSStatus = kAudioServicesNoError;
		var		theMax : Float32 = 1.0;
		let		theGain = Float32(1.0)/Float32(everyOscillator.count);
		assert( theGain > 0.0, "bad gain value: \(theGain)" );
		assert( !everyOscillator.isEmpty, "no oscillator" );
		if !aSamples.isEmpty {
			for theOscilator in everyOscillator {
				theMax = theOscilator.generate( length: anInNumberFrames, previous: aSamples, gain: theGain );
			}
			for i in aSamples.startIndex..<aSamples.endIndex {
				aSamples[i] /= theMax;
			}
			print( "max = \(theMax)", appendNewline:true );
		}
		return theResult;
	}

	static func createAudioComponentInstance() -> AudioComponentInstance {
		var		theResult : AudioComponentInstance = nil;
		var		theDefaultOutputDescription = AudioComponentDescription( componentType: OSType(kAudioUnitType_Output),
																	  componentSubType: OSType(kAudioUnitSubType_DefaultOutput),
																 componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
																		componentFlags: 0,
																	componentFlagsMask: 0);
		func oscillatorCallback( anInRefCon : UnsafeMutablePointer<Void>, anIOActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, anInTimeStamp : UnsafePointer<AudioTimeStamp>, anInBusNumber: UInt32, anInNumberFrames: UInt32, anIOData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
			var		theResult : OSStatus = kAudioServicesNoError;
			let		theBuffer : AudioBuffer = anIOData.memory.mBuffers;
			let		theSamples = UnsafeMutableBufferPointer<Float32>(theBuffer)
			if let theTonePlayer = currentTonePlayer {
				theResult = theTonePlayer.outputAudio(theSamples, numberFrames: anInNumberFrames );
			}
			return theResult;
		}

		// Create a new unit based on this that we'll use for output
		var		err = AudioComponentInstanceNew( AudioComponentFindNext(nil, &theDefaultOutputDescription), &theResult);
		
		// Set our tone rendering function on the unit
//		var		theTonePlayer = self;
		var		theInput = AURenderCallbackStruct( inputProc: oscillatorCallback, inputProcRefCon: nil );
		err = AudioUnitSetProperty(theResult, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &theInput, UInt32(sizeof(AURenderCallbackStruct)));
		
		// Set the format to 32 bit, single channel, floating point, linear PCM
		let		four_bytes_per_float : UInt32 = 4;
		let		eight_bits_per_byte : UInt32 = 8;
		var		theStreamFormat = AudioStreamBasicDescription( mSampleRate: TonePlayer.sampleRate,
																 mFormatID: kAudioFormatLinearPCM,
															  mFormatFlags: kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
														   mBytesPerPacket: four_bytes_per_float,
														  mFramesPerPacket: 1,
															mBytesPerFrame: four_bytes_per_float,
														 mChannelsPerFrame: 1,
														   mBitsPerChannel: four_bytes_per_float * eight_bits_per_byte,
																 mReserved: 0);
		
		err = AudioUnitSetProperty (theResult, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, AudioUnitElement(0), &theStreamFormat, UInt32(sizeof(AudioStreamBasicDescription)) );

		assert(err == noErr, "Error setting stream format: \(err)" );
		err = AudioUnitInitialize(theResult);
		assert(err == noErr, "Error starting unit: \(err)" );
		return theResult;
	}

	var toneUnit : AudioComponentInstance;

	func generateAudio( anInTimeStamp : UnsafePointer<AudioTimeStamp>, anInBusNumber: UInt32, anInNumberFrames: UInt32, anIOData: UnsafeMutablePointer<AudioBufferList>) -> Bool {
		return true;
	}

	private var outputPower : Double { get { return dBToPower(amplitude); } }

	private var baseSampleLength : UInt { return UInt(sum(ratios).denominator); }

	// 4:5:6
	
	func generateOscillators() {
		everyOscillator.removeAll();
		for theRatio in self.ratios {
			everyOscillator.append(Oscillator(baseFrequency:baseFrequency/TonePlayer.nyquestFrequency, ratio: theRatio, harmonics:harmonics));
		}
	}
	
	func stop() {
		if playing  {
			let		theError = AudioOutputUnitStop(self.toneUnit );
			assert( theError == noErr, "Error starting unit: 0x\(UInt(theError).hexadecimalString)");
			playing = false;
		}
	}
	
	func playType( aType : PlaybackType ) {
		if !playing {
			let		theError = AudioOutputUnitStart(self.toneUnit);
			assert( theError == noErr, "Error starting unit: 0x\(UInt(theError).hexadecimalString)");
			playing = theError == noErr;
		}
	}

}