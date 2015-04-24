//
//  SpectrumView.swift
//  Equal Temperament
//
//  Created by Nathan Day on 17/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

enum SpectrumType {
	case sine
	case triange
	case square
};

class SpectrumView: ResultView {
	var		spectrumType : SpectrumType = .triange;

	override var		selectedRatios : [Rational] {
		didSet {
			setNeedsDisplay();
		}
	}

	override func drawRect(aDirtyRect: NSRect) {
		var		theBounds = NSInsetRect(self.bounds, 30.0, 0.0);
		theBounds.origin.x += 10.0;
		super.drawRect(aDirtyRect);

		func drawSpectrum( baseFreq aBaseFreq: Double, harmonic aHarmonic: Int ) {
			var		thePath = NSBezierPath();
			let		theX0 = NSMinX(theBounds);	// 40.5
			let		theY0 = NSMinY(theBounds)+CGFloat(aBaseFreq)*100.0-100.0;
			let		theBaseWidthHalf : CGFloat = 8.0;
			let		theTopWidthHalf : CGFloat = 2.0;
			var		theIndex = 1;
			thePath.lineWidth = 1.0;
			for var theY = theY0+theBaseWidthHalf; theY < NSMaxY(theBounds); theY += 100.0*CGFloat(aBaseFreq) {
				let		theWidth = NSWidth(theBounds)/CGFloat(theIndex++);

				thePath.moveToPoint(NSMakePoint(theX0, theY-theBaseWidthHalf));
				
				thePath.curveToPoint(NSMakePoint(theX0+theWidth, theY-theTopWidthHalf),
					controlPoint1: NSMakePoint(theX0, theY-(theBaseWidthHalf-theTopWidthHalf)),
					controlPoint2: NSMakePoint(theX0+theWidth*0.5, theY-theTopWidthHalf));

				thePath.curveToPoint(NSMakePoint(theX0+theWidth, theY+theTopWidthHalf),
					controlPoint1: NSMakePoint(theX0+theWidth+theTopWidthHalf, theY-theTopWidthHalf),
					controlPoint2: NSMakePoint(theX0+theWidth+theTopWidthHalf, theY+theTopWidthHalf));
	
				thePath.curveToPoint(NSMakePoint(theX0, theY+theBaseWidthHalf),
					controlPoint1: NSMakePoint(theX0+theWidth*0.5, theY+theTopWidthHalf),
					controlPoint2: NSMakePoint(theX0, theY+(theBaseWidthHalf-theTopWidthHalf)));
				
			}
			NSColor(calibratedHue: hueForIndex(aHarmonic), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
			NSColor(calibratedHue: hueForIndex(aHarmonic), saturation: 0.5, brightness: 0.875, alpha: 0.25).setFill();
			thePath.fill();
			thePath.stroke();
			thePath.moveToPoint(NSMakePoint(theX0, NSMinY(aDirtyRect)));
			thePath.lineToPoint(NSMakePoint(theX0, NSMaxY(aDirtyRect)));
			NSColor(calibratedWhite: 0.5, alpha: 1.0).setStroke();
			thePath.lineWidth = 0.5;
			thePath.stroke();
		}
	
		for i in 0..<selectedRatios.count {
			drawSpectrum( baseFreq: selectedRatios[i].toDouble, harmonic:i );
		}
	}
}
