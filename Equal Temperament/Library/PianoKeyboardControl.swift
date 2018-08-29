//
//  PianoKeyboardControl.swift
//  PianoKeyboard
//
//  Created by Nathaniel Day on 7/08/18.
//  Copyright © 2018 Nathaniel Day. All rights reserved.
//

import Cocoa

@IBDesignable public class PianoKeyboardControl: NSControl {

	public static let	A440Frequency = 440.0;
	public static let	A440MidiNumber = 69;
	public enum NumberOfKeys : Int {
	case keys12 = 12;
	case keys13 = 13;
	case keys25 = 25;
	case keys49 = 49;
	case keys61 = 61;
	case keys76 = 76;
	case keys88 = 88;
	case keys92 = 92;
	case keys97 = 97;
	case keysFull = 127;
	}

	public enum Orientation {
	case vertical;
	case horizontal;
	}

	internal struct Geometry {
		var		origin : (x:CGFloat,y:CGFloat);
		var		size : (width:CGFloat,height:CGFloat);
		var		minX : CGFloat { return origin.x; }
		var		minY : CGFloat { return origin.y; }
		var		width : CGFloat { return size.width; }
		var		height : CGFloat { return size.height; }
		var		maxX : CGFloat { return origin.x+size.width; }
		var		maxY : CGFloat { return origin.y+size.height; }
		init() {
			origin = (0.0,0.0);
			size = (0.0,0.0);
		}
		init(width: CGFloat, height: CGFloat) {
			origin = (0.0,0.0);
			size = (width,height);
		}
		init(x: CGFloat, y: CGFloat) {
			origin = (x,y);
			size = (0.0,0.0);
		}
		init(_ x: CGFloat, _ y: CGFloat,_ width: CGFloat, _ height: CGFloat) {
			origin = (x,y);
			size = (width,height);
		}
		init(minX aMinX: CGFloat, minY aMinY: CGFloat, maxX aMaxX: CGFloat, maxY aMaxY: CGFloat) {
			self.init(aMinX, aMinY,aMaxX-aMinX, aMaxY-aMinY);
		}
		func rect(for o: Orientation, bounds b: NSRect ) -> NSRect {
			switch o {
			case .vertical: return NSMakeRect(origin.x,origin.y,size.width,size.height);
			case .horizontal: return NSMakeRect(origin.y,b.maxY-size.width-origin.x,size.height,size.width);
			}
		}
		func size(for o: Orientation ) -> NSSize {
			switch o {
			case .vertical: return NSMakeSize(size.width,size.height);
			case .horizontal: return NSMakeSize(size.height,size.width);
			}
		}
		func point(for o: Orientation, bounds b: NSRect ) -> NSPoint {
			switch o {
			case .vertical: return NSMakePoint(origin.x,origin.y);
			case .horizontal: return NSMakePoint(origin.y,b.maxY-size.width-origin.x);
			}
		}

		func maxPoint(for o: Orientation, bounds b: NSRect ) -> NSPoint {
			switch o {
			case .vertical: return NSMakePoint(origin.x+size.width, origin.y+size.height);
			case .horizontal: return NSMakePoint(origin.y+size.height, b.maxY-size.width-origin.x+size.width);
			}
		}

		func inset( dX: CGFloat, dY: CGFloat ) -> Geometry {
			return Geometry(minX: minX+dX, minY: minY+dY, maxX: maxX-dX, maxY: maxY-dY);
		}

		static func intersection(_ a: Geometry, _ b: Geometry ) -> Geometry {
			return Geometry( minX: max(a.minX,b.minX), minY: max(a.minY,b.minY), maxX: min(a.maxX,b.maxX), maxY: min(a.maxY,b.maxY) );
		}
	}

