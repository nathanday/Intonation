/*
	Tone.swift
	Intonation

	Created by Nathan Day on 12/06/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import AudioToolbox;

enum PlaybackType : Int {
	case unison = 0;
	case up;
	case down;
	case upDown;
}

class Tone {
	var				toneUnit : AudioComponentInstance?;
	var				theta : Double = 0;
	var				baseFrequency: Double;
	var				envelope = Envelope(attack: 0.1, release: 0.1);
	let				interval: Interval;
	var				playing = false;
	private var		thetaDelta: Double {
		get {
			return baseFrequency*interval.toDouble;
		}
	}
	var				harmonics: HarmonicsDescription;
	var				complete : Bool = false;

	func createAudioComponentInstance() -> AudioComponentInstance {
		var		theResult : AudioComponentInstance? = nil;
		var		theDefaultOutputDescription = AudioComponentDescription( componentType: OSType(kAudioUnitType_Output),
			componentSubType: OSType(kAudioUnitSubType_DefaultOutput),
			componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
			componentFlags: 0,
			componentFlagsMask: 0);

		func toneCallback( _ anInRefCon : UnsafeMutableRawPointer, anIOActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, anInTimeStamp : UnsafePointer<AudioTimeStamp>, anInBusNumber: UInt32, anInNumberFrames: UInt32, anIOData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
			let		theResult : OSStatus = kAudioServicesNoError;
			if let theBuffer : AudioBuffer = anIOData?.pointee.mBuffers {
				let		theSamples = UnsafeMutableBufferPointer<Float32>(theBuffer);
				let		theToneRef = anInRefCon.assumingMemoryBound(to: Tone.self);
				let		theTone = theToneRef.pointee;
				let		theGain = Float32(0.5);
				assert( theGain > 0.0, "bad gain value: \(theGain)" );
				//		assert( !playingTones.isEmpty, "no tones" );
				if !theSamples.isEmpty {
					theTone.generate( buffer: theSamples, gain: theGain, count: Int(anInNumberFrames) );
					if theToneRef.pointee.complete {
						theToneRef.pointee.stop();
					}
				}
			}
			return theResult;
		}

		// Create a new unit based on this that we'll use for output
		var		err = AudioComponentInstanceNew( AudioComponentFindNext(nil, &theDefaultOutputDescription)!, &theResult);

		// Set our tone rendering function on the unit
		//		var		theTonePlayer = self;
		let		theSelf = UnsafeMutablePointer<Tone>.allocate(capacity: 1);
		theSelf.initialize(to: self);
		var		theInput = AURenderCallbackStruct( inputProc: toneCallback, inputProcRefCon: theSelf );
		err = AudioUnitSetProperty(theResult!, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &theInput, UInt32(MemoryLayout<AURenderCallbackStruct>.size));

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

		err = AudioUnitSetProperty (theResult!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, AudioUnitElement(0), &theStreamFormat, UInt32(MemoryLayout<AudioStreamBasicDescription>.size) );

		assert(err == noErr, "Error setting stream format: \(err)" );
		err = AudioUnitInitialize(theResult!);
		assert(err == noErr, "Error starting unit: \(err)" );
		return theResult!;
	}

	init( baseFrequency aBaseFrequency: Double, interval anInterval: Interval, harmonics aHarmonics: HarmonicsDescription ) {
		baseFrequency = aBaseFrequency;
		interval = anInterval;
		harmonics = aHarmonics;
		toneUnit = nil;
		var		theDefaultOutputDescription = AudioComponentDescription( componentType: OSType(kAudioUnitType_Output),
			componentSubType: OSType(kAudioUnitSubType_DefaultOutput),
			componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
			componentFlags: 0,
			componentFlagsMask: 0);
		func toneCallback( _ anInRefCon : UnsafeMutableRawPointer, anIOActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, anInTimeStamp : UnsafePointer<AudioTimeStamp>, anInBusNumber: UInt32, anInNumberFrames: UInt32, anIOData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
			let		theResult : OSStatus = kAudioServicesNoError;
			if let theBuffer : AudioBuffer = anIOData?.pointee.mBuffers {
				let		theSamples = UnsafeMutableBufferPointer<Float32>(theBuffer);
				let		theToneRef = anInRefCon.assumingMemoryBound(to: Tone.self);
				let		theTone = theToneRef.pointee;
				let		theGain = Float32(0.5);
				assert( theGain > 0.0, "bad gain value: \(theGain)" );
				if !theSamples.isEmpty {
					theTone.generate( buffer: theSamples, gain: theGain, count: Int(anInNumberFrames) );
					if theToneRef.pointee.complete {
						theToneRef.pointee.stop();
					}
				}
			}
			return theResult;
		}

		// Create a new unit based on this that we'll use for output
		var		err = AudioComponentInstanceNew( AudioComponentFindNext(nil, &theDefaultOutputDescription)!, &toneUnit);

		// Set our tone rendering function on the unit
		//		var		theTonePlayer = self;
		let		theSelf = UnsafeMutablePointer<Tone>.allocate(capacity: 1);
		theSelf.initialize(to: self);
		var		theInput = AURenderCallbackStruct( inputProc: toneCallback, inputProcRefCon: theSelf );
		err = AudioUnitSetProperty(toneUnit!, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &theInput, UInt32(MemoryLayout<AURenderCallbackStruct>.size));

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

		err = AudioUnitSetProperty (toneUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, AudioUnitElement(0), &theStreamFormat, UInt32(MemoryLayout<AudioStreamBasicDescription>.size) );

		assert(err == noErr, "Error setting stream format: \(err)" );
		err = AudioUnitInitialize(toneUnit!);
		assert(err == noErr, "Error starting unit: \(err)" );
		assert(thetaDelta < 1.0);
	}

	final func generate( buffer aBuffer : UnsafeMutableBufferPointer<Float32>, gain aGain: Float32, count aCount : Int ) {
		var		theEnvelope : Float32 = 0.0;
		let		theThreshold = powf(2.0,-7.0);
		for j : Int in 0..<aCount {
			(complete,theEnvelope) = envelope[Float32(theta)];
			if !complete {
				var		theTotal : Float32 = 0.0;
				for i in 1...min(harmonics.maximumHarmonic,Int(0.5/thetaDelta)) {
					if i%2 == 1 && harmonics.amplitudes[i] < theThreshold { break; }
					let theFreq = harmonics.frequency[i];
					theTotal += harmonics.amplitudes[i]*Float32(sin(theta*theFreq));
				}
				aBuffer[j] = Float32(theTotal)*aGain*theEnvelope;
				theta += thetaDelta;
			}
		}
	}

	/*
	final func generate( buffer aBuffer : UnsafeMutableBufferPointer<Float32>, gain aGain: Float32, count aCount : Int ) {
		var		theEnvelope : Float32 = 0.0;
		let		theThreshold = powf(2.0,-7.0);
		for j : Int in 0..<aCount {
			(complete,theEnvelope) = envelope[Float32(theta)];
			if !complete {
				var		theTotal : Float32 = 0.0;
				for i in 1...min(harmonics.maximumHarmonic,Int(0.5/thetaDelta)) {
					if i%2 == 1 && harmonics.amplitudes[i] < theThreshold { break; }
					theTotal += harmonics.amplitudes[i]*Float32(sin(theta*harmonics.frequency[i]));
				}
				aBuffer[j] = Float32(theTotal)*aGain*theEnvelope;
				theta += thetaDelta;
			}
		}
	}
	*/

