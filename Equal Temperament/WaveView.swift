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
	
	var		xScale : Float = 200.0 {
		didSet {
			invalidateIntrinsicContentSize();
			setNeedsDisplay();
		}
	}

	override var intrinsicContentSize: NSSize { get { return NSMakeSize(CGFloat(2*commonFactor)*CGFloat(xScale), NSViewNoInstrinsicMetric); } }

	override func drawRect(dirtyRect: NSRect) {
		var		theBounds = self.bounds;
		let		theHeight =  NSHeight(theBounds);
		let		theWidth =  NSWidth(theBounds);
		let		theZeroAxis = floor(NSMinY(theBounds)+theHeight*0.55)+0.25;
		let		theY0 = NSMinY(theBounds)-0.25;
		let		theY1 = NSMaxY(theBounds)+0.25;
		let		theX0 = NSMinX(theBounds)-0.25;
		let		theX1 = NSMaxX(theBounds)+0.25;

		func drawWave( aFreqs : [Double], lineWidth aLineWidth : CGFloat ) {
			var		thePath = NSBezierPath();
			var		theScalingFactor = pow(1.0/(Double(aFreqs.count)+1.0),0.8);
			thePath.lineWidth = aLineWidth;
			thePath.moveToPoint(NSMakePoint(theX0, theZeroAxis));
			for theX in Int(NSMinX(dirtyRect))...Int(NSMaxX(dirtyRect)) {
				let		thePhase = Double(theX)/Double(theWidth);
				var		theValue = 0.0;
				for theFreq in aFreqs {
					theValue += sin(theFreq*thePhase*2*M_PI*Double(commonFactor));
				}
				thePath.lineToPoint(NSMakePoint(theX0+CGFloat(theX), theZeroAxis+CGFloat(theValue*theScalingFactor)*theHeight*0.6));
			}
			thePath.stroke();
		}

		func drawAxises() {
			var		thePath = NSBezierPath();
			thePath.lineWidth = 1.0;
			thePath.moveToPoint(NSMakePoint(theX0,theZeroAxis));
			thePath.lineToPoint(NSMakePoint(theX1,theZeroAxis));

			for i in 1..<8*commonFactor {
				let		theInterval = CGFloat(i)/(8.0*CGFloat(commonFactor));
				let		theX = theX0+floor(theWidth*CGFloat(theInterval))+0.5;
				if i%8 == 0 {
					thePath.moveToPoint(NSMakePoint(theX,theY0));
					thePath.lineToPoint(NSMakePoint(theX,theY1));
				}
				else {
					let		theLen : CGFloat = i%4 == 0 ? 5.0 : (i%2 == 0 ? 4.0 : 2.0);
					thePath.moveToPoint(NSMakePoint(theX, theZeroAxis-theLen));
					thePath.lineToPoint(NSMakePoint(theX, theZeroAxis+theLen));
				}
				if i%8 == 4 {
					drawText(string: "\(i/8 + 1)", size: NSFont.systemFontSizeForControlSize(NSControlSize.RegularControlSize)*1.25, point: NSMakePoint(theX-6.0,20.0), color:NSColor.darkGrayColor(), textAlignment:.CenterTextAlignment );
				}
			}
			NSColor.darkGrayColor().setStroke();
			thePath.stroke();
		}

		switch displayMode {
		case .combined:
			for i in 0..<selectedRatios.count {
				NSColor(calibratedHue: (CGFloat(i+4)*1.0/5.1-2.0/15.0)%1.0, saturation: 0.5, brightness: 0.75, alpha: 1.0).setStroke();
				drawWave( [selectedRatios[i].toDouble], lineWidth:1.0 );
			}
			NSColor(calibratedWhite: 0.0, alpha: 1.0).setStroke();
			drawWave( selectedRatios.map({$0.toDouble;}), lineWidth:3.0 );
		case .overlayed:
			NSColor(calibratedWhite: 0.5, alpha: 1.0).setStroke();
			drawWave( selectedRatios.map({$0.toDouble;}), lineWidth:1.5 );
			for i in 0..<selectedRatios.count {
				let		theHue = hueForIndex(i);
				NSColor(calibratedHue: theHue, saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
				drawWave( [selectedRatios[i].toDouble], lineWidth:2.0 );
			}
		}
		drawAxises();
    }

}