	private static func length(_ v : NSControl.ControlSize) -> CGFloat {
		switch v {
		case .mini: return 48.0;
		case .small: return 64.0;
		case .regular: return 96.0;
		}
	}
	private static func accidentalLength(_ v : NSControl.ControlSize) -> CGFloat {
		switch v {
		case .mini: return 28.0;
		case .small: return 38.0;
		case .regular: return 58.0;
		}
	}
	private static func keyWidth(_ v : NSControl.ControlSize) -> CGFloat {
		switch v {
		case .mini: return 10.0;
		case .small: return 14.0;
		case .regular: return 18.0;
		}
	}
	private static func middleCMarkerSize(_ v : NSControl.ControlSize) -> CGSize {
		switch v {
		case .mini: return CGSize(width:4.0,height:4.0);
		case .small: return CGSize(width:6.0,height:6.0);
		case .regular: return CGSize(width:7.0,height:7.0);
		}
	}

	private static func numberOfWhiteKeys( forNumberOfKeys aNumberOfKeys : PianoKeyboardControl.NumberOfKeys ) -> Int {
		switch(aNumberOfKeys) {
		case .keys12: return 7;
		case .keys13: return 8;
		case .keys25: return 15;
		case .keys49: return 29;
		case .keys61: return 36;
		case .keys76: return 45;
		case .keys88: return 52;
		case .keys92: return 55;
		case .keys97: return 57;
		case .keysFull: return 75;
		}
	}

	internal static func noteNumberInOctave( forMidiNumber aNoteNumber: Int ) -> Int {
		return aNoteNumber%12;
	}
	internal static func octaveNumber( forMidiNumber aNoteNumber: Int ) -> Int {
		return aNoteNumber/12 - 1;
	}

	internal static func noteName( forNoteNumber aNoteNumber: Int ) -> String {
		let kNoteName = [ "C", "C♯/D♭", "D", "D♯/E♭", "E", "F", "F♯/G♭", "G", "G♯/A♭", "A", "A♯/B♭♭", "B" ];
		return kNoteName[aNoteNumber%kNoteName.count];
	}

	internal static func noteName( forMidiNoteNumber aNoteNumber: Int ) -> String {
		return "\(noteName( forNoteNumber: aNoteNumber ))\(octaveNumber( forMidiNumber: aNoteNumber ))";
	}

	internal static func isNatural( forMidiNoteNumber aNoteNumber: Int ) -> Bool {
		switch noteNumberInOctave(forMidiNumber: aNoteNumber) {
		case 1, 3, 6, 8, 10:
			return false;
		default:
			return true;
		}
	}

	private static func naturalNoteNumber( forMidiNoteNumber aNoteNumber: Int ) -> Int? {
		let		theNoteNumber = noteNumberInOctave( forMidiNumber: aNoteNumber );
		switch theNoteNumber {
		case 0, 2, 4:
			return theNoteNumber/2 + aNoteNumber/12*7;
		case 5, 7, 9, 11:
			return theNoteNumber/2 + 1 + aNoteNumber/12*7;
		default:
			return nil;
		}
	}

	private static func midiNotNumber( forNaturalNoteNumber aNoteNumber : Int ) -> Int {
		let		theNoteNumber = aNoteNumber%7;
		switch theNoteNumber
		{
		case 0...2:
			return theNoteNumber*2 + aNoteNumber/7*12;
		default:
			return theNoteNumber*2 - 1 + aNoteNumber/7*12;
		}
	}

	public static func frequency( forMidiNoteNumber aMidiNotNumber: Int ) -> Double {
		return A440Frequency*pow(2.0,(Double(aMidiNotNumber-A440MidiNumber))/12.0);
	}

	public static func midiNoteNumber(forFrequency aFrequency: Double) -> Int {
		return Int(12.0 * log(aFrequency/A440Frequency)/log(2)+0.5)+A440MidiNumber;
	}

