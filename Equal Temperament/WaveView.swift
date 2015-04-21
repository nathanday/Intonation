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

class BackGround : ResultView {
	@IBOutlet var		childView : NSView?
	override func drawRect(dirtyRect: NSRect) {
		super.drawRect(dirtyRect);
		var		thePath = NSBezierPath();
		assert( childView != nil );
		if let theSubView : NSView = childView {
			let		theFrame = theSubView.frame;
			thePath.lineWidth = 1.0;
			thePath.moveToPoint(NSMakePoint(NSMinX(theFrame), NSMinY(theFrame)-1.0));
			thePath.lineToPoint(NSMakePoint(NSMaxX(theFrame), NSMinY(theFrame)-1.0));
			thePath.moveToPoint(NSMakePoint(NSMinX(theFrame), NSMaxY(theFrame)+1.0));
			thePath.lineToPoint(NSMakePoint(NSMaxX(theFrame), NSMaxY(theFrame)+1.0));
			NSColor.darkGrayColor().setStroke();
			thePath.stroke();
		}
	}
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
				thePath.lineToPoint(NSMakePoint(theZeroAxis+CGFloat(theValue*theScalingFactor)*theWidth*0.3333, theY0+CGFloat(theY)));
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
			NSColor(calibratedWhite: 0.5, alpha: 1.0).setStroke();
			for i in 0..<selectedRatios.count {
				drawWave( [selectedRatios[i].toDouble], lineWidth:0.5 );
			}
			NSColor(calibratedRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).setStroke();
			drawWave( selectedRatios.map({$0.toDouble;}), lineWidth:2.0 );
		case .overlayed:
			NSColor(calibratedWhite: 0.5, alpha: 1.0).setStroke();
			drawWave( selectedRatios.map({$0.toDouble;}), lineWidth:0.5 );
			for i in 0..<selectedRatios.count {
				NSColor(calibratedHue: (CGFloat(i+4)*1.0/5.1-2.0/15.0)%1.0, saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
				drawWave( [selectedRatios[i].toDouble], lineWidth:2.0 );
			}
		}
		drawAxises();
    }
    
}
