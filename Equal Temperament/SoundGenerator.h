//
//  SoundGenerator.h
//  Equal Temperament
//
//  Created by Nathan Day on 8/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

#import <Foundation/Foundation.h>

typdef enum {
	kMusicSequenceTypeUnison,
	kMusicSequenceTypeUp,
	kMusicSequenceTypeDown,
	kMusicSequenceTypeBoth
}	MusicSequenceType;

struct Oscillator {
	const double		delta;
	double				theta;
};


@interface TonePlayer : NSObject
{
	double							_baseFrequency;
	struct HarmonicsDescription		_harmonicsDescription;
	double							_noteDuration;
	enum MusicSequenceType			_sequenceType;
	RatiosPlayler					* _oscillator;
}

@property(assign,nonatomic) double							baseFrequency;
@property(assign,nonatomic) struct HarmonicsDescription		harmonicsDescription;
@property(assign,nonatomic) double							noteDuration;
@property(assign,nonatomic) enum MusicSequenceType			sequenceType;
@property(assign,nonatomic)	RatiosPlayler					* oscillator;

- (void)generateOSC
{
}

- (void)playRatios:(NSArray *)aRatios musicSequenceType:(MusicSequenceType)aChord {

}

@end