	private var		trackingArea : NSTrackingArea?
	public var		numberOfKeys : PianoKeyboardControl.NumberOfKeys {
		set { (cell as! PianoKeyboardControl.Cell).numberOfKeys = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).numberOfKeys; }
	}
	public var		orientation : PianoKeyboardControl.Orientation {
		set { (cell as! PianoKeyboardControl.Cell).orientation = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).orientation; }
	}
	public var		selection : IndexSet? {
		set { (cell as! PianoKeyboardControl.Cell).selection = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).selection; }
	}
	public var		hilightedKey : Int? {
		set { (cell as! PianoKeyboardControl.Cell).hilightedKey = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).hilightedKey; }
	}

	@IBInspectable public var		allowsMultipleSelection : Bool {
		set { (cell as! PianoKeyboardControl.Cell).allowsMultipleSelection = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).allowsMultipleSelection; }
	}
	@IBInspectable public var		allowsDiscontinuousSelection : Bool {
		set { (cell as! PianoKeyboardControl.Cell).allowsDiscontinuousSelection = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).allowsDiscontinuousSelection; }
	}
	@IBInspectable public var		pushOnPushOff : Bool {
		set { (cell as! PianoKeyboardControl.Cell).pushOnPushOff = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).pushOnPushOff; }
	}
	@IBInspectable public var		showSelectedKeys : Bool {
		set { (cell as! PianoKeyboardControl.Cell).showSelectedKeys = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).showSelectedKeys; }
	}
	@IBInspectable public var		emptySelectionAllowed : Bool {
		set { (cell as! PianoKeyboardControl.Cell).emptySelectionAllowed = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).emptySelectionAllowed; }
	}
	@IBInspectable public var		showMiddleC : Bool {
		set { (cell as! PianoKeyboardControl.Cell).showMiddleC = newValue; }
		get { return (cell as! PianoKeyboardControl.Cell).showMiddleC; }
	}

	public var		selectedFrequency : Double? {
		return (cell as! PianoKeyboardControl.Cell).selectedFrequency;
	}
	public var		selectedOctave : Int? {
		return (cell as! PianoKeyboardControl.Cell).selectedOctave;
	}
	@IBInspectable override public var		controlSize : NSControl.ControlSize {
		get { return (cell as! PianoKeyboardControl.Cell).controlSize; }
		set {
			(cell as! PianoKeyboardControl.Cell).controlSize = newValue;
		}
	}

	override public func sizeToFit() {
		var		theFrame = frame;
		theFrame.size = (cell as! PianoKeyboardControl.Cell).cellSize;
		frame = theFrame;
	}

	override public init(frame aFrameRect: NSRect) {
		super.init(frame: aFrameRect);
		cell = PianoKeyboardControl.Cell();
		cell?.controlView = self;
		cell?.target = self;
		cell?.action = #selector(performClick(_:));
		orientation = frame.height > frame.width ? .vertical : .horizontal;
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder);
		cell = PianoKeyboardControl.Cell();
		cell?.controlView = self;
		cell?.target = self;
		cell?.action = #selector(performClick(_:));
		orientation = frame.height > frame.width ? .vertical : .horizontal;
	}

	override public func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview();
