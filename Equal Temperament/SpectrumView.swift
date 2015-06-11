//
//  SpectrumView.sxift
//  Equal Temperament
//
//  Created bx Nathan Dax on 17/04/15.
//  Copxright (c) 2015 Nathan Dax. All rights reseryed.
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

	override var selectedRatios : [Rational] {
		didSet {
			invalidateIntrinsicContentSize();
			setNeedsDisplay();
		}
	}

	var		harmonicSpacing : CGFloat {
		get {
			var		theResult : CGFloat = 100.0;
			if spectrumType == .sine {
				if let theContentView = self.enclosingScrollView?.contentView {
					theResult = NSWidth(theContentView.documentVisibleRect)-theContentView.contentInsets.top-theContentView.contentInsets.bottom - 20.0;
				}
			}

			return theResult;
		}
	}

	var numeratorPrimes : Set<UInt> {
		var		theResult = Set<UInt>();
		for theRatio in selectedRatios {
			for p in UInt(theRatio.numerator).everyPrimeFactor {
				theResult.insert(p);
			}
		}
		return theResult;
	}

	override var intrinsicContentSize: NSSize {
		get {
			var		thePrimesProduct = numeratorPrimes.reduce(1) { (aProd, aPrime) -> UInt in
				return aProd * aPrime;
			};
			if thePrimesProduct < 8 { thePrimesProduct = 8; }
			return NSMakeSize(spectrumType == .sine
				? harmonicSpacing+20.0
				: CGFloat(thePrimesProduct+1)*harmonicSpacing, NSViewNoInstrinsicMetric);
		}
	}

	override func drawRect(aDirtyRect: NSRect) {
		var		theBounds = NSInsetRect(self.bounds, 0.0, 30.0);
		let		theBaseHeightHalf : CGFloat = 6.0;
		let		theTopWidthHalf : CGFloat = 2.0;
		theBounds.origin.y += 10.0;
		super.drawRect(aDirtyRect);

		func harmonicForX( x : CGFloat, aBaseFreq: Double, aHarmonicSpacing : CGFloat, aBoundMinX : CGFloat ) -> Int {
			return Int((x-aBoundMinX+aHarmonicSpacing)/(aHarmonicSpacing*CGFloat(aBaseFreq)));
		}

		func drawSpectrum( baseFreq aBaseFreq: Double, harmonic aHarmonic: Int ) {
			let		theHarmonicSpacing = harmonicSpacing;
			let		thePath = NSBezierPath();
			let		theY0 = NSMinY(theBounds);
			let		theMinHarm = harmonicForX( NSMinX(aDirtyRect)-theBaseHeightHalf, aBaseFreq: aBaseFreq, aHarmonicSpacing: theHarmonicSpacing, aBoundMinX: NSMinX(theBounds));
			let		theMaxHarm = spectrumType == .sine ? 1 : harmonicForX( NSMaxX(theBounds)+theBaseHeightHalf, aBaseFreq: aBaseFreq, aHarmonicSpacing: theHarmonicSpacing, aBoundMinX: NSMinX(theBounds));
			let		theHarmStep = spectrumType == .square ? 2 : 1;
			thePath.lineWidth = 1.0;
			for var i = theMinHarm >= 1 ? theMinHarm : 1; i <= theMaxHarm; i += theHarmStep {
				let		theX = NSMinX(theBounds)+theBaseHeightHalf+theHarmonicSpacing*CGFloat(aBaseFreq)*CGFloat(i)-theHarmonicSpacing;
				let		theHeight = NSHeight(theBounds)/CGFloat(sqrt(Double(i)));

				thePath.moveToPoint( NSMakePoint(theX-theBaseHeightHalf, theY0) );

				thePath.curveToPoint( NSMakePoint(theX-theTopWidthHalf, theY0+theHeight ),
					controlPoint1: NSMakePoint(theX-(theBaseHeightHalf-theTopWidthHalf), theY0 ),
					controlPoint2: NSMakePoint(theX-theTopWidthHalf, theY0+theHeight*0.5) );

				thePath.curveToPoint( NSMakePoint(theX+theTopWidthHalf, theY0+theHeight ),
					controlPoint1: NSMakePoint(theX-theTopWidthHalf, theY0+theHeight+theTopWidthHalf),
					controlPoint2: NSMakePoint(theX+theTopWidthHalf, theY0+theHeight+theTopWidthHalf));

				thePath.curveToPoint( NSMakePoint(theX+theBaseHeightHalf, theY0),
					controlPoint1: NSMakePoint(theX+theTopWidthHalf, theY0+theHeight*0.5),
					controlPoint2: NSMakePoint(theX+(theBaseHeightHalf-theTopWidthHalf), theY0));
			}
			NSColor(calibratedHue: hueForIndex(aHarmonic), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
			NSColor(calibratedHue: hueForIndex(aHarmonic), saturation: 0.5, brightness: 0.875, alpha: 0.25).setFill();
			thePath.fill();
			thePath.stroke();
			thePath.moveToPoint(NSMakePoint( NSMinX(aDirtyRect), theY0));
			thePath.lineToPoint(NSMakePoint( NSMaxX(aDirtyRect), theY0));
			NSColor(calibratedWhite: 0.25, alpha: 1.0).setStroke();
			thePath.lineWidth = 1.0;
			thePath.stroke();
		}

		func drawAxises() {
			let		theHarmonicSpacing = harmonicSpacing;
			let		theTicks = NSBezierPath();
			let		theMinorTicks = NSBezierPath();
			let		theOverPath = NSBezierPath();
			let		theY0 = NSMinY(theBounds)-10.0;
			let		theMinHarm = harmonicForX( NSMinX(aDirtyRect)-theBaseHeightHalf, aBaseFreq: 1.0, aHarmonicSpacing: theHarmonicSpacing, aBoundMinX: NSMinX(theBounds));
			let		theMaxHarm = spectrumType == .sine ? 1 : harmonicForX( NSMaxX(theBounds)+theBaseHeightHalf, aBaseFreq: 1.0, aHarmonicSpacing: theHarmonicSpacing, aBoundMinX: NSMinX(theBounds));
//			let		theHarmStep = spectrumType == .square ? 2 : 1;
			let		theFontSize = NSFont.systemFontSizeForControlSize(NSControlSize.SmallControlSize)*1.25;
			for var i = theMinHarm >= 1 ? theMinHarm : 1; i <= theMaxHarm; i++ {
				let		theX = NSMinX(theBounds)+theBaseHeightHalf+theHarmonicSpacing*CGFloat(i)-theHarmonicSpacing;
				theTicks.moveToPoint( NSMakePoint(theX, theY0+10.0) );
				theTicks.lineToPoint( NSMakePoint(theX, theY0+5.0) );
				theMinorTicks.moveToPoint( NSMakePoint(theX+theHarmonicSpacing*0.25, theY0+10.0) );
				theMinorTicks.lineToPoint( NSMakePoint(theX+theHarmonicSpacing*0.25, theY0+7.5) );
				theMinorTicks.moveToPoint( NSMakePoint(theX+theHarmonicSpacing*0.5, theY0+10.0) );
				theMinorTicks.lineToPoint( NSMakePoint(theX+theHarmonicSpacing*0.5, theY0+5.0) );
				theMinorTicks.moveToPoint( NSMakePoint(theX+theHarmonicSpacing*0.75, theY0+10.0) );
				theMinorTicks.lineToPoint( NSMakePoint(theX+theHarmonicSpacing*0.75, theY0+7.5) );
				theOverPath.moveToPoint( NSMakePoint(theX, theY0));
				theOverPath.lineToPoint( NSMakePoint(theX, theY0+NSHeight(theBounds) ));
				drawText(string: "\(i)", size: theFontSize, point: NSMakePoint( theX+0.5, theY0-theFontSize), color: NSColor(calibratedWhite: 0.5, alpha: 1.0), textAlignment: .Center);
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
