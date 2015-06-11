//
//  TonePlayer.h
//  Equal Temperament
//
//  Created by Nathan Day on 8/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

#pragma once

#include <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum {
	kPlaybackUnison,
	kPlaybackUp,
	kPlaybackDown,
	kPlaybackUpDown
}	PlaybackType;

struct OscillatorSet {
	struct Oscillator		* oscillator;
	NSUInteger				count;
};

struct Oscillator {
	unsigned long		theta;
	struct
	{
		Float32				values[kSampleRate/20];
		NSUInteger			length;
	}					waveTable;
};
