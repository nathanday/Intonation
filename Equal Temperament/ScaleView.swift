/*
	ScaleView.swift
	Intonation
	
	Created by Nathan Day on 5/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

class ScaleView : ResultView {
	static let		equalTempGradient: NSGradient? = NSGradient(starting: NSColor(named: "intonationGradientStart")!, ending: NSColor(named: "intonationGradientEnd")!);
	let		equalTempBarWidth : CGFloat = 20.0;
	
	var		numberOfIntervals : Int = 12 {
		didSet { needsDisplay = true; }
	}
	var		useIntervals : Bool = true {
		didSet { needsDisplay = true; }
	}
	
	func drawJustIntonationRatio( ratio aRatio : Interval, hilighted aHilighted : Bool, index anIndex: Int ) {
	}
	
	func drawEqualTemperamentRatio( rationNumber aRatioNumber : Int ) {
	}
	func drawNoEqualTemperament( ) { }
	
	override func draw(_ aDirtyRect: NSRect) {
		if useIntervals {
			for i in 0..<numberOfIntervals { drawEqualTemperamentRatio( rationNumber: i ); }
		}
		else {
			drawNoEqualTemperament();
		}
		dataSource?.enumerateIntervals { (anIndex:Int, anInterval:Interval, aSelected: Bool) in
			drawJustIntonationRatio(ratio: anInterval, hilighted: aSelected, index:anIndex );
		}
	}

	func closestInterval(to aPoint: CGPoint ) -> (index:Int,interval:Interval,distance:CGFloat)? {
		preconditionFailure("This method must be overridden")
	}

	override func mouseDown(with anEvent: NSEvent) {
		let		theLocation = convert(anEvent.locationInWindow, from: nil );
		if let theClosestInterval = closestInterval(to: theLocation) {
			delegate?.resultView( self, willSelectIntervalAtIndex: theClosestInterval.index );
		}
	}
	override func mouseUp(with anEvent: NSEvent) {
		let		theLocation = convert(anEvent.locationInWindow, from: nil );
		if let theClosestInterval = closestInterval(to: theLocation) {
			delegate?.resultView( self, didSelectIntervalAtIndex: theClosestInterval.index );
		}
	}
	override func mouseDragged(with anEvent: NSEvent) {
		print( "################################# mouseDragged(with:) \(anEvent.description)" );
	}
	override func mouseMoved(with anEvent: NSEvent) {
		print( "################################# mouseMoved(with:) \(anEvent.description)" );
	}
}

class LinearScaleView : ScaleView {
	private var		previousValue : CGFloat = 0.0;
	private var		offsetCount : UInt = 0;
	private var		drawingBounds : NSRect {
		get {
			var		theResult = NSInsetRect(bounds, 0.0, 5.0);
			theResult.origin.x += 5.0;
			return theResult;
		}
	}
	override func draw(_ aDirtyRect: NSRect) {
		previousValue = 0.0;
		super.draw(aDirtyRect);
	}
	override func drawJustIntonationRatio( ratio aRatio : Interval, hilighted aHilighted : Bool, index anIndex: Int ) {
		let		theX0 = floor(NSMidX(drawingBounds)+equalTempBarWidth/2.0)-20.5;
		let		theY = CGFloat(log2(aRatio.toDouble)) * NSHeight(drawingBounds) + NSMinY(drawingBounds);
		let		theCloseToPrevious = abs(theY-previousValue)<14.0;
		offsetCount = theCloseToPrevious ? ((offsetCount+1)%6) : 0;
		let		theX1 = theX0 + 15.0 + 40.0*CGFloat(offsetCount);
		let		thePath = NSBezierPath()
		thePath.move(to: NSMakePoint(theX1+4.5, theY))
		thePath.curve(to: NSMakePoint(theX1+2.5, theY+2.0), controlPoint1: NSMakePoint(theX1+4.5, theY+1.1), controlPoint2: NSMakePoint(theX1+3.6, theY+2.0))
		thePath.curve(to: NSMakePoint(theX1+0.5, theY), controlPoint1: NSMakePoint(theX1+1.4, theY+2.0), controlPoint2: NSMakePoint(theX1+0.5, theY+1.1))
		thePath.curve(to: NSMakePoint(theX1+2.5, theY-2.0), controlPoint1: NSMakePoint(theX1+0.5, theY-1.1), controlPoint2: NSMakePoint(theX1+1.4, theY-2.0))
		thePath.curve(to: NSMakePoint(theX1+4.5, theY), controlPoint1: NSMakePoint(theX1+3.6, theY-2.0), controlPoint2: NSMakePoint(theX1+4.5, theY-1.1))
		thePath.close()
		thePath.move(to: NSMakePoint(theX1, theY))
		thePath.line(to: NSMakePoint(theX0-equalTempBarWidth, theY))
		thePath.lineCapStyle = NSBezierPath.LineCapStyle.round
		if aHilighted {
			let		theColor = colorForIndex(anIndex);
			theColor.setFill()
			colorForIndex(anIndex).setStroke();
			thePath.fill()
			thePath.lineWidth = 3.0;
		} else {
			axisesColor.setStroke();
			thePath.lineWidth = 0.5;
		}
		thePath.stroke()
		
		let		theSize = (aHilighted ?  NSFont.systemFontSize(for: NSControl.ControlSize.regular) : NSFont.systemFontSize(for: NSControl.ControlSize.mini)) + 2.0;
		let		theTextColor = aHilighted ? colorForIndex(anIndex) : NSColor.secondaryLabelColor;
		drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(theX1+10.0, theY-theSize*0.5-3.0), color:theTextColor );
		
		previousValue = theY;
	}
	
	override func drawEqualTemperamentRatio( rationNumber aRatioNumber : Int ) {
		let		theHeights = NSHeight(drawingBounds)/CGFloat(numberOfIntervals);
		let		theX = floor(NSMidX(drawingBounds)-equalTempBarWidth/2.0)-20.5;
		let		theY = CGFloat(aRatioNumber)*theHeights+NSMinX(drawingBounds);
		LinearScaleView.equalTempGradient!.draw(in: NSBezierPath(rect: NSMakeRect(theX, theY, equalTempBarWidth, theHeights)), angle: -90);
	}
	override func drawNoEqualTemperament( ) {
		let		theX = floor(NSMidX(drawingBounds)-equalTempBarWidth/2.0)-20.5;
		NSColor.labelColor.setFill();
		NSMakeRect(theX, NSMinX(drawingBounds), equalTempBarWidth, NSHeight(drawingBounds)).fill();
	}
}

class PitchConstellationView : ScaleView {
	private var		maximumRadius : CGFloat {
		return min(NSWidth(bounds), NSHeight(bounds))*0.5;
	}
	private var		axisesRadius : CGFloat {
		return min(maximumRadius-80.0, 320.0);
	}
	private func endPoint(interval aRatio : Interval, radius aRadius : CGFloat) -> CGPoint {
		let		theBounds = bounds;
		let		theAngle = CGFloat(log2(aRatio.toDouble) * 2.0*Double.pi);
		return NSMakePoint(NSMidX(theBounds)+sin(theAngle)*aRadius, NSMidY(theBounds)+cos(theAngle)*aRadius);
	}


	override func closestInterval(to aPoint: CGPoint ) -> (index:Int,interval:Interval,distance:CGFloat)? {
		let		theBounds = bounds;
		var		theResult : (index:Int,interval:Interval,distance:CGFloat)?
		let		theOrigin = NSMakePoint(NSMidX(theBounds), NSMidY(theBounds));
		dataSource?.enumerateIntervals { (anIndex:Int, anInterval:Interval, aSelected: Bool) in
			let		theEndPoints = endPoint(interval: anInterval, radius: maximumRadius);
			let		theDistance = distance(from: aPoint, to: (p1: theOrigin, p2: theEndPoints));
			if let thePrevious = theResult {
				if theDistance < thePrevious.distance {
					theResult = (anIndex,anInterval,theDistance);
				}
			}  else {
				theResult = (anIndex,anInterval,theDistance);
			}
		}
		return theResult;
	}

	override func drawJustIntonationRatio( ratio aRatio : Interval, hilighted aHilighted : Bool, index anIndex: Int ) {
		let		theBounds = bounds;
		let		theAngle = CGFloat(log2(aRatio.toDouble) * 2.0*Double.pi);
		let		theRadius = aHilighted ? maximumRadius - 40.0 : axisesRadius;
		let		thePath = NSBezierPath()
		let		theOrigin = NSMakePoint(NSMidX(theBounds), NSMidY(theBounds));
		let		theLineEndPoint = endPoint(interval: aRatio, radius:theRadius);
		thePath.move(to: theOrigin);
		thePath.line(to: theLineEndPoint);
		thePath.lineCapStyle = NSBezierPath.LineCapStyle.round
		if aHilighted {
			colorForIndex(anIndex).setStroke();
			thePath.lineWidth = 3.0;
		} else {
			axisesColor.setStroke();
			thePath.lineWidth = 0.5;
		}
		thePath.stroke();

		let		theSize = (aHilighted ?  NSFont.systemFontSize(for: NSControl.ControlSize.regular) : NSFont.systemFontSize(for: NSControl.ControlSize.mini)) + 2.0;
		let		theTextColor = aHilighted ? colorForIndex(anIndex) : NSColor.secondaryLabelColor;
		let		theTextAlignment : NSTextAlignment = abs(sin(theAngle)) < 0.707 ? .center : sin(theAngle) < 0.0 ? .right :  .left;
		drawText(string: aRatio.ratioString, size:theSize, point: NSMakePoint(NSMidX(theBounds)+sin(theAngle)*(theRadius+5.0), NSMidY(theBounds)+cos(theAngle)*(theRadius+11.0)-theSize*0.8), color:theTextColor, textAlignment: theTextAlignment );
	}
	
	override func drawEqualTemperamentRatio( rationNumber aRatioNumber : Int ) {
		let		theBounds = bounds;
		let		theArcLength = 360.0/CGFloat(numberOfIntervals);
		let		theStart = CGFloat(90.0)-CGFloat(aRatioNumber+1)*theArcLength;
		let		theEnd	= CGFloat(90.0)-CGFloat(aRatioNumber)*theArcLength;
		let		thePath = NSBezierPath();
		thePath.appendArc(withCenter: NSMakePoint(NSMidX(theBounds), NSMidY(theBounds)), radius:axisesRadius, startAngle: theStart, endAngle: theEnd);
		thePath.appendArc(withCenter: NSMakePoint(NSMidX(theBounds), NSMidY(theBounds)), radius:axisesRadius-equalTempBarWidth, startAngle: theEnd, endAngle: theStart, clockwise: true);
		thePath.close();
		LinearScaleView.equalTempGradient!.draw(in: thePath, angle: (theStart+theEnd)*0.5+90.0);

		let		theAngle = (360.0+88.0-theStart) * CGFloat(Double.pi/180.0);
		let		theSize = NSFont.systemFontSize(for: NSControl.ControlSize.small);
		drawText(string: "\(aRatioNumber+1)", size:theSize, point: NSMakePoint(NSMidX(theBounds)+sin(theAngle)*(axisesRadius-9.0), NSMidY(theBounds)+cos(theAngle)*(axisesRadius-11.0)-theSize*0.8), color:NSColor.labelColor, textAlignment: .center );
	}

	override func drawNoEqualTemperament( ) {
		let		thePath = NSBezierPath();
		thePath.appendOval(in: NSMakeRect( NSMidX(bounds)-axisesRadius+(equalTempBarWidth*0.5), NSMidY(bounds)-axisesRadius+(equalTempBarWidth*0.5), 2.0*axisesRadius-equalTempBarWidth, 2.0*axisesRadius-equalTempBarWidth ) );
		thePath.lineWidth = equalTempBarWidth;
		NSColor(calibratedWhite: 0.875, alpha: 1.0).setStroke();
		thePath.stroke();
	}
}
