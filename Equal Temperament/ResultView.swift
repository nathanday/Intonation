/*
	ResultView.swift
	Intonation

	Created by Nathan Day on 8/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

@IBDesignable class ResultView: NSControl {

	private var		_colorInterpolator: ColorInterpolator?;
	var		colorInterpolator: ColorInterpolator {
		if _colorInterpolator == nil {
			switch effectiveAppearance.bestMatch(from: [.aqua,.darkAqua]) {
			case NSAppearance.Name.aqua:
				_colorInterpolator = ColorInterpolator(hsbaPoints: [
					(x:0.0,hueComponent:0.0,saturationComponent:1.0,brightnessComponent:0.75),
					(x:2.0,hueComponent:CGFloat(2.0/7.5),saturationComponent:1.0,brightnessComponent:0.625),
					(x:3.0,hueComponent:CGFloat(3.5/7.5),saturationComponent:1.0,brightnessComponent:0.625),
					(x:4.0,hueComponent:CGFloat(4.0/7.5),saturationComponent:1.0,brightnessComponent:0.625),
					(x:7.25,hueComponent:1.0,saturationComponent:1.0,brightnessComponent:0.75)]);
			case NSAppearance.Name.darkAqua:
				_colorInterpolator = ColorInterpolator(hsbaPoints: [
					(x:0.0,hueComponent:0.0,saturationComponent:1.0,brightnessComponent:1.0),
					(x:1.0,hueComponent:CGFloat(1.0/7.5),saturationComponent:0.8125,brightnessComponent:1.0),
					(x:4.0,hueComponent:CGFloat(4.0/7.5),saturationComponent:1.0,brightnessComponent:1.0),
					(x:5.0,hueComponent:CGFloat(5.0/7.5),saturationComponent:0.75,brightnessComponent:1.0),
					(x:7.25,hueComponent:1.0,saturationComponent:1.0,brightnessComponent:1.0)]);
			default:
				_colorInterpolator = ColorInterpolator(hsbaPoints: [
					(x:0.0,hueComponent:0.0,saturationComponent:1.0,brightnessComponent:0.75),
					(x:0.0,hueComponent:0.0,saturationComponent:1.0,brightnessComponent:0.75),
					(x:7.25,hueComponent:1.0,saturationComponent:1.0,brightnessComponent:0.75)]);
			}
		}
		return _colorInterpolator!;
	}

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
		didSet { needsDisplay = true; }
	}
	var		everyRatios : [Interval] = [] {
		didSet { needsDisplay = true; }
	}

	override func viewDidChangeEffectiveAppearance() {
		_colorInterpolator = nil;
	}

	func colorForIndex( _ aIndex : Int ) -> NSColor {
		return colorInterpolator[CGFloat(aIndex)]!;
	}

    var axisesColor : NSColor {
		return NSColor.controlAccent;
    }
    
    var majorAxisesColor : NSColor {
		return NSColor.secondarySelectedControlColor;
    }
    
    var minorAxisesColor : NSColor {
		return NSColor.controlAccent.withAlphaComponent(0.25);
//		return NSColor(named: NSColor.Name("minorAxisesColor"))!;
    }
    
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint ) {
		drawText(string: aString, size: aSize, point: aPoint, color:NSColor.textColor, textAlignment: .left );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor ) {
		drawText(string: aString, size: aSize, point: aPoint, color:aColor, textAlignment: .left );
	}
	func drawText(string aString: String, size aSize: CGFloat, point aPoint: CGPoint, color aColor: NSColor, textAlignment aTextAlignment: NSTextAlignment ) {
		var		theTextRect = NSMakeRect(aPoint.x, aPoint.y-aSize*0.2, 480.0, aSize*1.6);
		let		theTextTextContent = NSString(string: aString );
		let		theTextStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle;
		theTextStyle.alignment = aTextAlignment
		if aTextAlignment == .center {
			theTextRect.origin.x -= NSWidth(theTextRect)*0.5;
		}
		else if aTextAlignment == .right {
			theTextRect.origin.x -= NSWidth(theTextRect);
		}

		let		theTextFontAttributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: aSize), NSAttributedString.Key.foregroundColor: aColor, NSAttributedString.Key.paragraphStyle: theTextStyle]

		let		theTextTextSize: CGSize = theTextTextContent.boundingRect(with: NSMakeSize(theTextRect.width, CGFloat.infinity), options: NSString.DrawingOptions.usesLineFragmentOrigin, attributes: theTextFontAttributes).size
		let		theTextTextRect: NSRect = NSMakeRect(theTextRect.minX, theTextRect.minY + theTextRect.height*0.25 - theTextTextSize.height*0.1, theTextRect.width, theTextTextSize.height);
		NSGraphicsContext.saveGraphicsState()
//		theTextRect.clip
		theTextTextContent.draw(in: NSOffsetRect(theTextTextRect, 0.0, 1.0), withAttributes: theTextFontAttributes)
		NSGraphicsContext.restoreGraphicsState()
	}

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

		func drawCanvase() {
			let		theBounds = NSInsetRect(bounds, 2.0, 2.0);
			let		thePath = NSBezierPath()
			thePath.appendArc(withCenter: NSMakePoint(theBounds.maxX-2.0, theBounds.maxY-2.0), radius: 4.0, startAngle: 90, endAngle: 0, clockwise: true)
			thePath.appendArc(withCenter: NSMakePoint(theBounds.maxX-2.0, theBounds.minY+2.0), radius: 4.0, startAngle: 0, endAngle: 270, clockwise: true)
			thePath.appendArc(withCenter: NSMakePoint(theBounds.minX+2.0, theBounds.minY+2.0), radius: 4.0, startAngle: 270, endAngle: 180, clockwise: true)
			thePath.appendArc(withCenter: NSMakePoint(theBounds.minX+2.0, theBounds.maxY-2.0), radius: 4.0, startAngle: 180, endAngle: 90, clockwise: true)
			thePath.close()
			NSColor.windowBackgroundColor.setFill()
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
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect);
		let		thePath = NSBezierPath();
		assert( childView != nil );
		if let theFrame = childView?.frame {
			thePath.lineWidth = 1.0;
			switch orientation {
			case .vertical:
				thePath.move(to: NSMakePoint(NSMinX(theFrame), NSMinY(theFrame)-1.0));
				thePath.line(to: NSMakePoint(NSMaxX(theFrame), NSMinY(theFrame)-1.0));
				thePath.move(to: NSMakePoint(NSMinX(theFrame), NSMaxY(theFrame)+1.0));
				thePath.line(to: NSMakePoint(NSMaxX(theFrame), NSMaxY(theFrame)+1.0));
			case .horizontal:
				thePath.move(to: NSMakePoint(NSMinX(theFrame)-1.0,NSMinY(theFrame)));
				thePath.line(to: NSMakePoint(NSMinX(theFrame)-1.0,NSMaxY(theFrame)));
				thePath.move(to: NSMakePoint(NSMaxX(theFrame)+1.0,NSMinY(theFrame)));
				thePath.line(to: NSMakePoint(NSMaxX(theFrame)+1.0,NSMaxY(theFrame)));
			}
			NSColor.gridColor.setStroke();
			thePath.stroke();
		}
	}
}

extension BackGround {
	@IBInspectable var horizontal: Bool {
		get { return orientation == .horizontal; }
		set( aValue ) { orientation = aValue ? .horizontal : .vertical; }
	}
}


