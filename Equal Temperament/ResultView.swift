/*
	ResultView.swift
	Intonation

	Created by Nathan Day on 8/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

@IBDesignable class ResultView: NSControl {

	var		commonFactor : Int {
		get {
			var		theResult = 1;
			for theValue in selectedRatios {
				var		theDen = 1;
				if let theRationalValue = theValue as? RationalInterval {
					theDen = theRationalValue.denominator;
				} else {
					(_,theDen) = Rational.farey( Double(theValue.toDouble), maxDenominator:32 );
				}
				theResult *= theDen/Int(greatestCommonDivisor( UInt(theResult), UInt(theDen) ));
			}
			return theResult;
		}
	}
	var		selectedRatios : [Interval] = [] {
		didSet { setNeedsDisplay(); }
	}
	var		everyRatios : [Interval] = [] {
		didSet { setNeedsDisplay(); }
	}

	func hueForIndex( aIndex : Int ) -> CGFloat { return (CGFloat(aIndex+4)*1.0/5.1-2.0/15.0)%1.0; }

	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint ) {
		drawText(string: aString, size: aSize, point: aPoint, color:NSColor.blackColor(), textAlignment: .Left );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor ) {
		drawText(string: aString, size: aSize, point: aPoint, color:aColor, textAlignment: .Left );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor, textAlignment aTextAlignment: NSTextAlignment ) {
		var		theTextRect = NSMakeRect(aPoint.x, aPoint.y-aSize*0.2, 480.0, aSize*1.6);
		let		theTextTextContent = NSString(string: aString );
		let		theTextStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle;
		theTextStyle.alignment = aTextAlignment
		if aTextAlignment == .Center {
			theTextRect.origin.x -= NSWidth(theTextRect)*0.5;
		}
		else if aTextAlignment == .Right {
			theTextRect.origin.x -= NSWidth(theTextRect);
		}

		let		theTextFontAttributes = [NSFontAttributeName: NSFont.systemFontOfSize(aSize), NSForegroundColorAttributeName: aColor, NSParagraphStyleAttributeName: theTextStyle]

		let		theTextTextSize: CGSize = theTextTextContent.boundingRectWithSize(NSMakeSize(theTextRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: theTextFontAttributes).size
		let		theTextTextRect: NSRect = NSMakeRect(theTextRect.minX, theTextRect.minY + theTextRect.height*0.25 - theTextTextSize.height*0.1, theTextRect.width, theTextTextSize.height);
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

@IBDesignable class BackGround : ResultView {
	enum Orientation {
		case vertical;
		case horizontal;
	};
	@IBOutlet var		childView : NSView?
	var					orientation = Orientation.vertical;
	override func drawRect(dirtyRect: NSRect) {
		super.drawRect(dirtyRect);
		let		thePath = NSBezierPath();
		assert( childView != nil );
		if let theFrame = childView?.frame {
			thePath.lineWidth = 1.0;
			switch orientation {
			case .vertical:
				thePath.moveToPoint(NSMakePoint(NSMinX(theFrame), NSMinY(theFrame)-1.0));
				thePath.lineToPoint(NSMakePoint(NSMaxX(theFrame), NSMinY(theFrame)-1.0));
				thePath.moveToPoint(NSMakePoint(NSMinX(theFrame), NSMaxY(theFrame)+1.0));
				thePath.lineToPoint(NSMakePoint(NSMaxX(theFrame), NSMaxY(theFrame)+1.0));
			case .horizontal:
				thePath.moveToPoint(NSMakePoint(NSMinX(theFrame)-1.0,NSMinY(theFrame)));
				thePath.lineToPoint(NSMakePoint(NSMinX(theFrame)-1.0,NSMaxY(theFrame)));
				thePath.moveToPoint(NSMakePoint(NSMaxX(theFrame)+1.0,NSMinY(theFrame)));
				thePath.lineToPoint(NSMakePoint(NSMaxX(theFrame)+1.0,NSMaxY(theFrame)));
			}
			NSColor.darkGrayColor().setStroke();
			thePath.stroke();
		}
	}
}

extension BackGround {
	@IBInspectable var horizontal: Bool {
		get { return orientation == .horizontal; }
		set( aValue ) { self.orientation = aValue ? .horizontal : .vertical; }
	}
}


