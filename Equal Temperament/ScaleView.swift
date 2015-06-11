//
//  ScaleView.swift
//  Equal Temperament
//
//  Created by Nathan Day on 5/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ScaleView : ResultView {
	static let		equalTempGradient: NSGradient? = NSGradient(startingColor: NSColor.lightGrayColor(), endingColor: NSColor(calibratedWhite:0.9, alpha:1.0));
	let		equalTempBarWidth : CGFloat = 20.0;
	
	var		numberOfIntervals : UInt = 12 {
		didSet { setNeedsDisplay(); }
	}
	var		useIntervals : Bool = true {
		didSet { setNeedsDisplay(); }
	}
	
	func drawJustIntonationRatio( ratio aRatio : Rational, hilighted aHilighted : Bool, index anIndex: Int, previousValue aPreviousY : CGFloat ) -> CGFloat {
		return 0.0;
	}
	
	func drawEqualTemperamentRatio( rationNumber aRatioNumber : UInt ) {
	}
	func drawNoEqualTemperament( ) { }
	
	override func drawRect(aDirtyRect: NSRect) {
		var		thePreviousValue : CGFloat = 0.0;
		
		if useIntervals {
			for i in 0..<numberOfIntervals { drawEqualTemperamentRatio( rationNumber: i ); }
		}
		else {
			drawNoEqualTemperament();
		}
		for i in 0..<everyRatios.count {
			thePreviousValue = drawJustIntonationRatio(ratio: everyRatios[i], hilighted: selectedRatios.contains(everyRatios[i]), index:i, previousValue: thePreviousValue );
		}
	}
}

class LinearScaleView : ScaleView {
	private var		drawingBounds : NSRect {
		get {
			var		theResult = NSInsetRect(self.bounds, 0.0, 5.0);
			theResult.origin.x += 5.0;
			return theResult;
		}
	}
	override func drawJustIntonationRatio( ratio aRatio : Rational, hilighted aHilighted : Bool, index anIndex: Int, previousValue aPreviousY : CGFloat ) -> CGFloat {
		let		theX0 = floor(NSMidX(drawingBounds)+equalTempBarWidth/2.0)-20.5;
		let		theY = CGFloat(log2(aRatio.toDouble)) * NSHeight(drawingBounds) + NSMinY(drawingBounds);
		let		theCloseToPrevious = abs(theY-aPreviousY)<14.0;
		let		theX1 = theX0 + CGFloat(theCloseToPrevious ? 55.0 : 15.0);
		let		thePath = NSBezierPath()
		thePath.moveToPoint(NSMakePoint(theX1+4.5, theY))
		thePath.curveToPoint(NSMakePoint(theX1+2.5, theY+2.0), controlPoint1: NSMakePoint(theX1+4.5, theY+1.1), controlPoint2: NSMakePoint(theX1+3.6, theY+2.0))
		thePath.curveToPoint(NSMakePoint(theX1+0.5, theY), controlPoint1: NSMakePoint(theX1+1.4, theY+2.0), controlPoint2: NSMakePoint(theX1+0.5, theY+1.1))
		thePath.curveToPoint(NSMakePoint(theX1+2.5, theY-2.0), controlPoint1: NSMakePoint(theX1+0.5, theY-1.1), controlPoint2: NSMakePoint(theX1+1.4, theY-2.0))
		thePath.curveToPoint(NSMakePoint(theX1+4.5, theY), controlPoint1: NSMakePoint(theX1+3.6, theY-2.0), controlPoint2: NSMakePoint(theX1+4.5, theY-1.1))
		thePath.closePath()
		thePath.moveToPoint(NSMakePoint(theX1, theY))
		thePath.lineToPoint(NSMakePoint(theX0-equalTempBarWidth, theY))
		thePath.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
		if aHilighted {
			NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0).setFill()
			NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
			thePath.fill()
			thePath.lineWidth = 3.0;
		} else {
			NSColor(white: 0.0, alpha:0.25).setStroke();
			thePath.lineWidth = 0.5;
		}
		thePath.stroke()
		
