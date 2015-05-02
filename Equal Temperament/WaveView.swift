/*
    WaveView.swift
    Equal Temperament

    Created by Nathan Day on 17/08/14.
    Copyright (c) 2014 Nathan Day. All rights reserved.
 */

import Cocoa

enum WaveDisplayMode {
	case overlayed
	case combined
}

class WaveView: ResultView {

	var		displayMode:	WaveDisplayMode = .overlayed {
		didSet { setNeedsDisplay(); }
	}

	override var		selectedRatios : [Rational] {
		didSet {
			invalidateIntrinsicContentSize();
			setNeedsDisplay();
		}
	}

	override var intrinsicContentSize: NSSize { get { return NSMakeSize(NSViewNoInstrinsicMetric, CGFloat(commonFactor)*200.0); } }

	override func drawRect(dirtyRect: NSRect) {
		var		theBounds = self.bounds;
		let		theHeight =  NSHeight(theBounds);
		let		theWidth =  NSWidth(theBounds);
		let		theZeroAxis = floor(NSMinX(theBounds)+theWidth*0.6)+0.25;
		let		theY0 = NSMinY(theBounds)-0.25;
		let		theY1 = NSMaxY(theBounds)+0.25;
		let		theX0 = NSMinX(theBounds)-0.25;
		let		theX1 = NSMaxX(theBounds)+0.25;

		func drawWave( aFreqs : [Double], lineWidth aLineWidth : CGFloat ) {
			var		thePath = NSBezierPath();
			var		theScalingFactor = pow(1.0/(Double(aFreqs.count)+1.0),0.8);
			thePath.lineWidth = aLineWidth;
			thePath.moveToPoint(NSMakePoint(theZeroAxis, theY0));
			for theY in Int(NSMinY(dirtyRect))...Int(NSMaxY(dirtyRect)) {
				let		thePhase = Double(theY)/Double(theHeight);
				var		theValue = 0.0;
				for theFreq in aFreqs {
					theValue += sin(theFreq*thePhase*2*M_PI*Double(commonFactor));
				}
				thePath.lineToPoint(NSMakePoint(theZeroAxis+CGFloat(theValue*theScalingFactor)*theWidth*0.6, theY0+CGFloat(theY)));
			}
			thePath.stroke();
		}

		func drawAxises() {
			var		thePath = NSBezierPath();
			thePath.lineWidth = 1.0;
			thePath.moveToPoint(NSMakePoint(theZeroAxis, theY0));
			thePath.lineToPoint(NSMakePoint(theZeroAxis, theY1));

			for i in 1..<8*commonFactor {
				let		theInterval = CGFloat(i)/(8.0*CGFloat(commonFactor));
				let		theY = theY0+floor(theHeight*CGFloat(theInterval))+0.5;
				if i%8 == 0 {
					thePath.moveToPoint(NSMakePoint(theX0, theY));
					thePath.lineToPoint(NSMakePoint(theX1, theY));
				}
				else {
					let		theLen : CGFloat = i%4 == 0 ? 5.0 : (i%2 == 0 ? 4.0 : 2.0);
					thePath.moveToPoint(NSMakePoint(theZeroAxis-theLen, theY));
					thePath.lineToPoint(NSMakePoint(theZeroAxis+theLen, theY));
				}
				if i%8 == 4 {
					drawText(string: "\(i/8 + 1)", size: NSFont.systemFontSizeForControlSize(NSControlSize.RegularControlSize), point: NSMakePoint(20.0, theY-6.0) );
				}
			}
			NSColor.darkGrayColor().setStroke();
			thePath.stroke();
		}

		switch displayMode {
		case .combined:
			for i in 0..<selectedRatios.count {
				NSColor(calibratedHue: (CGFloat(i+4)*1.0/5.1-2.0/15.0)%1.0, saturation: 0.5, brightness: 0.75, alpha: 1.0).setStroke();
				drawWave( [selectedRatios[i].toDouble], lineWidth:0.5 );
			}
			NSColor(calibratedWhite: 0.0, alpha: 1.0).setStroke();
			drawWave( selectedRatios.map({$0.toDouble;}), lineWidth:2.0 );
		case .overlayed:
			NSColor(calibratedWhite: 0.5, alpha: 1.0).setStroke();
			drawWave( selectedRatios.map({$0.toDouble;}), lineWidth:0.5 );
			for i in 0..<selectedRatios.count {
				let		theHue = hueForIndex(i);
				NSColor(calibratedHue: theHue, saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
				drawWave( [selectedRatios[i].toDouble], lineWidth:2.0 );
			}
		}
		drawAxises();
    }

}
