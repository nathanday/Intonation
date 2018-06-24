//
//  ColorInterpolator.swift
//  Intonation
//
//  Created by Nathaniel Day on 5/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Cocoa

struct ColorInterpolator : Equatable {

	typealias Element = (x:CGFloat,hueComponent:CGFloat,saturationComponent:CGFloat,brightnessComponent:CGFloat);
	public let hsbaPoints : [Element];
	public let closedHue : Bool;
	public var count : Int { return hsbaPoints.count; }

	init( hsbaPoints aHSBAPoints: [Element], closedHue aClosedHue : Bool = true ) {
		hsbaPoints = aHSBAPoints.sorted { $0.x < $1.x; }
		closedHue = aClosedHue;
	}

	init( closedHue aClosedHue : Bool = true ) {
		self.init(hsbaPoints:[
			(x:0.0,hueComponent:0.0,saturationComponent:1.0,brightnessComponent:1.0),
			(x:1.0,hueComponent:1.0,saturationComponent:1.0,brightnessComponent:1.0)
			], closedHue: aClosedHue );
	}

	init( colors aColors: [NSColor], closedHue aClosedHue : Bool = true  ) {
		var	theHSBPoints = [Element]();
		for (theIndex,theColor) in aColors.enumerated() {
			var		theComponents = (x:CGFloat(theIndex),hueComponent:CGFloat(0.0),saturationComponent:CGFloat(0.0),brightnessComponent:CGFloat(0.0));
			theColor.getHue(&theComponents.hueComponent, saturation: &theComponents.saturationComponent, brightness: &theComponents.brightnessComponent, alpha:nil);
			theHSBPoints.append(theComponents);
		}
		self.init(hsbaPoints:theHSBPoints,closedHue:aClosedHue);
	}

	init( points aPoints: [(x:CGFloat,color:NSColor)], closedHue aClosedHue : Bool = true  ) {
		var	theHSBPoints = [Element]();
		for (theX,theColor) in aPoints {
			var		theComponents = (x:theX,hueComponent:CGFloat(0.0),saturationComponent:CGFloat(0.0),brightnessComponent:CGFloat(0.0));
			theColor.getHue( &theComponents.hueComponent, saturation: &theComponents.saturationComponent, brightness: &theComponents.brightnessComponent, alpha:nil);
			theHSBPoints.append(theComponents);
		}
		self.init(hsbaPoints:theHSBPoints,closedHue:aClosedHue);
	}

	private func search(_ x: CGFloat) -> Array<Element>.Index {
		var low = hsbaPoints.startIndex
		var high = hsbaPoints.endIndex
		while low != high {
			let mid = hsbaPoints.index(low, offsetBy: hsbaPoints.distance(from: low, to: high)/2)
			if x > hsbaPoints[mid].x {
				low = hsbaPoints.index(after: mid)
			} else {
				high = mid
			}
		}
		return low
	}

	var domainStart : CGFloat? { return hsbaPoints.first?.x; }
	var domainEnd : CGFloat? { return hsbaPoints.last?.x; }
	var domainSize : CGFloat? { return count > 0 ? hsbaPoints.last!.x -  hsbaPoints.first!.x : 0.0; }

	func values(at anAt:CGFloat, alpha anAlpha: CGFloat = 1.0) -> Element? {
		guard count > 0 else {
			return nil;
		}

		func blend( _ b:CGFloat, _ l:CGFloat, _ h:CGFloat ) -> CGFloat { return b*(h-l)+l; }
		let		theAt = ((anAt - domainStart!).truncatingRemainder(dividingBy:domainSize!))+domainStart!;
		let		theIndex = search(theAt);
		let		theLComponets = closedHue ? hsbaPoints[theIndex%count] : hsbaPoints[min(theIndex,count)];
		let		theHComponets = hsbaPoints[(theIndex+1)%count];
		let		theBlend = (theAt-theLComponets.x)/(theHComponets.x-theLComponets.x);
		let		theHHue = theIndex < count ? theHComponets.hueComponent : theLComponets.hueComponent + (theLComponets.hueComponent - theHComponets.hueComponent).rounded(.up);
		return (x:theAt, hueComponent: blend(theBlend,theLComponets.hueComponent,theHHue),
					   saturationComponent: blend(theBlend,theLComponets.saturationComponent,theHComponets.saturationComponent),
					   brightnessComponent: blend(theBlend,theLComponets.brightnessComponent,theHComponets.brightnessComponent));
	}

	func color(at anAt:CGFloat, alpha anAlpha: CGFloat = 1.0) -> NSColor? {
		guard let theComponets = values(at:anAt) else {
			return nil;
		}
		return NSColor(deviceHue: theComponets.hueComponent.truncatingRemainder(dividingBy: 1.0),
					   saturation: theComponets.saturationComponent,
					   brightness: theComponets.brightnessComponent,
					   alpha: anAlpha);
	}

	subscript(x:CGFloat) -> NSColor? {
		return color(at:x);
	}

	subscript(x:Int) -> NSColor? {
		guard x < count else {
			return nil;
		}
		let		theComponets = hsbaPoints[x];
		return NSColor(deviceHue: theComponets.hueComponent, saturation: theComponets.saturationComponent, brightness: theComponets.brightnessComponent, alpha: 1.0);
	}

	subscript(aBounds: Range<Int>) -> [NSColor] {
		var		theResult = [NSColor]();
		for theIndex in aBounds {
			if let theColour = self[theIndex] {
				theResult.append(theColour);
			} else {
				break;
			}
		}
		return theResult;
	}

	subscript<R>(r: R) -> [NSColor] where R : RangeExpression, Array<NSColor>.Index == R.Bound {
		return self[r.relative(to:hsbaPoints)];
	}

	func withClosedHue(_ aClosedHue: Bool) -> ColorInterpolator {
		return ColorInterpolator(hsbaPoints: hsbaPoints, closedHue: aClosedHue);
	}

	public static func == (lhs: ColorInterpolator, rhs: ColorInterpolator) -> Bool {
		if lhs.closedHue != rhs.closedHue {
			return false;
		}
		if lhs.count != rhs.count {
			return false;
		}
		for (theIndex,theComps) in lhs.hsbaPoints.enumerated() {
			if theComps != rhs.hsbaPoints[theIndex] {
				return false;
			}
		}
		return true;
	}
}

extension ColorInterpolator : CustomStringConvertible, CustomDebugStringConvertible {
	var description: String { return hsbaPoints.description; }
	public var debugDescription: String {
		return "<ColorInterpolator> \(hsbaPoints.description)";
	}
}

extension ColorInterpolator : ExpressibleByArrayLiteral {
	public init(arrayLiteral anElements: Element...) {
		self.init(hsbaPoints:anElements);
	}
//	public init(arrayLiteral anElements: NSColor...) {
//		self.init(colors:anElements);
//	}
//	public init(arrayLiteral anElements: (x:CGFloat,color:NSColor)...) {
//		self.init(points:anElements);
//	}
}
