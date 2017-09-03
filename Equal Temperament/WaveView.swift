/*
    WaveView.swift
    Intonation

    Created by Nathan Day on 17/08/14.
    Copyright © 2014 Nathan Day. All rights reserved.
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

	override var		selectedRatios : [Interval] {
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

	override var intrinsicContentSize: NSSize {
		return NSMakeSize(CGFloat(2*commonFactor)*CGFloat(xScale), NSView.noIntrinsicMetric);
	}

	override func draw(_ aDirtyRect: NSRect) {
		var		theBounds = self.bounds;
		let		theHeight =  NSHeight(theBounds);
		let		theWidth =  NSWidth(theBounds);
		let		theZeroAxis = floor(NSMinY(theBounds)+theHeight*0.55)+0.25;
		let		theY0 = theBounds.minY-0.25;
		let		theY1 = theBounds.maxY+0.25;
		let		theX0 = theBounds.minX-0.25;
		let		theX1 = theBounds.maxX+0.25;
		let		theOutOffFocusAlpha : CGFloat = 0.5;

		func drawWave( _ aFreqs : [Double], lineWidth aLineWidth : CGFloat ) {
			let		thePath = NSBezierPath();
			let		theScalingFactor = pow(1.0/(Double(aFreqs.count)+1.0),0.8);
			thePath.lineWidth = aLineWidth;
			thePath.move(to: NSMakePoint(theX0, theZeroAxis));
			for theX in Int(NSMinX(aDirtyRect))...Int(NSMaxX(aDirtyRect)) {
				let		thePhase = Double(theX)/Double(theWidth);
				var		theValue = 0.0;
				for theFreq in aFreqs {
					theValue += sin(theFreq*thePhase*2*Double.pi*Double(commonFactor));
				}
				thePath.line(to: NSMakePoint(theX0+CGFloat(theX), theZeroAxis+CGFloat(theValue*theScalingFactor)*theHeight*0.6));
			}
			thePath.stroke();
		}

		func drawAxises() {
			let		thePath = NSBezierPath();
			thePath.lineWidth = 1.0;
			thePath.move(to: NSMakePoint(theX0,theZeroAxis));
			thePath.line(to: NSMakePoint(theX1,theZeroAxis));

			for i in 1..<8*commonFactor {
				let		theInterval = CGFloat(i)/(8.0*CGFloat(commonFactor));
				let		theX = theX0+floor(theWidth*CGFloat(theInterval))+0.5;
				if i%8 == 0 {
					thePath.move(to: NSMakePoint(theX,theY0));
					thePath.line(to: NSMakePoint(theX,theY1));
				}
				else {
					let		theLen : CGFloat = i%4 == 0 ? 8.0 : (i%2 == 0 ? 4.0 : 2.0);
					thePath.move(to: NSMakePoint(theX, theZeroAxis-theLen));
					thePath.line(to: NSMakePoint(theX, theZeroAxis+theLen));
				}
				if i%8 == 4 {
					drawText(string: "\(i/8 + 1)", size: NSFont.systemFontSize(for: NSControl.ControlSize.regular)*1.25, point: NSMakePoint(theX-6.0,20.0), color:NSColor.darkGray, textAlignment:.center );
				}
			}
			axisesColor.setStroke();
			thePath.stroke();
		}
        if( selectedRatios.count > 0 ) {
            switch displayMode {
            case .combined:
                for (theIndex,theRatio) in selectedRatios.enumerated() {
                    NSColor(calibratedHue: (CGFloat(theIndex+4).truncatingRemainder(dividingBy: 1.0)/5.1-2.0/15.0).truncatingRemainder(dividingBy: 1.0), saturation: 0.5, brightness: 0.75, alpha: theOutOffFocusAlpha).setStroke();
                    drawWave( [theRatio.toDouble], lineWidth:1.0 );
                }
                NSColor(calibratedWhite: 0.0, alpha: 1.0).setStroke();
                drawWave( selectedRatios.map({$0.toDouble;}), lineWidth:2.0 );
            case .overlayed:
                NSColor(calibratedWhite: 0.5, alpha: theOutOffFocusAlpha).setStroke();
                drawWave( selectedRatios.map({$0.toDouble;}), lineWidth:1.5 );
                for (theIndex,theRatio) in selectedRatios.enumerated() {
                    let		theHue = hueForIndex(theIndex);
                    NSColor(calibratedHue: theHue, saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
                    drawWave( [theRatio.toDouble], lineWidth:2.0 );
                }
            }
        }
		drawAxises();
    }

}
