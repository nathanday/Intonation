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

	override var	selectedRatios : [Rational] {
		didSet(aValue) {
			setNeedsDisplay();
		}
	}

	override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
		
		let		theBounds = NSInsetRect(self.bounds, 20.0, 20.0);
		let		theHeight =  NSHeight(theBounds);
		let		theWidth =  NSWidth(theBounds);
		let		theZeroAxis = floor(NSMinX(theBounds)+theWidth*0.6)+0.25;
		let		theY0 = NSMinY(theBounds)-0.25;
		let		theY1 = NSMaxY(theBounds)+0.25;
		let		theX0 = NSMinX(theBounds)-0.25;
		let		theX1 = NSMaxX(theBounds)+0.25;

		func drawWave( aFreqs : [Double], index anIndex: Int ) {
			var		thePath = NSBezierPath();
			var		theScalingFactor = pow(1.0/(Double(aFreqs.count)+1.0),0.8);
			thePath.lineWidth = 1.0;
			thePath.moveToPoint(NSMakePoint(theZeroAxis, theY0));
			for theY in 0...Int(theHeight) {
				let		thePhase = Double(theY)/Double(theHeight);
				var		theValue = 0.0;
				for theFreq in aFreqs {
					theValue += sin(theFreq*thePhase*2*M_PI*Double(commonFactor));
				}
				thePath.lineToPoint(NSMakePoint(theZeroAxis+CGFloat(theValue*theScalingFactor)*theWidth*0.3333, theY0+CGFloat(theY)));
			}
			NSColor(calibratedHue: CGFloat(anIndex+2)*1.0/3.1, saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
			thePath.stroke();
		}

		func drawAxises() {
			var		thePath = NSBezierPath();
			thePath.lineWidth = 1.0;
			thePath.moveToPoint(NSMakePoint(theX0, theY0));
			thePath.lineToPoint(NSMakePoint(theX1, theY0));
			thePath.moveToPoint(NSMakePoint(theZeroAxis, theY0));
			thePath.lineToPoint(NSMakePoint(theZeroAxis, theY1));
			thePath.moveToPoint(NSMakePoint(theX0, theY1));
			thePath.lineToPoint(NSMakePoint(theX1, theY1));
			
			for i in 1..<8*commonFactor {
				let		theInterval = CGFloat(i)/(8.0*CGFloat(commonFactor));
				if i%8 == 0 {
					thePath.moveToPoint(NSMakePoint(theX0, theY0+floor(theHeight*CGFloat(theInterval))+0.5));
					thePath.lineToPoint(NSMakePoint(theX1, theY0+floor(theHeight*CGFloat(theInterval))+0.5));
				}
				else {
					let		theLen : CGFloat = i%4 == 0 ? 5.0 : (i%2 == 0 ? 4.0 : 2.0);
					thePath.moveToPoint(NSMakePoint(theZeroAxis-theLen, theY0+floor(theHeight*CGFloat(theInterval))+0.5));
					thePath.lineToPoint(NSMakePoint(theZeroAxis+theLen, theY0+floor(theHeight*CGFloat(theInterval))+0.5));
				}
			}
			NSColor.darkGrayColor().setStroke();
			thePath.stroke();
		}

		switch displayMode {
		case .combined:
			drawWave( selectedRatios.map({$0.toDouble;}), index:0);
		case .overlayed:
			for i in 0..<selectedRatios.count {
				drawWave( [selectedRatios[i].toDouble], index:i);
			}
		}
		drawAxises();
    }
    
}
