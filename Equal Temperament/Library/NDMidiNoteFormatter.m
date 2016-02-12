//
//  NDMidiNoteFormatter.m
//  NDFormaters
//
//  Created by Nathan Day on 13/04/13.
//  Copyright (c) 2013 Nathan Day. All rights reserved.
//

#import "NDMidiNoteFormatter.h"

@implementation NDMidiNoteFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
	NSString			* theResult = nil;
	if( [anObject isKindOfClass:[NSNumber class]] )
	{
		static NSString		* const kNoteNames[] = { @"C", @"C\u266F", @"D", @"D\u266F", @"E", @"F", @"F\u266F", @"G", @"G\u266F", @"A", @"A\u266F", @"B" };
		NSUInteger			theNoteNumber = [anObject unsignedIntegerValue];
		theResult = [NSString stringWithFormat:@"%@%ld", NSLocalizedString(kNoteNames[theNoteNumber%12], @"Note Name"), theNoteNumber/12 - 2];
	}
	return theResult;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)aString errorDescription:(NSString **)anError
{
	BOOL		theResult = NO;
	NSScanner	* theScanner = [NSScanner scannerWithString:aString];
	NSString	* theNoteName = nil;
	if( [theScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefgABCDEFG"] intoString:&theNoteName] )
	{
		unichar			theChar = [theNoteName characterAtIndex:0];
		NSInteger		theNoteNumber = theChar - (islower(theChar) ? 'c' : 'C');
		NSString		* theArg = nil;
		NSInteger		theOctave = 0;
		if( [theScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"#+b-4"] intoString:&theArg] )
		{
			if( [theArg isEqualToString:@"#"] || [theArg isEqualToString:@"+"] )
				theNoteNumber += 1;
			else if( [theArg isEqualToString:@"b"] || [theArg isEqualToString:@"-"] )
				theNoteNumber--;
		}

		if( ![theScanner scanInteger:&theOctave] )
			theOctave = 3;
		*anObject = [NSNumber numberWithInteger:theNoteNumber+(theOctave+2)*12];
		theResult = YES;
	}
	else
	{
		NSInteger	theIntegerValue = aString.integerValue;
		if( theIntegerValue >= 0 && theIntegerValue <= 127 )
		{
			*anObject = [NSNumber numberWithInteger:theIntegerValue];
			theResult = YES;
		}
		else if( anError != nil )
			*anError = NSLocalizedString(@"Bad note name", @"Error message when the note name can not be recognized");
	}

	return theResult;
}

@end
