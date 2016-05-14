/*
	HarmonicView.swift
	Intonation

	Created by Nathan Day on 5/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

func pow(x: Int, y: UInt) -> Int {
	var		theResult = 1;
	for _ in 0...y {
		theResult = theResult * x;
	}
	return theResult;
}

func lengthForRange(aRange: Range<UInt> ) -> UInt {
	return aRange.endIndex - aRange.startIndex;
}

func log10( aValue : UInt ) -> UInt {
	var		thrValue = aValue;
	var		theResult = UInt(0)
	while thrValue > 10 {
		thrValue = thrValue/10;
		theResult += 1;
	}
	return theResult;
}

func greatestCommonDivisor(u: [Rational] ) -> Int {
	var		theResult = 1;
	for theNumber in u {
		theResult = Int(greatestCommonDivisor( UInt(theResult), UInt(theNumber.numerator)));
	}
	return theResult;
}

class HarmonicView: ResultView {

	var		octaveRange = UInt(2)...UInt(5);
	var		showFundamental = false {
		didSet {
			updateOctaveRange();
			setNeedsDisplay();
		}
	}

	override var	selectedRatios : [Interval] {
		didSet(aValue) {
			updateOctaveRange();
			setNeedsDisplay();
		}
	}

	final private func updateOctaveRange() {
		var		theOctaveStart : UInt = 0;
		var		theOctaveEnd : UInt = 0;
		let		theCommonFactor = commonFactor;
		if let theFirst = selectedRatios.first {
			theOctaveStart = theCommonFactor > 1 ? HarmonicView.octaveForHarmonic(UInt(theCommonFactor)) : 0;
			if let theNum = theFirst.numeratorForDenominator(theCommonFactor) {
				theOctaveEnd = theNum > 0 ? HarmonicView.octaveForHarmonic(UInt(theNum)) : 1;
			}
			else {
				theOctaveEnd = theOctaveStart;
			}
			for theRational in selectedRatios {
				if let theNum = theRational.numeratorForDenominator(theCommonFactor) {
					let		theNumeratorOctave = theNum > 0 ? HarmonicView.octaveForHarmonic(UInt(theNum)) : 0;
					if theNumeratorOctave > theOctaveEnd {
						theOctaveEnd = theNumeratorOctave;
					}
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
		let		theHarmonicSpacing : CGFloat = max(20.0,CGFloat(10-selectedRatios.count)*5.0);
		var		theBounds = NSInsetRect(self.bounds, 20.0, 20.0);
		let		theXOrigin = max(NSMidX(theBounds)-CGFloat(max(0,selectedRatios.count))*theHarmonicSpacing*0.55-8.0,NSMinX(self.bounds)+20.0);
		theBounds.origin.y += 10.0;
        super.drawRect(dirtyRect)

		func drawOctave( anOctave: UInt ) {
			let		theSize = NSFont.systemFontSizeForControlSize(NSControlSize.RegularControlSize)*1.25;
			let		theOctaveHeight = NSHeight(theBounds)/CGFloat(lengthForRange(octaveRange));
			let		theY = floor((CGFloat(anOctave-octaveRange.startIndex)+0.5) * theOctaveHeight+NSMinY(theBounds));
			drawText(string: "\(anOctave+1)", size:theSize, point: NSMakePoint(theXOrigin-2.5, theY-theSize*0.55), color: NSColor.darkGrayColor());
			let		thePath = NSBezierPath();
			thePath.lineWidth = 0.5;
			thePath.moveToPoint(NSMakePoint(theXOrigin+3.5, theY+theOctaveHeight/2.0-5.0));
			thePath.lineToPoint(NSMakePoint(theXOrigin+3.5, theY+theSize*0.75));
			thePath.moveToPoint(NSMakePoint(theXOrigin+3.5, theY-theSize*0.45));
			thePath.lineToPoint(NSMakePoint(theXOrigin+3.5, theY-theOctaveHeight/2.0+5.0));
			NSColor.darkGrayColor().setStroke();
			thePath.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
			thePath.stroke()
		}

		func drawHarmonic( aHarmonic: UInt ) {
			let		theSubInterval = aHarmonic-(1<<HarmonicView.octaveForHarmonic(aHarmonic));
			let		theY = yValueForHarmonic(aHarmonic, bounds: theBounds);
			let		thePath = NSBezierPath();
			if theSubInterval == 0 {
				let		theColor = NSColor(deviceRed: 0.0, green: 0.0, blue: 0.75, alpha: 1.0);
				thePath.lineWidth = 2.0;
				thePath.moveToPoint(NSMakePoint(theXOrigin, floor(theY*2.0)*0.5+0.25));
				thePath.lineToPoint(NSMakePoint(theXOrigin+28.0, floor(theY*2.0)*0.5+0.25));
				thePath.moveToPoint(NSMakePoint(theXOrigin+38.0+6.5*CGFloat(log10(aHarmonic)), floor(theY*2.0)*0.5+0.25));
				thePath.lineToPoint(NSMakePoint(theXOrigin+62.0, floor(theY*2.0)*0.5+0.25));
				theColor.setStroke();
				drawText(string: "\(aHarmonic)", size:NSFont.systemFontSizeForControlSize(NSControlSize.SmallControlSize), point: NSMakePoint(theXOrigin+29.5, floor(theY*2.0)*0.5-7.5), color:theColor );
			}
			else {
				thePath.moveToPoint(NSMakePoint(theXOrigin+30.0, floor(theY*2.0)*0.5+0.25));
				thePath.lineWidth = 1.0;
				if (aHarmonic)%4 == 0 {
					thePath.lineToPoint(NSMakePoint(theXOrigin+58.0, floor(theY*2.0)*0.5+0.25));
					NSColor.darkGrayColor().setStroke();
				}
				else if (aHarmonic)%2 == 0 {
					thePath.lineToPoint(NSMakePoint(theXOrigin+54.0, floor(theY*2.0)*0.5+0.25));
					NSColor.grayColor().setStroke();
				}
				else {
					thePath.lineToPoint(NSMakePoint(theXOrigin+50.0, floor(theY*2.0)*0.5+0.25));
					NSColor.lightGrayColor().setStroke();
				}
			}
			thePath.stroke()
		}

		func drawRatio( aRatio: Interval, index anIndex: Int, of anOf: Int ) {
			let		theYDenom = yValueForHarmonic( UInt(commonFactor), bounds: theBounds );
			let		theSize = NSFont.systemFontSizeForControlSize(NSControlSize.SmallControlSize);
			if aRatio == 1 {
				let		thePath = NSBezierPath();
				let		theX = theXOrigin+75.0+CGFloat(anOf)*theHarmonicSpacing;
				thePath.moveToPoint(NSMakePoint(theXOrigin+65.0, theYDenom ));
				thePath.lineToPoint(NSMakePoint(theX+5.0, theYDenom));
				NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
				thePath.lineWidth = 4.0;
				thePath.stroke()
				drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX+5.0, theYDenom-8.5), color:NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0) );
			}
			else if let theNum = aRatio.numeratorForDenominator(commonFactor)
			{
				let		theYNum = yValueForHarmonic( UInt(theNum), bounds: theBounds );
				let		theYDelta = abs(theYNum-theYDenom);
				let		thePath = NSBezierPath();
				let		theX = theXOrigin+75.0+CGFloat(anIndex)*theHarmonicSpacing;

				thePath.moveToPoint(NSMakePoint(theXOrigin+65.0, theYNum ));
				thePath.lineToPoint(NSMakePoint(theX-10.0, theYNum));
				thePath.curveToPoint( NSMakePoint(theX, theYNum-theYDelta/2.0+6.0), controlPoint1: NSMakePoint(theX, theYNum), controlPoint2: NSMakePoint(theX, theYNum));
				thePath.moveToPoint(NSMakePoint(theX, theYDenom+theYDelta/2.0-6.0));
				thePath.curveToPoint( NSMakePoint(theX-10.0, theYDenom), controlPoint1: NSMakePoint(theX, theYDenom), controlPoint2: NSMakePoint(theX, theYDenom));
				thePath.lineToPoint(NSMakePoint(theXOrigin+65.0, theYDenom));
				NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
				thePath.lineWidth = 4.0;
				thePath.stroke()
				drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX-7.0, theYDenom+theYDelta/2.0-8.5), color:NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0) );
			}
		}

		for i in (1<<octaveRange.startIndex)...(1<<(octaveRange.endIndex)) { drawHarmonic(i); }
		for i in octaveRange { drawOctave( i ); }
		for (theIndex,theRatio) in selectedRatios.enumerate() {
			drawRatio( theRatio, index:theIndex, of:selectedRatios.count );
		}
    }
}
