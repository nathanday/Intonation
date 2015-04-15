//
//  ResultView.swift
//  Equal Temperament
//
//  Created by Nathan Day on 8/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ResultView: NSControl {

	var		commonFactor : Int {
		get {
			var		theResult = 1;
			for theValue in selectedRatios {
				theResult *= theValue.denominator/greatestCommonDivisor(theResult,theValue.denominator);
			}
			return theResult;
		}
	}
	var		selectedRatios : [Rational] = [] {
		didSet { setNeedsDisplay(); }
	}
	var		everyRatios : [Rational] = [] {
		didSet { setNeedsDisplay(); }
	}
	
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint ) {
		drawText(string: aString, size: aSize, point: aPoint, color:NSColor.blackColor(), textAlignment: NSTextAlignment.LeftTextAlignment );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor ) {
		drawText(string: aString, size: aSize, point: aPoint, color:aColor, textAlignment: NSTextAlignment.LeftTextAlignment );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor, textAlignment aTextAlignment: NSTextAlignment ) {
		var		theTextRect = NSMakeRect(aPoint.x, aPoint.y, 480.0, 16.0);
		let		theTextTextContent = NSString(string: aString );
		let		theTextStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle;
		theTextStyle.alignment = aTextAlignment
		if aTextAlignment == NSTextAlignment.CenterTextAlignment {
			theTextRect.origin.x -= NSWidth(theTextRect)*0.5;
		}
		else if aTextAlignment == NSTextAlignment.RightTextAlignment {
			theTextRect.origin.x -= NSWidth(theTextRect);
		}
		
		var		theTextFontAttributes = [NSFontAttributeName: NSFont.systemFontOfSize(aSize), NSForegroundColorAttributeName: aColor, NSParagraphStyleAttributeName: theTextStyle]
		
		let		theTextTextHeight: CGFloat = theTextTextContent.boundingRectWithSize(NSMakeSize(theTextRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: theTextFontAttributes).size.height
		let		theTextTextRect: NSRect = NSMakeRect(theTextRect.minX, theTextRect.minY + (theTextRect.height - theTextTextHeight) / 2.0, theTextRect.width, theTextTextHeight)
		NSGraphicsContext.saveGraphicsState()
		NSRectClip(theTextRect)
		theTextTextContent.drawInRect(NSOffsetRect(theTextTextRect, 0.0, 1.0), withAttributes: theTextFontAttributes)
		NSGraphicsContext.restoreGraphicsState()
	}

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

		func drawCanvase() {
			let		theBounds = NSInsetRect(self.bounds, 2.0, 2.0);
			let		thePath = NSBezierPath()
			thePath.appendBezierPathWithArcWithCenter(NSMakePoint(theBounds.maxX-2.0, theBounds.maxY-2.0), radius: 4.0, startAngle: 90, endAngle: 0, clockwise: true)
			thePath.appendBezierPathWithArcWithCenter(NSMakePoint(theBounds.maxX-2.0, theBounds.minY+2.0), radius: 4.0, startAngle: 0, endAngle: 270, clockwise: true)
			thePath.appendBezierPathWithArcWithCenter(NSMakePoint(theBounds.minX+2.0, theBounds.minY+2.0), radius: 4.0, startAngle: 270, endAngle: 180, clockwise: true)
			thePath.appendBezierPathWithArcWithCenter(NSMakePoint(theBounds.minX+2.0, theBounds.maxY-2.0), radius: 4.0, startAngle: 180, endAngle: 90, clockwise: true)
			thePath.closePath()
			NSColor.whiteColor().setFill()
			thePath.fill()
		}
		
		drawCanvase();
	}
    
}
