//
//  ViewControllerPlaceHolderView.swift
//  NDViewControllerPlaceHolderView_swift
//
//  Created by Nathan Day on 5/12/15.
//  Copyright © 2015 Nathaniel Day. All rights reserved.
//

import Cocoa

class ViewControllerPlaceHolderView : NSView {

	@IBOutlet weak var	viewController : NSViewController?

	override func awakeFromNib() {
		placeRepresentitiveView();
	}

	func loadViewController( _ aViewController : NSViewController ) {
		if viewController != aViewController {
			viewController?.view.removeFromSuperview();
			viewController = aViewController;
			placeRepresentitiveView();
		}
	}

	private func placeRepresentitiveView()
	{
		if let theView = viewController?.view {
			theView.frame = self.bounds;
			theView.autoresizingMask = [ .viewWidthSizable, .viewHeightSizable ];
			addSubview(theView);
		}
	}
}