		let		theSize = (aHilighted ?  NSFont.systemFontSizeForControlSize(NSControlSize.RegularControlSize) : NSFont.systemFontSizeForControlSize(NSControlSize.MiniControlSize)) + 2.0;
		let		theTextColor = aHilighted ? NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0) : NSColor(white: 0.0, alpha: 0.25);
		drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX1+10.0, theY-theSize*0.5-3.0), color:theTextColor );
		
		return theCloseToPrevious ? 0.0 : theY;
	}
	
	override func drawEqualTemperamentRatio( rationNumber aRatioNumber : UInt ) {
		let		theHeights = NSHeight(drawingBounds)/CGFloat(numberOfIntervals);
		let		theX = floor(NSMidX(drawingBounds)-equalTempBarWidth/2.0)-20.5;
		let		theY = CGFloat(aRatioNumber)*theHeights+NSMinX(drawingBounds);
		LinearScaleView.equalTempGradient!.drawInBezierPath(NSBezierPath(rect: NSMakeRect(theX, theY, equalTempBarWidth, theHeights)), angle: -90)
	}
	override func drawNoEqualTemperament( ) {
		let		theX = floor(NSMidX(drawingBounds)-equalTempBarWidth/2.0)-20.5;
		NSColor(calibratedWhite: 0.875, alpha: 1.0).setFill();
		NSRectFill(NSMakeRect(theX, NSMinX(drawingBounds), equalTempBarWidth, NSHeight(drawingBounds)));
	}
}

class PitchConstellationView : ScaleView {
	private var		maximumRadius : CGFloat { get { return min(NSWidth(self.bounds), NSHeight(self.bounds))*0.5; } }
	private var		axisesRadius : CGFloat { get { return min(maximumRadius-80.0, 320.0); } }
	override func drawJustIntonationRatio( ratio aRatio : Rational, hilighted aHilighted : Bool, index anIndex: Int, previousValue aPreviousY : CGFloat ) -> CGFloat {
		let		theBounds = self.bounds;
		let		theAngle = CGFloat(log2(aRatio.toDouble) * 2.0*M_PI);
		let		theRadius = aHilighted ? maximumRadius - 40.0 : axisesRadius;
		let		thePath = NSBezierPath()
		thePath.moveToPoint(NSMakePoint(NSMidX(theBounds), NSMidY(theBounds)));
		thePath.lineToPoint(NSMakePoint(NSMidX(theBounds)+sin(theAngle)*theRadius, NSMidY(theBounds)+cos(theAngle)*theRadius));
		thePath.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
		if aHilighted {
			NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0).setStroke();
			thePath.lineWidth = 3.0;
		} else {
			NSColor(white: 0.0, alpha:0.5).setStroke();
			thePath.lineWidth = 0.5;
		}
		thePath.stroke();

		let		theSize = (aHilighted ?  NSFont.systemFontSizeForControlSize(NSControlSize.RegularControlSize) : NSFont.systemFontSizeForControlSize(NSControlSize.MiniControlSize)) + 2.0;
		let		theTextColor = aHilighted ? NSColor(calibratedHue: hueForIndex(anIndex), saturation: 1.0, brightness: 0.75, alpha: 1.0) : NSColor(white: 0.0, alpha: 0.25);
		let		theTextAlignment : NSTextAlignment = abs(sin(theAngle)) < 0.707 ? .Center : sin(theAngle) < 0.0 ? .Right :  .Left;
		drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(NSMidX(theBounds)+sin(theAngle)*(theRadius+5.0), NSMidY(theBounds)+cos(theAngle)*(theRadius+11.0)-theSize*0.8), color:theTextColor, textAlignment: theTextAlignment );
		
		return 0.0;
	}
	
	override func drawEqualTemperamentRatio( rationNumber aRatioNumber : UInt ) {
		let		theBounds = self.bounds;
		let		theArcLength = 360.0/CGFloat(numberOfIntervals);
		let		theStart = CGFloat(aRatioNumber)*theArcLength;
		let		theEnd	= CGFloat(aRatioNumber+1)*theArcLength;
		let		thePath = NSBezierPath();
		thePath.appendBezierPathWithArcWithCenter(NSMakePoint(NSMidX(theBounds), NSMidY(theBounds)), radius:axisesRadius, startAngle: theStart, endAngle: theEnd);
		thePath.appendBezierPathWithArcWithCenter(NSMakePoint(NSMidX(theBounds), NSMidY(theBounds)), radius:axisesRadius-equalTempBarWidth, startAngle: theEnd, endAngle: theStart, clockwise: true);
		thePath.closePath();
		LinearScaleView.equalTempGradient!.drawInBezierPath(thePath, angle: (theStart+theEnd)*0.5+90.0);
	}

	override func drawNoEqualTemperament( ) {
		let		thePath = NSBezierPath();
		thePath.appendBezierPathWithOvalInRect(NSMakeRect( NSMidX(self.bounds)-axisesRadius+(equalTempBarWidth*0.5), NSMidY(self.bounds)-axisesRadius+(equalTempBarWidth*0.5), 2.0*axisesRadius-equalTempBarWidth, 2.0*axisesRadius-equalTempBarWidth ) );
		thePath.lineWidth = equalTempBarWidth;
		NSColor(calibratedWhite: 0.875, alpha: 1.0).setStroke();
		thePath.stroke();
	}
}

