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

	var		orientation = Orientation.vertical;
	var		colapsed : Bool {
		get { return isHidden; }
		set( aValue ) { isHidden = aValue; }
	}

	override var	isHidden : Bool {
		didSet {
			complimentaryView?.isHidden = !isHidden;
			invalidateIntrinsicContentSize();
			var		theOrientation = NSLayoutConstraint.Orientation.vertical;
			var		thePriority = expandedContentHuggingPriority;
			if( orientation  == .horizontal ) {
				theOrientation = .horizontal;
			}
			if( isHidden ) {
				thePriority = NSLayoutConstraint.Priority.defaultHigh.rawValue;
			}
			super.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: thePriority), for: theOrientation);
		}
	}

	private(set) var		expandedSize : NSSize;
	@IBInspectable	var		expandedContentHuggingPriority : Float = NSLayoutConstraint.Priority.defaultLow.rawValue;
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
				return NSMakeSize( NSView.noIntrinsicMetric, colapsed ? colapsedSize.height : expandedSize.height);
			case .horizontal:
				return NSMakeSize(colapsed ? colapsedSize.width : expandedSize.width, NSView.noIntrinsicMetric );
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
		expandedSize = frame.size;
	}

	override var frame : NSRect {
		didSet {
			if colapsed {
				switch( orientation ) {
				case .vertical:
					if frame.size.width != expandedSize.width {
						expandedSize = NSMakeSize(frame.size.width, expandedSize.height);
					}
				case .horizontal:
					if frame.size.height != expandedSize.height {
						expandedSize = NSMakeSize(expandedSize.width,frame.size.height);
					}
				}
			}
			else {
				expandedSize = frame.size;
			}
		}
	}

	override func setContentHuggingPriority(_ aPriority: NSLayoutConstraint.Priority, for anOrientation: NSLayoutConstraint.Orientation) {
		if !colapsed {
			switch( orientation ) {
			case .vertical:
				if( anOrientation == .vertical ) {
					expandedContentHuggingPriority = contentHuggingPriority(for: .vertical).rawValue;
				}
			case .horizontal:
				if( anOrientation == .horizontal ) {
					expandedContentHuggingPriority = contentHuggingPriority(for: .horizontal).rawValue;
				}
			}
		}
		super.setContentHuggingPriority(aPriority, for: anOrientation);
	}

	@IBAction func colapse( _ aSender : Any? ) { colapsed = true; }
	@IBAction func expand( _ aSender : Any? ) { colapsed = false; }
	@IBAction func toggle( _ aSender : Any? ) { colapsed = !colapsed; }

//	override func drawRect(aDirtyRect: NSRect) {
//		NSColor(calibratedRed: 0.5, green: 0.75, blue: 1.0, alpha: 1.0).setFill();
//		NSRectFill(aDirtyRect);
//	}
}
