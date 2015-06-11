//
//  Oscillator.h
//  Equal Temperament
//
//  Created by Nathan Day on 7/06/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define kSampleRate		44100


typedef enum {
	kPlaybackUnison,
	kPlaybackUp,
	kPlaybackDown,
	kPlaybackUpDown
}	PlaybackType;

@interface Oscillator : NSObject
{
	unsigned long		theta;
	Float32				values[kSampleRate/20];
	NSUInteger			length;
}

@end


@interface OscillatorSet : NSObject
{
	struct Oscillator		* oscillator;
	NSUInteger				count;
}

@end

OSStatus oscillatorCallback( void * inRefCon, AudioUnitRenderActionFlags * ioActionFlags, const AudioTimeStamp * inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList * ioData);

