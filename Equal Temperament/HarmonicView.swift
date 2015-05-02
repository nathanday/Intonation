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
	var		showFundamental = false {
		didSet {
			updateOctaveRange();
			setNeedsDisplay();
		}
	}

	override var	selectedRatios : [Rational] {
		didSet(aValue) {
			updateOctaveRange();
			setNeedsDisplay();
		}
	}

	final private func updateOctaveRange() {
		var		theOctaveStart : UInt = 0;
		var		theOctaveEnd : UInt = 0;
		var		theCommonFactor = commonFactor;
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
		var		theBounds = NSInsetRect(self.bounds, 20.0, 20.0);
		theBounds.origin.y += 10.0;
        super.drawRect(dirtyRect)

		func drawOctave( anOctave: UInt ) {
			let		theSize = NSFont.systemFontSizeForControlSize(NSControlSize.RegularControlSize)*1.25;
			let		theOctaveHeight = NSHeight(theBounds)/CGFloat(lengthForRange(octaveRange));
			let		theX = NSMinX(theBounds)+10.0;
			let		theY = floor((CGFloat(anOctave-octaveRange.startIndex)+0.5) * theOctaveHeight+NSMinY(theBounds));
			drawText(string: "\(anOctave+1)", size:theSize, point: NSMakePoint(theX-2.5, theY-theSize*0.55), color: NSColor.darkGrayColor());
			var		thePath = NSBezierPath();
			thePath.lineWidth = 0.5;
			thePath.moveToPoint(NSMakePoint(theX+3.5, theY+theOctaveHeight/2.0-5.0));
			thePath.lineToPoint(NSMakePoint(theX+3.5, theY+theSize*0.75));
			thePath.moveToPoint(NSMakePoint(theX+3.5, theY-theSize*0.45));
			thePath.lineToPoint(NSMakePoint(theX+3.5, theY-theOctaveHeight/2.0+5.0));
			NSColor.darkGrayColor().setStroke();
			thePath.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
			thePath.stroke()
		}

		func drawHarmonic( aHarmonic: UInt ) {
			let		theSubInterval = aHarmonic-(1<<HarmonicView.octaveForHarmonic(aHarmonic));
			let		theY = yValueForHarmonic(aHarmonic, bounds: theBounds);
			var		thePath = NSBezierPath();
			if theSubInterval == 0 {
				let		theColor = NSColor(deviceRed: 0.0, green: 0.0, blue: 0.75, alpha: 1.0);
				thePath.lineWidth = 2.0;
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+10.0, floor(theY*2.0)*0.5+0.25));
				thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+38.0, floor(theY*2.0)*0.5+0.25));
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+48.0+6.5*CGFloat(log10(aHarmonic)), floor(theY*2.0)*0.5+0.25));
				thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+72.0, floor(theY*2.0)*0.5+0.25));
				theColor.setStroke();
				drawText(string: "\(aHarmonic)", size:NSFont.systemFontSizeForControlSize(NSControlSize.SmallControlSize), point: NSMakePoint(NSMinX(theBounds)+39.5, floor(theY*2.0)*0.5-7.5), color:theColor );
			}
			else {
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+40.0, floor(theY*2.0)*0.5+0.25));
				thePath.lineWidth = 1.0;
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

		func drawRatio( aRatio: Rational, index anIndex: Int, of anOf: Int ) {
			let		theYDenom = yValueForHarmonic( UInt(commonFactor), bounds: theBounds );
			let		theSize = NSFont.systemFontSizeForControlSize(NSControlSize.SmallControlSize);
			if aRatio == 1 {
				var		thePath = NSBezierPath();
				let		theX = NSMinX(theBounds)+85.0+CGFloat(anOf)*20.0;
				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+75.0, theYDenom ));
				thePath.lineToPoint(NSMakePoint(theX+3.0, theYDenom));
				NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
				thePath.lineWidth = 4.0;
				thePath.stroke()
				drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX+5.0, theYDenom-8.5), color:NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0) );
			}
			else if let theNum = aRatio.numeratorForDenominator(commonFactor)
			{
				let		theYNum = yValueForHarmonic( UInt(theNum), bounds: theBounds );
				let		theYDelta = abs(theYNum-theYDenom);
				var		thePath = NSBezierPath();
				let		theX = NSMinX(theBounds)+85.0+CGFloat(anIndex)*20.0;

				thePath.moveToPoint(NSMakePoint(NSMinX(theBounds)+75.0, theYNum ));
				thePath.lineToPoint(NSMakePoint(theX-10.0, theYNum));
				thePath.curveToPoint( NSMakePoint(theX, theYNum-theYDelta/2.0+6.0), controlPoint1: NSMakePoint(theX, theYNum), controlPoint2: NSMakePoint(theX, theYNum));
				thePath.moveToPoint(NSMakePoint(theX, theYDenom+theYDelta/2.0-6.0));
				thePath.curveToPoint( NSMakePoint(theX-10.0, theYDenom), controlPoint1: NSMakePoint(theX, theYDenom), controlPoint2: NSMakePoint(theX, theYDenom));
				thePath.lineToPoint(NSMakePoint(NSMinX(theBounds)+75.0, theYDenom));
				NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
				thePath.lineWidth = 4.0;
				thePath.stroke()
				drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX-7.0, theYDenom+theYDelta/2.0-8.5), color:NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0) );
			}
		}

		for i in (1<<octaveRange.startIndex)...(1<<(octaveRange.endIndex)) { drawHarmonic(i); }
		for i in octaveRange { drawOctave( i ); }
		for i in 0..<selectedRatios.count { drawRatio( selectedRatios[i], index:i, of:selectedRatios.count ); }
    }
}
