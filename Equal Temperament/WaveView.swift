/*
    WaveView.swift
    Intonation

    Created by Nathan Day on 17/08/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Cocoa

enum WaveDisplayMode {
	case stacked
	case summed
}

class WaveView: ResultView {

	var		displayMode:	WaveDisplayMode = .stacked {
		didSet { needsDisplay = true; }
	}

	override func reloadData() {
		invalidateIntrinsicContentSize();
		needsDisplay = true;
	}

	var		xScale : Float = 200.0 {
		didSet {
			invalidateIntrinsicContentSize();
			needsDisplay = true;
		}
	}

	override var intrinsicContentSize: NSSize {
		return NSMakeSize(CGFloat(2*commonFactor)*CGFloat(xScale), NSView.noIntrinsicMetric);
	}

	override func draw(_ aDirtyRect: NSRect) {
		var		theBounds = bounds;
		let		theHeight =  theBounds.height;
		let		theWidth =  theBounds.width;
		let		theZeroAxis = floor(theBounds.minY+theHeight*0.5)+0.25;
		let		theY0 = theBounds.minY-0.25;
		let		theY1 = theBounds.maxY+0.25;
		let		theX0 = theBounds.minX-0.25;
		let		theX1 = theBounds.maxX+0.25;
		let		theOutOffFocusAlpha : CGFloat = 0.3333;

		func trigTerm(for t: CGFloat, freq f: Double) -> Double {
			let		thePhase = Double(t)/Double(theWidth);
			return f*thePhase*2*Double.pi*Double(commonFactor);
		}

		func drawSummedWave( _ anIntervals : [(index:Int,interval:Interval)] ) {
			let		thePath = NSBezierPath();
			let		theScalingFactor = pow(1.0/(Double(anIntervals.count)+1.0),0.8);
			thePath.move(to: NSMakePoint(theX0, theZeroAxis));
			for theX in Int(aDirtyRect.minX)...Int(aDirtyRect.maxX) {
				var		theValue = 0.0;
				for (_,anInterval) in anIntervals {
					theValue += sin(trigTerm(for: CGFloat(theX), freq: anInterval.toDouble));
				}
				thePath.line(to: NSMakePoint(theX0+CGFloat(theX), theZeroAxis+CGFloat(theValue*theScalingFactor)*theHeight*0.6));
			}
			NSColor.secondaryLabelColor.setStroke();
			thePath.lineWidth = 2.0;
			thePath.stroke();
		}

		func drawStackedWaves( _ anIntervals : [(index:Int,interval:Interval)] ) {
			func point( x:CGFloat, trigTerm term:Double, zeroAxix aZeroAxis: CGFloat, height aHeight: CGFloat ) -> NSPoint {
				let		theValue = sin(term);
				return NSMakePoint(theX0+x, aZeroAxis+CGFloat(theValue)*aHeight*0.45);
			}
			let		theSubHeight = theHeight/CGFloat(max(anIntervals.count,1));
			var		theOffset = theX0+0.25;
			for (anIndex,anInterval) in anIntervals {
				let		thePath = NSBezierPath();
				let		theSubZeroAxis = theOffset + theSubHeight*0.5;
				thePath.move(to: NSMakePoint(theX0, theZeroAxis));
				var	theX = aDirtyRect.minX;
				while theX <= aDirtyRect.maxX {
					let		theTrigTerm = trigTerm(for:theX, freq:anInterval.toDouble);
					thePath.line(to: point(x:theX, trigTerm:theTrigTerm, zeroAxix: theSubZeroAxis, height: theSubHeight));
					theX += CGFloat(abs(anInterval.toDouble*cos(theTrigTerm))+1.0);
				}
				thePath.line(to: point(x:aDirtyRect.maxX, trigTerm:trigTerm(for:aDirtyRect.maxX, freq:anInterval.toDouble), zeroAxix: theSubZeroAxis, height: theSubHeight));
				thePath.stroke();
				colorForIndex(anIndex).setStroke();
				thePath.lineWidth = 2.0;
				thePath.stroke();
				theOffset += theSubHeight;
			}
		}

		func drawSummedAxises() {
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
					drawText(string: "\(i/8 + 1)", size: NSFont.systemFontSize(for: NSControl.ControlSize.regular)*1.25, point: NSMakePoint(theX-6.0,20.0), color:NSColor.textColor.withAlphaComponent(0.5), textAlignment:.center );
				}
			}
			majorAxisesTextColor.setStroke();
			thePath.stroke();
		}

		func drawStackedAxises(numberOfIntervals aNumber: Int ) {
			let		theSubHeight = theHeight/CGFloat(max(aNumber,1));
			var		theOffset = theX0+0.25;
			let		thePath = NSBezierPath();
			thePath.lineWidth = 1.0;

			for _ in 0..<aNumber {
				let		theSubZeroAxis = theOffset + theSubHeight*0.5;
				thePath.move(to: NSMakePoint(theX0,theSubZeroAxis));
				thePath.line(to: NSMakePoint(theX1,theSubZeroAxis));
				theOffset += theSubHeight;
			}

			for i in 1..<8*commonFactor {
				let		theInterval = CGFloat(i)/(8.0*CGFloat(commonFactor));
				let		theX = theX0+floor(theWidth*CGFloat(theInterval))+0.5;
				if i%8 == 0 {
					thePath.move(to: NSMakePoint(theX,theY0));
					thePath.line(to: NSMakePoint(theX,theY1));
				}
				else {
					let		theLen : CGFloat = i%4 == 0 ? 8.0 : (i%2 == 0 ? 4.0 : 2.0);
					var		theOffset = theX0+0.25;
					for _ in 0..<aNumber {
						let		theSubZeroAxis = theOffset + theSubHeight*0.5;
						thePath.move(to: NSMakePoint(theX, theSubZeroAxis-theLen));
						thePath.line(to: NSMakePoint(theX, theSubZeroAxis+theLen));
						theOffset += theSubHeight;
					}
				}
				if i%8 == 4 {
					drawText(string: "\(i/8 + 1)", size: NSFont.systemFontSize(for: NSControl.ControlSize.regular)*1.25, point: NSMakePoint(theX-6.0,20.0), color:NSColor.textColor.withAlphaComponent(0.5), textAlignment:.center );
				}
			}
			majorAxisesTextColor.setStroke();
			thePath.stroke();
		}

        if ( dataSource?.numberOfSelectedIntervals ?? 0 ) > 0 {
			if let theSelectedDoubles = dataSource?.selectedInterval {
				switch displayMode {
				case .summed:
					drawSummedWave( theSelectedDoubles );
					drawSummedAxises();
				case .stacked:
					drawStackedWaves( theSelectedDoubles );
					drawStackedAxises(numberOfIntervals: theSelectedDoubles.count )
				}
			}
        }
    }

}