//		self.controlSize = controlSize;
		if let theTrackingArea = trackingArea {
			removeTrackingArea(theTrackingArea);
		}
		trackingArea = NSTrackingArea(rect: NSZeroRect, options: [.inVisibleRect,.mouseMoved,.mouseEnteredAndExited,.activeAlways], owner: self, userInfo: nil);
	}

	override public var intrinsicContentSize: NSSize {
		return NSSize(width:PianoKeyboardControl.length(controlSize) + CGFloat(8.0), height:CGFloat(PianoKeyboardControl.numberOfWhiteKeys(forNumberOfKeys: numberOfKeys)) * PianoKeyboardControl.keyWidth(controlSize) + 3.0 );
	}

	override public func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
		cell?.drawInterior(withFrame: bounds, in: self);
    }

	override public func mouseMoved(with anEvent: NSEvent) {
		let		thePoint = convert(anEvent.locationInWindow, from: nil);
		if NSPointInRect(thePoint, bounds) {
			cell?.continueTracking(last: thePoint, current: thePoint, in: self);
		} else {
		}
		needsDisplay = true;
	}

	override public func mouseExited(with anEvent: NSEvent) {
		let		thePoint = convert(anEvent.locationInWindow, from:nil);
		cell?.stopTracking(last: thePoint, current: thePoint, in: self, mouseIsUp: false);
		needsDisplay = true;
	}

	override public func mouseDown(with anEvent: NSEvent) {
		let		thePoint = convert(anEvent.locationInWindow, from:nil);
		if NSPointInRect(thePoint, self.bounds)  {
			cell?.startTracking(at: thePoint, in: self)
		}
	}

	override public func mouseUp(with anEvent: NSEvent) {
		let		thePoint = convert(anEvent.locationInWindow, from:nil);
		cell?.stopTracking(last: thePoint, current: thePoint, in: self, mouseIsUp: true);
	}

	override public var integerValue : Int {
		get {
			return selection?.min() ?? NSNotFound;
		}
		set {
			selection = IndexSet(integer: newValue);
		}
	}
	override public var stringValue : String {
		get {
			if let theMin = selection?.min() {
				return PianoKeyboardControl.noteName(forMidiNoteNumber: theMin );
			} else {
				return "";
			}
		}
		set {
			
		}
	}

	public class Cell: NSActionCell {

		private var			mouseDown = false;

		public override class var prefersTrackingUntilMouseUp: Bool {
			return true;
		}

		public override init() {
			super.init();
			controlSize = .small;						//		NSRegularControlSize|NSSmallControlSize|NSControlSizeMini;
		}

		public required init(coder: NSCoder) {
			super.init(coder: coder);
			controlSize = .small;						//		NSRegularControlSize|NSSmallControlSize|NSControlSizeMini;
		}

		public var		numberOfKeys : PianoKeyboardControl.NumberOfKeys = .keys88 {
			didSet {
				if let theControlView = controlView {
					theControlView.superview?.setNeedsDisplay(theControlView.frame);
				}
			}
		}
		public var		orientation : PianoKeyboardControl.Orientation = .vertical;
		public var		selection : IndexSet? {
			willSet {
				willChangeValue(forKey:"selection");
				willChangeValue(forKey:"integerValue");
				willChangeValue(forKey:"stringValue");
				willChangeValue(forKey:"selectedFrequency");
				willChangeValue(forKey:"selectedOctave");
			}
			didSet {
				didChangeValue(forKey:"selectedOctave");
				didChangeValue(forKey:"selectedFrequency");
				didChangeValue(forKey:"stringValue");
				didChangeValue(forKey:"integerValue");
				didChangeValue(forKey:"selection");
			}
		}
		public var		hilightedKey : Int?;

		public var		allowsMultipleSelection : Bool = true;
		public var		allowsDiscontinuousSelection : Bool = true;
		public var		pushOnPushOff : Bool = false;
		public var		showSelectedKeys : Bool = false;
		public var		emptySelectionAllowed : Bool = true;
		public var		showMiddleC : Bool = true {
			didSet {
				controlView?.needsDisplay = true;
			}
		}

		public var		selectedFrequency : Double? {
			if let theIndex = selection?.min() {
				return PianoKeyboardControl.frequency( forMidiNoteNumber: theIndex );
			} else {
				return nil;
			}
		}
		public var		selectedOctave : Int? {
			if let theIndex = selection?.min() {
				return PianoKeyboardControl.octaveNumber( forMidiNumber: theIndex);
			} else {
				return nil;
			}
		}

		var		range : ClosedRange<Int> {
			switch numberOfKeys {
			case .keys12: return 60...71;
			case .keys13: return 60...72;
			case .keys25: return 48...72;
			case .keys49: return 36...84;
			case .keys61: return 36...96;
			case .keys76: return 28...103;
			case .keys88: return 21...108;
			case .keys92: return 16...108;
			case .keys97: return 12...108;
			case .keysFull: return 0...127;
			}
		}

		public override var cellSize: NSSize {
			let		theKeyWidth = PianoKeyboardControl.keyWidth(controlSize);
			let		theLength = PianoKeyboardControl.length(controlSize);
			return Geometry( width: theLength-2.0, height: CGFloat(PianoKeyboardControl.numberOfWhiteKeys(forNumberOfKeys: numberOfKeys)) * theKeyWidth + 1.0 ).size(for: orientation);
		}
		private func frame(forKeyNumber aMidiKeyNumber: Int )-> Geometry {
			guard let	theKeyLocation = range.min() else {
				return Geometry();
			}
			let		theIsNatual = PianoKeyboardControl.isNatural(forMidiNoteNumber: aMidiKeyNumber );
			guard let theMax = PianoKeyboardControl.naturalNoteNumber(forMidiNoteNumber: aMidiKeyNumber - (theIsNatual ? 0 : 1) ) else {
				return Geometry();
			}
			guard let theMin = PianoKeyboardControl.naturalNoteNumber(forMidiNoteNumber: theKeyLocation ) else {
				return Geometry();
			}
			let		theNaturalNoteOffset = theMax - theMin;

			var		theResult = Geometry();
			let		theKeyWidth = PianoKeyboardControl.keyWidth(controlSize);
			let		theLength = PianoKeyboardControl.length(controlSize);
			if theIsNatual {
				theResult = Geometry(1.0, CGFloat(theNaturalNoteOffset) * theKeyWidth + 1.0, theLength-4.0, theKeyWidth);
			}
			else {
				let theAccidentalLength = PianoKeyboardControl.accidentalLength(controlSize);
				theResult = Geometry(1.0, (CGFloat(theNaturalNoteOffset) + 0.5)*theKeyWidth+3.0, theAccidentalLength, theKeyWidth-3.0);
				switch aMidiKeyNumber%12 {
				case 1: theResult.origin.y -= 1.0;
				case 3: theResult.origin.y += 1.0;
				case 6: theResult.origin.y -= 1.5;
				case 10: theResult.origin.y += 1.5;
				default: break;
				}
			}
			return theResult;
		}

		private func rectangles(forKeyNumber aMidiKeyNumber: Int ) -> (Geometry,Geometry?) {			// this method is not reentraint
			var		theResult : (Geometry,Geometry?) = (frame(forKeyNumber:aMidiKeyNumber),nil);

			if PianoKeyboardControl.isNatural(forMidiNoteNumber:aMidiKeyNumber) {
				let		theRangeOfKeys = range;
				theResult.1 = theResult.0;

				if !PianoKeyboardControl.isNatural(forMidiNoteNumber:aMidiKeyNumber-1) && aMidiKeyNumber-1 > theRangeOfKeys.min()! {
					let		theIntersectionRect = Geometry.intersection(frame(forKeyNumber:aMidiKeyNumber-1),theResult.0);
					theResult.0.size.height -= theIntersectionRect.height;
					theResult.0.origin.y += theIntersectionRect.height;
				}

				if( !PianoKeyboardControl.isNatural(forMidiNoteNumber:aMidiKeyNumber+1) && aMidiKeyNumber+1 < theRangeOfKeys.max()! )
				{
					let	theIntersectionRect = Geometry.intersection(frame(forKeyNumber:aMidiKeyNumber+1),theResult.0);
					theResult.0.size.height -= floor(theIntersectionRect.height);
				}
			}
			return theResult;
		}

		private let	strokeColor = NSColor.black;
		private let	fillColor = NSColor.white;

		private func keyColor(forMidiNoteNumber aMidiNoteNumber: Int, isSelected aSelected: Bool) -> NSColor {
			var		theWhite : CGFloat = 0.6;
			if PianoKeyboardControl.isNatural(forMidiNoteNumber:aMidiNoteNumber) {
				theWhite = 0.5;
			}
			if aSelected && pushOnPushOff {
				theWhite -= 0.2;
			}
			return NSColor.init(white: theWhite, alpha: 1.0);
		}

		public override func startTracking(at aStartPoint: NSPoint, in aControlView: NSView) -> Bool {
			hilightedKey = midiKeyNumber(at:aStartPoint, frame: aControlView.bounds);
			mouseDown = true;
			aControlView.needsDisplay = true;
			return hilightedKey != nil;
		}

		public override func continueTracking(last aLastPoint: NSPoint, current aCurrentPoint: NSPoint, in aControlView: NSView) -> Bool {
			hilightedKey = midiKeyNumber(at:aCurrentPoint, frame: aControlView.bounds);
			aControlView.needsDisplay = true;
			return hilightedKey != nil;
		}

		public override func stopTracking(last aLastPoint: NSPoint, current aStopPoint: NSPoint, in aControlView: NSView, mouseIsUp aMouseIsUp: Bool) {
			hilightedKey = nil;
			if aMouseIsUp  {
				if let theSelectedKey = midiKeyNumber(at:aStopPoint, frame: aControlView.bounds) {
					if allowsMultipleSelection && allowsDiscontinuousSelection && ((mouseDownFlags & Int(NSEvent.ModifierFlags.option.rawValue) != 0) || pushOnPushOff) {
						var		theNewSelection = selection ?? IndexSet();
						if selection?.contains(theSelectedKey) ?? false {
							theNewSelection.remove(theSelectedKey);
							if emptySelectionAllowed || !theNewSelection.isEmpty {
								selection = theNewSelection;
							}
						} else {
							theNewSelection.insert(theSelectedKey);
							selection = theNewSelection;
						}
					} else if allowsMultipleSelection && (mouseDownFlags & Int(NSEvent.ModifierFlags.shift.rawValue) != 0) {
						if let theMin = selection?.min(), let theMax = selection?.max() {
							if theSelectedKey < theMin {
								selection = IndexSet(integersIn: theSelectedKey...theMax);
							} else if theSelectedKey > theMax {
								selection = IndexSet(integersIn: theMin...theSelectedKey);
							}
						} else {
							selection = IndexSet(integer:theSelectedKey);
						}
					} else if !allowsMultipleSelection && pushOnPushOff {
						if selection?.contains(theSelectedKey) ?? false && emptySelectionAllowed {
							selection = nil;
						} else {
							selection = IndexSet(integer:theSelectedKey);
						}
					} else {
						selection = IndexSet(integer:theSelectedKey);
					}
					aControlView.needsDisplay = true;
					(aControlView as! NSControl).sendAction(action, to: target);
				}
			}
			mouseDown = false;
		}

		public override func drawInterior(withFrame aCellFrame: NSRect, in aControlView: NSView) {
			guard let theContext = NSGraphicsContext.current?.cgContext else {
				return;
			}
			let theKeyWidth = PianoKeyboardControl.keyWidth(controlSize);
			let theLength = PianoKeyboardControl.length(controlSize);
			let theAccidentalLength = PianoKeyboardControl.accidentalLength(controlSize);

			func drawBackground(context aCGContext: CGContext ) {
				aCGContext.beginPath();
				let			theFrame = Geometry( 0.0, 0.0, theLength-2.0, CGFloat(PianoKeyboardControl.numberOfWhiteKeys(forNumberOfKeys: numberOfKeys)) * theKeyWidth + 1.0 );
				aCGContext.addRect(theFrame.rect(for: orientation,bounds:aCellFrame));
				aCGContext.setFillColor(fillColor.cgColor);
				let		thePath = aCGContext.path!;
				aCGContext.fillPath();
				aCGContext.addPath(thePath);
				aCGContext.setStrokeColor( strokeColor.cgColor );
				aCGContext.setLineWidth( 2.0 );
				aCGContext.strokePath();
			}

			func addRectangles(forKeyNumber anIndex:Int, to aCGContext: CGContext ) {
				let		theRects = rectangles(forKeyNumber:anIndex);
				aCGContext.addRect( theRects.0.rect(for: orientation, bounds: aCellFrame) );
				if let theSecondRect = theRects.1 {
					aCGContext.addRect( theSecondRect.rect(for: orientation, bounds: aCellFrame) );
				}
			}

			func draw(selectedKeys aSelected: IndexSet, context aCGContext: CGContext ) {
				aCGContext.beginPath();
				for theIndex in aSelected {
					if PianoKeyboardControl.isNatural(forMidiNoteNumber:theIndex) {
						addRectangles(forKeyNumber:theIndex, to: aCGContext )
					}
				}
				aCGContext.setFillColor( NSColor.controlAccentColor.cgColor );
				aCGContext.fillPath();

				aCGContext.beginPath();
				for theIndex in aSelected {
					if !PianoKeyboardControl.isNatural(forMidiNoteNumber:theIndex) {
						addRectangles(forKeyNumber:theIndex, to: aCGContext )
					}
				}
				aCGContext.setFillColor( NSColor.alternateSelectedControlColor.cgColor );
				aCGContext.fillPath();
			}
			func draw(hilightedKey aHilightedKey: Int, context aCGContext: CGContext ) {
				let		theIsSelectionHilightedKey = selection?.contains(aHilightedKey) ?? false;
				aCGContext.beginPath();
				addRectangles(forKeyNumber:aHilightedKey, to: aCGContext )
				aCGContext.closePath();
				aCGContext.setFillColor(keyColor(forMidiNoteNumber: aHilightedKey, isSelected: theIsSelectionHilightedKey).cgColor);
				if PianoKeyboardControl.isNatural(forMidiNoteNumber:aHilightedKey) {
					aCGContext.fillPath();
				} else {
					aCGContext.setStrokeColor(strokeColor.cgColor);
					aCGContext.setLineWidth(1.0 );
					aCGContext.fillPath();
				}
			}

			func drawKeyBoarders(between aRange: ClosedRange<Int>, context aCGContext: CGContext ) {
				guard let theRangeMax = aRange.max() else {
					return;
				}

				aCGContext.beginPath();
				for i in aRange {
					let		theKeyFrame = frame(forKeyNumber:i);

					if PianoKeyboardControl.isNatural(forMidiNoteNumber:i) {
						var		thePoint = Geometry(minX:theKeyFrame.minX,minY:theKeyFrame.maxY + 0.5,maxX:theKeyFrame.maxX,maxY:theKeyFrame.maxY + 0.5);
						if !PianoKeyboardControl.isNatural(forMidiNoteNumber:i+1) || i >= theRangeMax {
							thePoint.origin.x = theKeyFrame.minX+theAccidentalLength;
						}
						aCGContext.move(to:thePoint.point(for: orientation,bounds: aCellFrame));
						aCGContext.addLine(to: thePoint.maxPoint(for: orientation,bounds: aCellFrame));
					}
				}
				aCGContext.setStrokeColor( strokeColor.cgColor );
				aCGContext.setLineWidth(1.0 );
				aCGContext.strokePath();
			}

			func drawAccidentals(between aRange: ClosedRange<Int>, context aCGContext: CGContext ) {
				aCGContext.beginPath();
				for i in aRange {
					let		theIsSelectionHilightedKey = selection?.contains(i) ?? false;
					let		theIsHilightedKey = hilightedKey != nil && hilightedKey! == i;
					if !PianoKeyboardControl.isNatural(forMidiNoteNumber:i) && (!theIsSelectionHilightedKey || (!pushOnPushOff && !showSelectedKeys)) && !theIsHilightedKey {
						aCGContext.addRect( frame(forKeyNumber:i).rect(for: orientation,bounds:aCellFrame) );
					}
				}
				aCGContext.setFillColor( strokeColor.cgColor );
				aCGContext.fillPath();
			}

			func drawMiddleC(context aCGContext: CGContext) {
				let		theSize = PianoKeyboardControl.middleCMarkerSize(controlSize);
				var		theMarkerFrame = frame(forKeyNumber:60).rect(for: orientation,bounds:aCellFrame);
				theMarkerFrame.origin.x += theMarkerFrame.size.width - floor(theSize.width*1.75);
				theMarkerFrame.origin.y += ceil((theKeyWidth - theSize.height)/2.0);
				theMarkerFrame.size = theSize;
				aCGContext.beginPath();
				aCGContext.addEllipse(in: theMarkerFrame );
				aCGContext.setFillColor( strokeColor.cgColor );
				aCGContext.fillPath();
			}

			theContext.setShouldAntialias(true);
			drawBackground(context: theContext );
			/*
			draw selected Keys
			*/
			if let theSelection = selection,
				theSelection.count > 0 && (pushOnPushOff || showSelectedKeys) {
					draw(selectedKeys: theSelection, context: theContext );
			}

			/*
			draw hilighted key
			*/
			if let theHilightedKey = hilightedKey {
				draw(hilightedKey: theHilightedKey, context: theContext );
			}

			/*
			draw Keys
			*/
			let		theKeyRange = range;
			drawKeyBoarders(between: theKeyRange, context: theContext );
			drawAccidentals(between: theKeyRange, context: theContext );

			if showMiddleC {
				drawMiddleC(context:theContext);
			}

		}

		public func midiKeyNumber(at aPoint: NSPoint, frame aCellFrame: NSRect ) -> Int? {
			let		theKeyRange = range;
			let theKeyWidth = PianoKeyboardControl.keyWidth(controlSize);
			guard let theRangeMin = theKeyRange.min() else {
				return nil;
			}
			guard let theRangeMax = theKeyRange.max() else {
				return nil;
			}
			guard let theNaturalNoteNumber = PianoKeyboardControl.naturalNoteNumber(forMidiNoteNumber: theRangeMin ) else {
				return nil;
			}
			let		thePos = orientation == .vertical ? aPoint.y : aPoint.x;
			var		theWhiteKey = Int(thePos/theKeyWidth)+theNaturalNoteNumber;
			let		theOctave = theWhiteKey/7;

			var		theResult = 0;

			theWhiteKey %= 7;

			switch theWhiteKey {
			case 0, 1, 2:
				theResult = 2*theWhiteKey + theOctave*12;
			default:
				theResult = 2*theWhiteKey - 1 + theOctave*12;
			}
			let	 theSharpFrame = frame(forKeyNumber:theResult+1).rect(for: orientation,bounds:aCellFrame);
			if NSPointInRect(aPoint, theSharpFrame) {
				theResult += 1;
			}
			else {
				let	 theFlatFrame = frame(forKeyNumber:theResult-1).rect(for: orientation,bounds:aCellFrame);
				if NSPointInRect(aPoint, theFlatFrame) {
					theResult -= 1;
				}
			}

			if theResult < theRangeMin || theResult > theRangeMax {
				return nil;
			}
			return theResult;
		}

		public override func copy(with zone: NSZone? = nil) -> Any {
			let		theResult = Cell();
			theResult.numberOfKeys = numberOfKeys;
			theResult.orientation = orientation;
			theResult.allowsMultipleSelection = allowsMultipleSelection;
			theResult.allowsDiscontinuousSelection = allowsDiscontinuousSelection;
			theResult.pushOnPushOff = pushOnPushOff;
			theResult.showSelectedKeys = showSelectedKeys;
			theResult.emptySelectionAllowed = emptySelectionAllowed;
			theResult.showMiddleC = showMiddleC;
			return theResult;
		}

	}
}
