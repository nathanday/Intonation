/*
	DisclosureView.swift
	Intonation

	Created by Nathan Day on 26/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

class DisclosureView : NSView {
	enum Orientation {
		case vertical
		case horizontal
	}

	@IBOutlet var		complimentaryView : NSView?

	var		orientation : DisclosureView.Orientation = .vertical;
	var		colapsed : Bool {
		get { return hidden; }
		set( aValue ) { hidden = aValue; }
	}

	override var	hidden : Bool {
		didSet {
			complimentaryView?.hidden = !hidden;
			invalidateIntrinsicContentSize();
			var		theOrientation = NSLayoutConstraintOrientation.Vertical;
			var		thePriority = expandedContentHuggingPriority;
			if( orientation  == .horizontal ) {
				theOrientation = .Horizontal;
			}
			if( hidden ) {
				thePriority = NSLayoutPriorityDefaultHigh;
			}
			super.setContentHuggingPriority(thePriority, forOrientation: theOrientation);
		}
	}

	private(set) var		expandedSize : NSSize;
	@IBInspectable	var		expandedContentHuggingPriority : Float = NSLayoutPriorityDefaultLow;
	var						colapsedSize : NSSize {
		get {
			switch( orientation ) {
			case .vertical:
				return NSMakeSize(expandedSize.width, 0.0);
			case .horizontal:
				return NSMakeSize(0.0,expandedSize.height);
			}
		}
	}
	override var intrinsicContentSize: NSSize {
		get {
			switch( orientation ) {
			case .vertical:
				return NSMakeSize( NSViewNoInstrinsicMetric, colapsed ? colapsedSize.height : expandedSize.height);
			case .horizontal:
				return NSMakeSize(colapsed ? colapsedSize.width : expandedSize.width, NSViewNoInstrinsicMetric );
			}
		}
	}

	override var fittingSize : NSSize { get { return intrinsicContentSize; } }

	override init(frame aFrameRect: NSRect) {
		expandedSize = aFrameRect.size;
		super.init(frame: aFrameRect);
	}

	required init?(coder aCoder: NSCoder) {
		expandedSize = NSMakeSize(0.0, 0.0);
		super.init(coder: aCoder);
		expandedSize = self.frame.size;
	}

	override var frame : NSRect {
		didSet {
			if colapsed {
				switch( orientation ) {
				case .vertical:
					if self.frame.size.width != expandedSize.width {
						expandedSize = NSMakeSize(self.frame.size.width, expandedSize.height);
					}
				case .horizontal:
					if self.frame.size.height != expandedSize.height {
						expandedSize = NSMakeSize(expandedSize.width,self.frame.size.height);
					}
				}
			}
			else {
				expandedSize = self.frame.size;
			}
		}
	}

	override func setContentHuggingPriority(aPriority: NSLayoutPriority, forOrientation anOrientation: NSLayoutConstraintOrientation) {
		if !colapsed {
			switch( orientation ) {
			case .vertical:
				if( anOrientation == .Vertical ) {
					expandedContentHuggingPriority = contentHuggingPriorityForOrientation(.Vertical);
				}
			case .horizontal:
				if( anOrientation == .Horizontal ) {
					expandedContentHuggingPriority = contentHuggingPriorityForOrientation(.Horizontal);
				}
			}
		}
		super.setContentHuggingPriority(aPriority, forOrientation: anOrientation);
	}

	@IBAction func colapse( aSender : AnyObject? ) { colapsed = true; }
	@IBAction func expand( aSender : AnyObject? ) { colapsed = false; }
	@IBAction func toggle( aSender : AnyObject? ) { colapsed = !colapsed; }

//	override func drawRect(aDirtyRect: NSRect) {
//		NSColor(calibratedRed: 0.5, green: 0.75, blue: 1.0, alpha: 1.0).setFill();
//		NSRectFill(aDirtyRect);
//	}
}
