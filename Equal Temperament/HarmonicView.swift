/*
	HarmonicView.swift
	Intonation

	Created by Nathan Day on 5/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

func pow(_ x: Int, y: UInt) -> Int {
	var		theResult = 1;
	for _ in 0...y {
		theResult = theResult * x;
	}
	return theResult;
}

func lengthForRange(_ aRange: Range<UInt> ) -> UInt {
	return aRange.upperBound - aRange.lowerBound;
}

func lengthForRange(_ aRange: CountableClosedRange<UInt> ) -> UInt {
	return aRange.upperBound - aRange.lowerBound;
}

func greatestCommonDivisor(_ u: [Rational] ) -> Int {
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
			needsDisplay = true;
		}
	}

	override func reloadData() {
		updateOctaveRange();
		needsDisplay = true;
	}

	private func firstInterval() -> Interval? {
		if let theIndex = dataSource?.selectedIndecies.first {
			return dataSource?.interval(for: theIndex);
		} else {
			return nil;
		}
	}

	final private func updateOctaveRange() {
		var		theOctaveStart : UInt = 0;
		var		theOctaveEnd : UInt = 0;
		let		theCommonFactor = commonFactor;
		if let theFirst = firstInterval() {
			theOctaveStart = theCommonFactor > 1 ? HarmonicView.octaveForHarmonic(UInt(theCommonFactor)) : 0;
			if let theNum = theFirst.numeratorForDenominator(theCommonFactor) {
				theOctaveEnd = theNum > 0 ? HarmonicView.octaveForHarmonic(UInt(theNum)) : 0;
			}
			else {
				theOctaveEnd = theOctaveStart;
			}
			dataSource?.enumerateSelectedIntervals {
				(anIndex,aSelectedIndex,anInterval) in
				if let theNum = anInterval.numeratorForDenominator(theCommonFactor) {
					let		theNumeratorOctave = theNum > 0 ? HarmonicView.octaveForHarmonic(UInt(theNum)) : 0;
					if theNumeratorOctave > theOctaveEnd {
						theOctaveEnd = theNumeratorOctave;
					}
				}
			}
		}
		theOctaveEnd += 1;
		if showFundamental {
			octaveRange = 0...theOctaveEnd;
		}
		else {
			octaveRange = theOctaveStart...theOctaveEnd;
		}
	}

	final class func octaveForHarmonic( _ aHarmonic: UInt ) -> UInt {
		return log2(aHarmonic);
	}

	final func yValueForHarmonic( _ aHarmonic: UInt ) -> CGFloat { return yValueForHarmonic( aHarmonic, bounds: bounds ); }

	final private func yValueForHarmonic( _ aHarmonic: UInt, bounds aBounds: NSRect ) -> CGFloat {
		let		theOctave = HarmonicView.octaveForHarmonic(aHarmonic);
		let		theSubInterval = aHarmonic-(1<<HarmonicView.octaveForHarmonic(aHarmonic));
		let		theSubIntervalCount = 1<<HarmonicView.octaveForHarmonic(aHarmonic);

		let		theFractionPoint = CGFloat(theOctave - octaveRange.first!) + CGFloat(theSubInterval)/CGFloat(theSubIntervalCount);

		return theFractionPoint * NSHeight(aBounds)/CGFloat(lengthForRange(octaveRange)) + aBounds.minY;
	}
	override func draw(_ dirtyRect: NSRect) {
		let		theSelectedRationsCount = dataSource?.numberOfSelectedIntervals ?? 0;
		let		theHarmonicSpacing : CGFloat = max(20.0,CGFloat(10-theSelectedRationsCount)*5.0);
		var		theBounds = NSInsetRect(bounds, 20.0, 20.0);
		let		theXOrigin = max(theBounds.midX-CGFloat(max(0,theSelectedRationsCount))*theHarmonicSpacing*0.55-8.0,bounds.minX+20.0);
		theBounds.origin.y += 10.0;
        super.draw(dirtyRect)

		func drawOctave( _ anOctave: UInt ) {
			let		theSize = NSFont.systemFontSize(for: NSControl.ControlSize.regular)*1.25;
			let		theOctaveHeight = NSHeight(theBounds)/CGFloat(lengthForRange(octaveRange));
			let		theY = floor((CGFloat(anOctave-octaveRange.first!)+0.5) * theOctaveHeight+theBounds.minY);
			drawText(string: "\(anOctave+1)", size:theSize, point: NSMakePoint(theXOrigin-2.5, theY-theSize*0.55), color: majorAxisesTextColor);
			let		thePath = NSBezierPath();
			thePath.lineWidth = 0.5;
			thePath.move(to: NSMakePoint(theXOrigin+3.5, theY+theOctaveHeight/2.0-5.0));
			thePath.line(to: NSMakePoint(theXOrigin+3.5, theY+theSize*0.75));
			thePath.move(to: NSMakePoint(theXOrigin+3.5, theY-theSize*0.45));
			thePath.line(to: NSMakePoint(theXOrigin+3.5, theY-theOctaveHeight/2.0+5.0));
			axisesColor.setStroke();
			thePath.lineCapStyle = NSBezierPath.LineCapStyle.round
			thePath.stroke()
		}

		func drawHarmonic( _ aHarmonic: UInt ) {
			let		theSubInterval = aHarmonic-(1<<HarmonicView.octaveForHarmonic(aHarmonic));
			let		theY = yValueForHarmonic(aHarmonic, bounds: theBounds);
			let		thePath = NSBezierPath();
			if theSubInterval == 0 {
				thePath.lineWidth = 2.0;
				thePath.move(to: NSMakePoint(theXOrigin, floor(theY*2.0)*0.5+0.25));
				thePath.line(to: NSMakePoint(theXOrigin+28.0, floor(theY*2.0)*0.5+0.25));
				thePath.move(to: NSMakePoint(theXOrigin+38.0+6.5*CGFloat(log10(aHarmonic)), floor(theY*2.0)*0.5+0.25));
				thePath.line(to: NSMakePoint(theXOrigin+62.0, floor(theY*2.0)*0.5+0.25));
				majorAxisesColor.setStroke();
				drawText(string: "\(aHarmonic)", size:NSFont.systemFontSize(for: NSControl.ControlSize.small), point: NSMakePoint(theXOrigin+29.5, floor(theY*2.0)*0.5-7.5), color:majorAxisesTextColor );
			}
			else {
				thePath.move(to: NSMakePoint(theXOrigin+30.0, floor(theY*2.0)*0.5+0.25));
				thePath.lineWidth = 1.0;
				if (aHarmonic)%4 == 0 {
					thePath.line(to: NSMakePoint(theXOrigin+58.0, floor(theY*2.0)*0.5+0.25));
					majorAxisesColor.setStroke();
				}
				else if (aHarmonic)%2 == 0 {
					thePath.line(to: NSMakePoint(theXOrigin+54.0, floor(theY*2.0)*0.5+0.25));
					minorAxisesColor.setStroke();
				}
				else {
					thePath.line(to: NSMakePoint(theXOrigin+50.0, floor(theY*2.0)*0.5+0.25));
					secondaryMinorAxisesColor.setStroke();
				}
			}
			thePath.stroke()
		}

		func drawRatio( _ aRatio: Interval, index anIndex: Int, selectedIndex aSelectedIndex: Int, of anOf: Int ) {
			let		theYDenom = yValueForHarmonic( UInt(commonFactor), bounds: theBounds );
			let		theSize = NSFont.systemFontSize(for: NSControl.ControlSize.small);
			if aRatio == 1 {
				let		thePath = NSBezierPath();
				let		theX = theXOrigin+75.0+CGFloat(anOf)*theHarmonicSpacing;
				thePath.move(to: NSMakePoint(theXOrigin+65.0, theYDenom ));
				thePath.line(to: NSMakePoint(theX+5.0, theYDenom));
				colorForIndex(aSelectedIndex).setStroke();
				thePath.lineWidth = 4.0;
				thePath.stroke()
				drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX+5.0, theYDenom-8.5), color:colorForIndex(aSelectedIndex) );
			}
			else if let theNum = aRatio.numeratorForDenominator(commonFactor)
			{
				let		theYNum = yValueForHarmonic( UInt(theNum), bounds: theBounds );
				let		theYDelta = abs(theYNum-theYDenom);
				let		thePath = NSBezierPath();
				let		theX = theXOrigin+75.0+CGFloat(anIndex)*theHarmonicSpacing;

				thePath.move(to: NSMakePoint(theXOrigin+65.0, theYNum ));
				thePath.line(to: NSMakePoint(theX-10.0, theYNum));
				thePath.curve( to: NSMakePoint(theX, theYNum-theYDelta/2.0+6.0), controlPoint1: NSMakePoint(theX, theYNum), controlPoint2: NSMakePoint(theX, theYNum));
				thePath.move(to: NSMakePoint(theX, theYDenom+theYDelta/2.0-6.0));
				thePath.curve( to: NSMakePoint(theX-10.0, theYDenom), controlPoint1: NSMakePoint(theX, theYDenom), controlPoint2: NSMakePoint(theX, theYDenom));
				thePath.line(to: NSMakePoint(theXOrigin+65.0, theYDenom));
				colorForIndex(aSelectedIndex).setStroke();
				thePath.lineWidth = 4.0;
				thePath.stroke()
				drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX-7.0, theYDenom+theYDelta/2.0-8.5), color:colorForIndex(aSelectedIndex));
			}
		}

		for i in (1<<octaveRange.first!)...(1<<(octaveRange.last!)) {
			drawHarmonic(UInt(i));
		}
		for i in octaveRange {
			drawOctave( i );
		}
		dataSource?.enumerateSelectedIntervals { (anIndex, aSelectedIndex, anInterval) in
			drawRatio( anInterval, index:anIndex, selectedIndex:aSelectedIndex, of:theSelectedRationsCount );
		}
    }
}
