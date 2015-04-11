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

func lengthForRange(aRange: Range<UInt> ) -> UInt {
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

func greatestCommonDivisor(u: [Rational] ) -> Int {
	var		theResult = 1;
	for theNumber in u {
		theResult = greatestCommonDivisor(theResult, theNumber.numerator);
	}
	return theResult;
}

class HarmonicView: ResultView {
	var		octaveRange = UInt(2)...UInt(5);
	var		commonDenominator : Int = 1;
	var		showFundamental = false {
		didSet {
			updateOctaveRange();
			setNeedsDisplay();
		}
	}
	
	var		justIntonationRatios : [Rational] = [] {
		didSet {
			commonDenominator = greatestCommonDivisor(justIntonationRatios);
			updateOctaveRange();
			setNeedsDisplay();
		}
	}
	
	final private func updateOctaveRange() {
		var		theOctaveStart : UInt = 1;
		var		theOctaveEnd : UInt = 1;
		if let theFirst = justIntonationRatios.first {
			theOctaveStart = theFirst.denominator > 1 ? HarmonicView.octaveForHarmonic(UInt(theFirst.denominator)) : 0;
			theOctaveEnd = theFirst.numerator > 1 ? HarmonicView.octaveForHarmonic(UInt(theFirst.numerator-1)) : 1;
			for theRational in justIntonationRatios {
				let		theDenominatorOctave = theRational.denominator > 1 ? HarmonicView.octaveForHarmonic(UInt(theRational.denominator)) : 0;
				let		theNumeratorOctave = theRational.numerator > 1 ? HarmonicView.octaveForHarmonic(UInt(theRational.numerator-1)) : 0;
				if theNumeratorOctave > theOctaveEnd {
					theOctaveEnd = theNumeratorOctave;
				}
				else if theDenominatorOctave < theOctaveStart {
					theOctaveStart = theDenominatorOctave;
				}
			}
		}
		if showFundamental {
			octaveRange = 0...theOctaveEnd;
		}
		else {
			octaveRange = theOctaveStart...theOctaveEnd;
		}
	}
	
	final class func octaveForHarmonic( aHarmonic: UInt ) -> UInt {
		return log2(aHarmonic)-1;
	}

	final func yValueForHarmonic( aHarmonic: UInt ) -> CGFloat { return yValueForHarmonic( aHarmonic, bounds: self.bounds ); }

	final private func yValueForHarmonic( aHarmonic: UInt, bounds aBounds: NSRect ) -> CGFloat {
		let		theOctave = HarmonicView.octaveForHarmonic(aHarmonic);
		let		theSubInterval = aHarmonic-(1<<HarmonicView.octaveForHarmonic(aHarmonic));
		let		theSubIntervalCount = 1<<HarmonicView.octaveForHarmonic(aHarmonic);

		let		theFractionPoint = CGFloat(theOctave-octaveRange.startIndex) + CGFloat(theSubInterval)/CGFloat(theSubIntervalCount);
		
		return theFractionPoint * NSHeight(aBounds)/CGFloat(lengthForRange(octaveRange)) + NSMinY(aBounds);
	}

	override func drawRect(dirtyRect: NSRect) {
		let		theBounds = NSInsetRect(self.bounds, 20.0, 20.0);
        super.drawRect(dirtyRect)
	
		func drawOctave( anOctave: UInt ) {
			let		theSize = NSFont.systemFontSizeForControlSize(NSControlSize.RegularControlSize);
			let		theOctaveHeight = NSHeight(theBounds)/CGFloat(lengthForRange(octaveRange));
			let		theX = NSMinX(theBounds)+10.0;
			let		theY = floor((CGFloat(anOctave-octaveRange.startIndex)+0.5) * theOctaveHeight+NSMinY(theBounds));
			drawText(string: "\(anOctave+1)", size:theSize, point: NSMakePoint(theX, theY-theSize*0.5), selected:false );
			var		thePath = NSBezierPath();
			thePath.lineWidth = 0.125;
			thePath.moveToPoint(NSMakePoint(theX+3.5, theY+theOctaveHeight/2.0-5.0));
			thePath.lineToPoint(NSMakePoint(theX+3.5, theY+theSize*0.75));
			thePath.moveToPoint(NSMakePoint(theX+3.5, theY-theSize*0.45));
			thePath.lineToPoint(NSMakePoint(theX+3.5, theY-theOctaveHeight/2.0+5.0));
			NSColor.lightGrayColor().setStroke();
			thePath.stroke()
		}
		
		func drawHarmonic( aHarmonic: UInt ) {
			let		theSubInterval = aHarmonic-(1<<HarmonicView.octaveForHarmonic(aHarmonic));
			let		theY = yValueForHarmonic(aHarmonic, bounds: theBounds);
			var		thePath = NSBezierPath()
			if theSubInterval == 0 {
				let		theColor = NSColor(deviceRed: 0.0, green: 0.0, blue: 0.75, alpha: 1.0);
				thePath.lineWidth = 1.0;
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+10.0, floor(theY*2.0)*0.5+0.25));
				thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+43.0, floor(theY*2.0)*0.5+0.25))
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+52.0+6*CGFloat(log10(aHarmonic)), floor(theY*2.0)*0.5+0.25));
				thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+72.0, floor(theY*2.0)*0.5+0.25))
				theColor.setStroke();
				drawText(string: "\(aHarmonic)", size:NSFont.systemFontSizeForControlSize(NSControlSize.MiniControlSize), point: NSMakePoint(NSMinX(theBounds)+45.0, floor(theY*2.0)*0.5-8.0), color:theColor, selected:false );
			}
			else {
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+40.0, floor(theY*2.0)*0.5+0.25));
				thePath.lineWidth = 0.5;
				if (aHarmonic)%4 == 0 {
					thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+68.0, floor(theY*2.0)*0.5+0.25));
					NSColor.darkGrayColor().setStroke();
				}
				else if (aHarmonic)%2 == 0 {
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

		func drawRatio( aRatio: Rational, index anIndex: Int ) {
			let		theYNum = yValueForHarmonic( UInt(aRatio.numerator), bounds: theBounds );
			let		theYDenom = yValueForHarmonic( UInt(aRatio.denominator), bounds: theBounds );
			let		theSize = NSFont.systemFontSizeForControlSize(NSControlSize.MiniControlSize);
			var		thePath = NSBezierPath()
			let		theYDelta = abs(theYNum-theYDenom);
			let		theX = NSMinX(theBounds)+85.0+CGFloat(anIndex)*15.0
			thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+75.0, theYNum ));
			thePath.lineToPoint(NSMakePoint(theX-10.0, theYNum));
			thePath.curveToPoint( NSMakePoint(theX, theYNum-theYDelta/2.0+6.0), controlPoint1: NSMakePoint(theX, theYNum), controlPoint2: NSMakePoint(theX, theYNum));
			thePath.moveToPoint(NSMakePoint(theX, theYDenom+theYDelta/2.0-6.0));
			thePath.curveToPoint( NSMakePoint(theX-10.0, theYDenom), controlPoint1: NSMakePoint(theX, theYDenom), controlPoint2: NSMakePoint(theX, theYDenom));
			thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+75.0, theYDenom));
			NSColor.redColor().setStroke();
			thePath.lineWidth = 1.0;
			thePath.stroke()
			drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX-7.0, theYDenom+theYDelta/2.0-8.0), color:NSColor.redColor(), selected:false );
		}

		for i in (1<<octaveRange.startIndex)...(1<<(octaveRange.endIndex)) {
			drawHarmonic(i);
		}
		for i in octaveRange {
			drawOctave( i );
		}

		for i in 0..<justIntonationRatios.count {
			drawRatio( justIntonationRatios[i], index:i );
		}
    }
    
}
