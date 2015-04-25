//
//  DisclosureView.swift
//  Equal Temperament
//
//  Created by Nathan Day on 26/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

class DisclosureView : NSView {
	enum Orientation {
		case vertical
		case horizontal
	}

	var		orientation : DisclosureView.Orientation = .vertical;
	var		colapsed = false {
		didSet {
			invalidateIntrinsicContentSize();
		}
	}

	override var	hidden : Bool {
		didSet {
			colapsed = self.hidden;
		}
	}

	private(set) var		expandedSize : NSSize;
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
			return colapsed ? colapsedSize : expandedSize;
		}
	}

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

	@IBAction func colapse( aSender : AnyObject? ) { colapsed = true; }
	@IBAction func expand( aSender : AnyObject? ) { colapsed = false; }
	@IBAction func toggle( aSender : AnyObject? ) { colapsed = !colapsed; }
}
