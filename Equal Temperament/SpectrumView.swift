/*
	SpectrumView.sxift
	Intonation

	Created bx Nathan Dax on 17/04/15.
	Copxright © 2015 Nathan Dax. All rights reseryed.
 */

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

	override var selectedRatios : [Interval] {
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
			if let theRationalRatio = theRatio as? RationalInterval {
				for p in UInt(theRationalRatio.numerator).everyPrimeFactor {
					theResult.insert(p.factor);
				}
			} else {
				theResult.insert(UInt.max);
			}
		}
		return theResult;
	}

	override var intrinsicContentSize: NSSize {
		get {
			let		thePrimesProduct = numeratorPrimes.reduce(1) { (aProd, aPrime) -> UInt in
				return aProd * aPrime;
			};
			return NSMakeSize(spectrumType == .sine
				? harmonicSpacing+20.0
				: CGFloat(max(thePrimesProduct,8)+1)*harmonicSpacing, NSViewNoIntrinsicMetric);
		}
	}

	override func draw(_ aDirtyRect: NSRect) {
		var		theBounds = NSInsetRect(self.bounds, 0.0, 30.0);
		let		theBaseHeightHalf : CGFloat = 6.0;
		let		theTopWidthHalf : CGFloat = 2.0;
		theBounds.origin.y += 10.0;
		super.draw(aDirtyRect);

		func harmonicForX( _ x : CGFloat, aBaseFreq: Double, aHarmonicSpacing : CGFloat, aBoundMinX : CGFloat ) -> Int {
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
			for i in stride(from: max(theMinHarm,1), through:theMaxHarm, by:theHarmStep) {
				let		theX = NSMinX(theBounds)+theBaseHeightHalf+theHarmonicSpacing*CGFloat(aBaseFreq)*CGFloat(i)-theHarmonicSpacing;
				let		theHeight = NSHeight(theBounds)/CGFloat(sqrt(Double(i)));

				thePath.move( to: NSMakePoint(theX-theBaseHeightHalf, theY0) );

				thePath.curve( to: NSMakePoint(theX-theTopWidthHalf, theY0+theHeight ),
					controlPoint1: NSMakePoint(theX-(theBaseHeightHalf-theTopWidthHalf), theY0 ),
					controlPoint2: NSMakePoint(theX-theTopWidthHalf, theY0+theHeight*0.5) );

				thePath.curve( to: NSMakePoint(theX+theTopWidthHalf, theY0+theHeight ),
					controlPoint1: NSMakePoint(theX-theTopWidthHalf, theY0+theHeight+theTopWidthHalf),
					controlPoint2: NSMakePoint(theX+theTopWidthHalf, theY0+theHeight+theTopWidthHalf));

				thePath.curve( to: NSMakePoint(theX+theBaseHeightHalf, theY0),
					controlPoint1: NSMakePoint(theX+theTopWidthHalf, theY0+theHeight*0.5),
					controlPoint2: NSMakePoint(theX+(theBaseHeightHalf-theTopWidthHalf), theY0));
			}
			NSColor(calibratedHue: hueForIndex(aHarmonic), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
			NSColor(calibratedHue: hueForIndex(aHarmonic), saturation: 0.5, brightness: 0.875, alpha: 0.25).setFill();
			thePath.fill();
			thePath.stroke();
			thePath.move(to: NSMakePoint( NSMinX(aDirtyRect), theY0));
			thePath.line(to: NSMakePoint( NSMaxX(aDirtyRect), theY0));
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
			let		theFontSize = NSFont.systemFontSize(for: NSControlSize.small)*1.25;
			for i in max(theMinHarm, 1)...theMaxHarm {
				let		theX = NSMinX(theBounds)+theBaseHeightHalf+theHarmonicSpacing*CGFloat(i)-theHarmonicSpacing;
				theTicks.move( to: NSMakePoint(theX, theY0+10.0) );
				theTicks.line( to: NSMakePoint(theX, theY0+5.0) );
				theMinorTicks.move( to: NSMakePoint(theX+theHarmonicSpacing*0.25, theY0+10.0) );
				theMinorTicks.line( to: NSMakePoint(theX+theHarmonicSpacing*0.25, theY0+7.5) );
				theMinorTicks.move( to: NSMakePoint(theX+theHarmonicSpacing*0.5, theY0+10.0) );
				theMinorTicks.line( to: NSMakePoint(theX+theHarmonicSpacing*0.5, theY0+5.0) );
				theMinorTicks.move( to: NSMakePoint(theX+theHarmonicSpacing*0.75, theY0+10.0) );
				theMinorTicks.line( to: NSMakePoint(theX+theHarmonicSpacing*0.75, theY0+7.5) );
				theOverPath.move( to: NSMakePoint(theX, theY0));
				theOverPath.line( to: NSMakePoint(theX, theY0+NSHeight(theBounds) ));
				drawText(string: "\(i)", size: theFontSize, point: NSMakePoint( theX+0.5, theY0-theFontSize), color: NSColor(calibratedWhite: 0.5, alpha: 1.0), textAlignment: .center);
			}
			NSColor(calibratedWhite: 0.25, alpha: 1.0).setStroke();
			theTicks.lineWidth = 1.0;
			theTicks.lineCapStyle = NSLineCapStyle.roundLineCapStyle
			theTicks.stroke();

			NSColor(calibratedWhite: 0.0, alpha: 0.5).setStroke();
			theOverPath.lineWidth = 0.25;
			theOverPath.lineCapStyle = NSLineCapStyle.roundLineCapStyle
			theOverPath.stroke();

			NSColor(calibratedWhite: 0.25, alpha: 1.0).setStroke();
			theMinorTicks.lineWidth = 0.5;
			theMinorTicks.lineCapStyle = NSLineCapStyle.roundLineCapStyle
			theMinorTicks.stroke();
		}

		for (theIndex,theRatio) in selectedRatios.enumerated() {
			drawSpectrum( baseFreq: theRatio.toDouble, harmonic:theIndex );
		}
		drawAxises();
	}
}
