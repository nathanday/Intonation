//
//  SoundGenerator.h
//  Equal Temperament
//
//  Created by Nathan Day on 8/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

#import <Foundation/Foundation.h>

enum MusicSequenceType {
	kMusicSequenceTypeUp,
	kMusicSequenceTypeDown,
	kMusicSequenceTypeBoth
};

struct HarmonicsDescription {
	double		amount,
				evenAmount;
	double		noteDuration;
};


@interface RatiosPlayler : NSObject

- (instancetype)initWithHarmonicsDescription:(struct HarmonicsDescription)aHarmonicsDescription frequency:(double)aFrequency;

@end

@interface SoundGenerator : NSObject
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
	_oscillator = [[RatiosPlayler alloc] initWithHarmonicsDescription:self.harmonicsDescription frequency:self.baseFrequency];
}

- (void)playRatios:(NSArray *)aRatios chord:(BOOL)aChord {
	
}

@end
