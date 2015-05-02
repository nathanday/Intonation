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

	func hueForIndex( aIndex : Int ) -> CGFloat { return (CGFloat(aIndex+4)*1.0/5.1-2.0/15.0)%1.0; }

	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint ) {
		drawText(string: aString, size: aSize, point: aPoint, color:NSColor.blackColor(), textAlignment: NSTextAlignment.LeftTextAlignment );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor ) {
		drawText(string: aString, size: aSize, point: aPoint, color:aColor, textAlignment: NSTextAlignment.LeftTextAlignment );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor, textAlignment aTextAlignment: NSTextAlignment ) {
		var		theTextRect = NSMakeRect(aPoint.x, aPoint.y-aSize*0.2, 480.0, aSize*1.6);
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

		let		theTextTextSize: CGSize = theTextTextContent.boundingRectWithSize(NSMakeSize(theTextRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: theTextFontAttributes).size
		var		theTextTextRect: NSRect = NSMakeRect(theTextRect.minX, theTextRect.minY + theTextRect.height*0.25 - theTextTextSize.height*0.1, theTextRect.width, theTextTextSize.height);
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


