//
//  ScaleView.swift
//  Equal Temperament
//
//  Created by Nathan Day on 5/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ScaleView : ResultView {
	static let		equalTempBarWidth : CGFloat = 20.0;
	static var		equalTempGradient: NSGradient? = NSGradient(startingColor: NSColor.lightGrayColor(), endingColor: NSColor(calibratedWhite:0.9, alpha:1.0));

	var		numberOfIntervals : UInt = 12 {
		didSet { setNeedsDisplay(); }
	}

	override func drawRect(dirtyRect: NSRect) {
		let		theBounds = NSInsetRect(self.bounds, 20.0, 20.0);
		var		thePreviousY : CGFloat = 0.0;
		func drawJustIntonationRatio( ratio aRatio : Rational, hilighted aHilighted : Bool ) {
			let		theX0 = floor(NSMidX(theBounds)+ScaleView.equalTempBarWidth/2.0)-20.5;
			let		theY = CGFloat(log2(aRatio.toDouble)) * NSHeight(theBounds) + NSMinX(theBounds);
			let		theCloseToPrevious = abs(theY-thePreviousY)<12.0;
			let		theX1 = theX0 + CGFloat(theCloseToPrevious ? 40.0 : 15.0);
			var		thePath = NSBezierPath()
			thePath.moveToPoint(NSMakePoint(theX1+4.5, theY))
			thePath.curveToPoint(NSMakePoint(theX1+2.5, theY+2.0), controlPoint1: NSMakePoint(theX1+4.5, theY+1.1), controlPoint2: NSMakePoint(theX1+3.6, theY+2.0))
			thePath.curveToPoint(NSMakePoint(theX1+0.5, theY), controlPoint1: NSMakePoint(theX1+1.4, theY+2.0), controlPoint2: NSMakePoint(theX1+0.5, theY+1.1))
			thePath.curveToPoint(NSMakePoint(theX1+2.5, theY-2.0), controlPoint1: NSMakePoint(theX1+0.5, theY-1.1), controlPoint2: NSMakePoint(theX1+1.4, theY-2.0))
			thePath.curveToPoint(NSMakePoint(theX1+4.5, theY), controlPoint1: NSMakePoint(theX1+3.6, theY-2.0), controlPoint2: NSMakePoint(theX1+4.5, theY-1.1))
			thePath.closePath()
			thePath.moveToPoint(NSMakePoint(theX1, theY))
			thePath.lineToPoint(NSMakePoint(theX0-ScaleView.equalTempBarWidth, theY))
			thePath.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
			if aHilighted {
				NSColor.blueColor().setFill()
				NSColor.blueColor().setStroke();
				thePath.fill()
			} else {
				NSColor(white: 0.0, alpha:0.5).setStroke();
			}
			thePath.lineWidth = aHilighted ? 1.0 : 0.5;
			thePath.stroke()

			let		theSize = NSFont.systemFontSizeForControlSize(NSControlSize.MiniControlSize);
			let		theTextColor = aHilighted ? NSColor.blueColor() : NSColor(white: 0.0, alpha: 0.5);
			drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX1+10.0, theY-theSize*0.85), color:theTextColor );

			thePreviousY = theCloseToPrevious ? 0.0 : theY;
		}

		func drawEqualTemperamentRatio( rationNumber aRatioNumber : UInt ) {
			let		theHeights = NSHeight(theBounds)/CGFloat(numberOfIntervals);
			let		theX = floor(NSMidX(theBounds)-ScaleView.equalTempBarWidth/2.0)-20.5;
			let		theY = CGFloat(aRatioNumber)*theHeights+20.0;
			ScaleView.equalTempGradient!.drawInBezierPath(NSBezierPath(rect: NSMakeRect(theX, theY, ScaleView.equalTempBarWidth, theHeights)), angle: -90)
		}

		super.drawRect(dirtyRect);
		for i in 0..<numberOfIntervals { drawEqualTemperamentRatio( rationNumber: i ); }
		for aRatio in everyRatios {
			drawJustIntonationRatio(ratio: aRatio, hilighted: contains(selectedRatios, aRatio) );
		}
	}
}
