//
//  Oscillator.m
//  Equal Temperament
//
//  Created by Nathan Day on 7/06/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

#import "Oscillator.h"

@implementation Oscillator

@end

@implementation OscillatorSet

@end

OSStatus oscillatorCallback( void * inRefCon, AudioUnitRenderActionFlags * ioActionFlags, const AudioTimeStamp * inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList * ioData)
{
	OscillatorSet		* theOscillatorSet = (__bridge OscillatorSet*)inRefCon;
	return noErr;
}
