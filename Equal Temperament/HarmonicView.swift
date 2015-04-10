//
//  HarmonicView.swift
//  Equal Temperament
//
//  Created by Nathan Day on 5/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

func pow(x: Int, y: UInt) -> Int {
	var		theResult = 1;
	for i in 0...y {
		theResult = theResult * x;
	}
	return theResult;
}

func log2( aValue : UInt ) -> UInt { return aValue == 0 ? 0 : 1 + log2( aValue>>1 ); }

func length(range aRange: Range<UInt> ) -> UInt {
	return aRange.endIndex - aRange.startIndex;
}

func log10( var aValue : UInt ) -> UInt {
	var		theResult = UInt(0)
	while aValue > 10 {
		aValue = aValue/10;
		theResult++;
	}
	return theResult;
}

class HarmonicView: ResultView {
	var		octaveRange = UInt(2)...UInt(5);
	
	var		justIntonationRatios : [Rational] = [] {
		didSet {
			updateOctaveRange();
			setNeedsDisplay();
		}
	}
	
	final private func updateOctaveRange() {
		var		theOctaveStart : UInt = 1;
		var		theOctaveEnd : UInt = 2;
		if let theFirst = justIntonationRatios.first {
			theOctaveStart = log2(UInt(theFirst.denominator));
			theOctaveEnd = log2(UInt(theFirst.numerator));
			for theRational in justIntonationRatios {
				let		theDenominatorOctave = log2(UInt(theRational.denominator));
				let		theNumeratorOctave = log2(UInt(theRational.numerator));
				if theNumeratorOctave > theOctaveEnd {
					theOctaveEnd = theNumeratorOctave;
				}
				else if theDenominatorOctave < theOctaveStart {
					theOctaveStart = theDenominatorOctave;
				}
			}
		}
		octaveRange = theOctaveStart...theOctaveEnd;
	}

	override func drawRect(dirtyRect: NSRect) {
		let		theBounds = NSInsetRect(self.bounds, 20.0, 20.0);
        super.drawRect(dirtyRect)
	
		func drawOctave( octave anOctave: UInt ) {
			let		theSize = NSFont.systemFontSizeForControlSize(NSControlSize.RegularControlSize);
			drawText(string: "\(anOctave+1)", size:theSize, point: NSMakePoint(NSMinX(theBounds)+10.0, (CGFloat(anOctave-octaveRange.startIndex)+0.5) * NSHeight(theBounds)/CGFloat(length(range:octaveRange))+NSMinY(theBounds)-theSize*0.5), selected:false );
		}
		
		func drawHarmonic( harmonic aHarmonic: UInt ) {
			let		theOctave = log2(aHarmonic+1)-1;
			let		theSubInterval = aHarmonic+1-(1<<(log2(aHarmonic+1)-1));
			let		theSubIntervalCount = 1<<(log2(aHarmonic+1)-1);

			let		theY = (CGFloat(theOctave-octaveRange.startIndex) + CGFloat(theSubInterval)/CGFloat(theSubIntervalCount)) * NSHeight(theBounds)/CGFloat(length(range:octaveRange)) + NSMinY(theBounds);
			var		thePath = NSBezierPath()
			if theSubInterval == 0 {
				let		theColor = NSColor(deviceRed: 0.0, green: 0.0, blue: 0.75, alpha: 1.0);
				thePath.lineWidth = 1.0;
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+10.0, floor(theY*2.0)*0.5+0.25));
				thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+43.0, floor(theY*2.0)*0.5+0.25))
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+52.0+6*CGFloat(log10(aHarmonic+1)), floor(theY*2.0)*0.5+0.25));
				thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+72.0, floor(theY*2.0)*0.5+0.25))
				theColor.setStroke();
				drawText(string: "\(aHarmonic+1)", size:NSFont.systemFontSizeForControlSize(NSControlSize.MiniControlSize), point: NSMakePoint(NSMinX(theBounds)+45.0, floor(theY*2.0)*0.5-8.0), color:theColor, selected:false );
			}
			else {
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+40.0, floor(theY*2.0)*0.5+0.25));
				thePath.lineWidth = 0.5;
				if (aHarmonic+1)%4 == 0 {
					thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+68.0, floor(theY*2.0)*0.5+0.25));
					NSColor.darkGrayColor().setStroke();
				}
				else if (aHarmonic+1)%2 == 0 {
					thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+64.0, floor(theY*2.0)*0.5+0.25));
					NSColor.grayColor().setStroke();
				}
				else {
					thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+60.0, floor(theY*2.0)*0.5+0.25));
					NSColor.lightGrayColor().setStroke();
				}
			}
			thePath.stroke()
		}

		for i in (1<<octaveRange.startIndex)-1..<(1<<octaveRange.endIndex) {
			drawHarmonic(harmonic: i);
		}
		for i in octaveRange {
			drawOctave( octave:i );
		}
    }
    
}
