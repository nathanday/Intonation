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
	case saw
	case square
};

class SpectrumView: ResultView {
	var		spectrumType : SpectrumType = .saw {
		didSet {
			invalidateIntrinsicContentSize();
			setNeedsDisplay();
		}
	}

	override var		selectedRatios : [Rational] {
		didSet {
			setNeedsDisplay();
		}
	}
	
	var		harmonicSpacing : CGFloat {
		get {
			var		theResult : CGFloat = 100.0;
			if spectrumType == .sine {
				if let theContentView = self.enclosingScrollView?.contentView {
					theResult = NSHeight(theContentView.documentVisibleRect)-theContentView.contentInsets.top-theContentView.contentInsets.bottom - 20.0;
				}
			}
			
			return theResult;
		}
	}

	override var intrinsicContentSize: NSSize { get { return NSMakeSize(NSViewNoInstrinsicMetric, spectrumType == .sine ? harmonicSpacing+20.0 : 1200.0); } }

	override func drawRect(aDirtyRect: NSRect) {
		var		theBounds = NSInsetRect(self.bounds, 30.0, 0.0);
		let		theBaseWidthHalf : CGFloat = 6.0;
		let		theTopWidthHalf : CGFloat = 2.0;
		theBounds.origin.x += 10.0;
		super.drawRect(aDirtyRect);

		func drawSpectrum( baseFreq aBaseFreq: Double, harmonic aHarmonic: Int ) {
			let		theHarmonicSpacing = harmonicSpacing;
			var		thePath = NSBezierPath();
			let		theX0 = NSMinX(theBounds);
			let		theMaxHarm = spectrumType == .sine ? 1 : 1000;
			let		theHarmStep = spectrumType == .square ? 2 : 1;
			thePath.lineWidth = 1.0;
			for var i = 1; i <= theMaxHarm; i += theHarmStep {
				let		theY = NSMinY(theBounds)+theBaseWidthHalf+theHarmonicSpacing*CGFloat(aBaseFreq)*CGFloat(i)-theHarmonicSpacing;
				let		theWidth = NSWidth(theBounds)/CGFloat(i);

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
				if theY > NSMaxY(aDirtyRect) { break; }
				
			}
			NSColor(calibratedHue: hueForIndex(aHarmonic), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
			NSColor(calibratedHue: hueForIndex(aHarmonic), saturation: 0.5, brightness: 0.875, alpha: 0.25).setFill();
			thePath.fill();
			thePath.stroke();
			thePath.moveToPoint(NSMakePoint(theX0, NSMinY(aDirtyRect)));
			thePath.lineToPoint(NSMakePoint(theX0, NSMaxY(aDirtyRect)));
			NSColor(calibratedWhite: 0.25, alpha: 1.0).setStroke();
			thePath.lineWidth = 1.0;
			thePath.stroke();
		}

		func drawAxises() {
			let		theHarmonicSpacing = harmonicSpacing;
			var		theTicks = NSBezierPath();
			var		theMinorTicks = NSBezierPath();
			var		theOverPath = NSBezierPath();
			let		theX0 = NSMinX(theBounds)-10.0;
			let		theMaxHarm = spectrumType == .sine ? 1 : 1000;
			let		theHarmStep = spectrumType == .square ? 2 : 1;
			for var i = 1; i <= theMaxHarm; i += theHarmStep {
				let		theY = NSMinY(theBounds)+theBaseWidthHalf+theHarmonicSpacing*CGFloat(i)-theHarmonicSpacing;
				let		theFontSize = NSFont.systemFontSizeForControlSize(NSControlSize.SmallControlSize);
				theTicks.moveToPoint(NSMakePoint(theX0+10.0, theY));
				theTicks.lineToPoint(NSMakePoint(theX0+5.0, theY));
				theMinorTicks.moveToPoint(NSMakePoint(theX0+10.0, theY+theHarmonicSpacing*0.25));
				theMinorTicks.lineToPoint(NSMakePoint(theX0+7.5, theY+theHarmonicSpacing*0.25));
				theMinorTicks.moveToPoint(NSMakePoint(theX0+10.0, theY+theHarmonicSpacing*0.5));
				theMinorTicks.lineToPoint(NSMakePoint(theX0+5.0, theY+theHarmonicSpacing*0.5));
				theMinorTicks.moveToPoint(NSMakePoint(theX0+10.0, theY+theHarmonicSpacing*0.75));
				theMinorTicks.lineToPoint(NSMakePoint(theX0+7.5, theY+theHarmonicSpacing*0.75));
				theOverPath.moveToPoint(NSMakePoint(theX0, theY));
				theOverPath.lineToPoint(NSMakePoint(theX0+NSWidth(theBounds), theY));
				drawText(string: "\(i)", size: theFontSize, point: NSMakePoint(theX0, theY-theFontSize*0.875), color: NSColor(calibratedWhite: 0.5, alpha: 1.0), textAlignment: .RightTextAlignment);
			}
			NSColor(calibratedWhite: 0.25, alpha: 1.0).setStroke();
			theTicks.lineWidth = 1.0;
			theTicks.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
			theTicks.stroke();

			NSColor(calibratedWhite: 0.0, alpha: 0.5).setStroke();
			theOverPath.lineWidth = 0.25;
			theOverPath.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
			theOverPath.stroke();

			NSColor(calibratedWhite: 0.25, alpha: 1.0).setStroke();
			theMinorTicks.lineWidth = 0.5;
			theMinorTicks.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
			theMinorTicks.stroke();
		}
	
		for i in 0..<selectedRatios.count {
			drawSpectrum( baseFreq: selectedRatios[i].toDouble, harmonic:i );
		}
		drawAxises();
	}
}
