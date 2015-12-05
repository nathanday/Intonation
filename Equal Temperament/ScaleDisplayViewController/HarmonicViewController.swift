//
//  HarmonicViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class HarmonicViewController : NSViewController, ScaleDisplayViewController {

	var	harmonicView : HarmonicView? {
		var		theResult : HarmonicView? = nil;
		if self.view is HarmonicView {
			theResult = (self.view as! HarmonicView);
		}
		assert(theResult != nil, "Failed to get HarmonicView")
		return theResult;
	}

	func setIntervals( intervals anIntervals : [EqualTemperamentEntry], intervalCount anIntervalCount : UInt, enabled anEnable : Bool ) { }
	func hideIntervalRelatedColumn( aHide : Bool ) { }

	func setSelectionIntervals( aSelectionIntervals : [Interval]) {
		if let theHarmonicView = harmonicView {
			theHarmonicView.selectedRatios = aSelectionIntervals.map({ return $0.ratio; });
		}
	}

}