//	final func fastGenerate( buffer aBuffer : UnsafeMutableBufferPointer<Float32>, gain aGain: Float32, count aCount : Int ) {
//		var		theEnvelope : Float32 = 0.0;
//		for j : Int in 0.stride(through: aCount, by: 8) {
//			(complete,theEnvelope) = envelope[Float32(theta)];
//			if !complete {
//				var		theTotal : UnsafeMutablePointer<Float> = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
//				for i in 1...min(harmonics.maximumHarmonic,Int(0.5/thetaDelta)) {
//			vvsinf( theTotal,
//		          _: UnsafePointer<Float>,
//		             _: UnsafePointer<Int32>);
//			}
//		}
//	}

	func stop() {
		if playing  {
			let		theError = AudioOutputUnitStop(self.toneUnit! );
			assert( theError == noErr, "Error starting unit: 0x\(UInt(theError).hexadecimalString)");
			envelope.beginRelease = true;
			playing = false;
		}
	}

	func play( ) {
		if !playing {
			let		theError = AudioOutputUnitStart(self.toneUnit!);
			assert( theError == noErr, "Error starting unit: 0x\(UInt(theError).hexadecimalString)");
			playing = theError == noErr;
		}
	}

	func release() {
		envelope.hold = Float32(theta)-envelope.attack;
	}
}

extension Tone : Hashable {
	public var hashValue: Int {
		get { return interval.hashValue; }
	}
	public static func ==(aLhs: Tone, aRhs: Tone) -> Bool {
		return aLhs.interval == aRhs.interval;
	}
}

