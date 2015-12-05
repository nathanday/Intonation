//
//  ViewControllerPlaceHolderView.swift
//  NDViewControllerPlaceHolderView_swift
//
//  Created by Nathan Day on 5/12/15.
//  Copyright © 2015 Nathaniel Day. All rights reserved.
//

import Cocoa

class ViewControllerPlaceHolderView : NSView {

	@IBOutlet var	viewController : NSViewController?;

	override func awakeFromNib() { placeRepresentitiveView(); }

	func placeRepresentitiveView()
	{
		if let theView = viewController?.view {
			theView.frame = self.bounds;
			theView.autoresizingMask = [ .ViewWidthSizable, .ViewHeightSizable ];
			addSubview(theView);
		}
	}
}
