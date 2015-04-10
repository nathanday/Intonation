//
//  ResultView.swift
//  Equal Temperament
//
//  Created by Nathan Day on 8/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ResultView: NSControl {

	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, selected aSelected: Bool ) {
		drawText(string: aString, size: aSize, point: aPoint, color:NSColor.blackColor(), selected: aSelected );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor, selected aSelected: Bool ) {
		let		theTextRect = NSMakeRect(aPoint.x, aPoint.y, 60.0, 16.0);
		let		theTextTextContent = NSString(string: aString );
		let		theTextStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle;
		theTextStyle.alignment = NSTextAlignment.LeftTextAlignment
		
		var		theTextFontAttributes = [NSFontAttributeName: NSFont.systemFontOfSize(aSize), NSForegroundColorAttributeName: aColor, NSParagraphStyleAttributeName: theTextStyle]
		if aSelected {
			theTextFontAttributes[NSFontAttributeName] = NSFont.boldSystemFontOfSize(aSize*1.2);
		}
		
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
