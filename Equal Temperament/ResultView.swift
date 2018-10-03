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
					(x:1.0,hueComponent:CGFloat(1.25/7.5),saturationComponent:1.0,brightnessComponent:0.625),
					(x:3.0,hueComponent:CGFloat(3.625/7.5),saturationComponent:1.0,brightnessComponent:0.625),
					(x:7.25,hueComponent:1.0,saturationComponent:1.0,brightnessComponent:0.75)]);
			case NSAppearance.Name.darkAqua:
				_colorInterpolator = ColorInterpolator(hsbaPoints: [
					(x:0.0,hueComponent:0.0,saturationComponent:1.0,brightnessComponent:1.0),
					(x:1.0,hueComponent:CGFloat(1.0/7.5),saturationComponent:0.8125,brightnessComponent:1.0),
					(x:4.0,hueComponent:CGFloat(4.0/7.5),saturationComponent:1.0,brightnessComponent:1.0),
					(x:5.0,hueComponent:CGFloat(5.5/7.5),saturationComponent:0.75,brightnessComponent:1.0),
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

	weak var	dataSource : ResultViewDataSource?;
	weak var	delegate : ResultViewDelegate?;

	var		commonFactor : Int {
		get {
			var		theResult = 1;
			let		theSelectedIndicies = dataSource?.selectedIndecies;
			dataSource?.enumerateIntervals { (anIndex:Int, anInterval:Interval, aSelected: Bool) in
				if theSelectedIndicies?.contains(anIndex) ?? false {
					var		theDen = 1;
					if let theRationalValue = anInterval as? RationalInterval {
						theDen = theRationalValue.denominator;
					} else {
						theDen = Rational( anInterval.toDouble, maxDenominator:32 ).denominator;
					}
					theResult *= theDen/Int(greatestCommonDivisor( UInt(theResult), UInt(theDen) ));
				}
			}
			return theResult;
		}
	}

	func reloadData() {
		needsDisplay = true;
	}
	func reloadData(forIntervalIndexes intervalIndexes: IndexSet ) {
		reloadData();
	}

	override func viewDidChangeEffectiveAppearance() {
		_colorInterpolator = nil;
	}

	func colorForIndex( _ aIndex : Int ) -> NSColor {
		return colorInterpolator[CGFloat(aIndex)]!;
	}

    var axisesColor : NSColor {
		return NSColor.controlAccentColor;
    }
    
	var majorAxisesColor : NSColor {
		return NSColor.controlAccentColor;
	}

	var majorAxisesTextColor : NSColor {
		return NSColor.secondaryLabelColor;
	}

	var minorAxisesColor : NSColor {
		return NSColor.controlAccentColor.withAlphaComponent(0.6666);
	}
	var secondaryMinorAxisesColor : NSColor {
		return NSColor.controlAccentColor.withAlphaComponent(0.3333);
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
				thePath.move(to: NSMakePoint(theFrame.minX, theFrame.minY-1.0));
				thePath.line(to: NSMakePoint(theFrame.maxX, theFrame.minY-1.0));
				thePath.move(to: NSMakePoint(theFrame.minX, theFrame.maxY+1.0));
				thePath.line(to: NSMakePoint(theFrame.maxX, theFrame.maxY+1.0));
			case .horizontal:
				thePath.move(to: NSMakePoint(theFrame.minX-1.0,theFrame.minY));
				thePath.line(to: NSMakePoint(theFrame.minX-1.0,theFrame.maxY));
				thePath.move(to: NSMakePoint(theFrame.maxX+1.0,theFrame.minY));
				thePath.line(to: NSMakePoint(theFrame.maxX+1.0,theFrame.maxY));
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

protocol ResultViewDataSource : class {
	var numberOfIntervals : Int {get};
	var numberOfSelectedIntervals : Int {get};
	func interval(for anIndex: Int) -> Interval?;
	var selectedIndecies : IndexSet {get};
	var selectedInterval : [(index:Int,interval:Interval)] {get};
	func enumerateIntervals( _ aBlock: (Int,Interval,Bool) -> Void );
	func enumerateSelectedIntervals( _ aBlock: (Int,Int,Interval) -> Void );
}

protocol ResultViewDelegate : class {
	func resultView( _ resultView: ResultView, willSelectIntervalAtIndex index: Int );
	func resultView( _ resultView: ResultView, didSelectIntervalAtIndex index: Int );
	func resultView( _ resultView: ResultView, willDeselectIntervalAtIndex index: Int );
	func resultView( _ resultView: ResultView, didDeselectIntervalAtIndex index: Int );
}
