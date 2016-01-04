//
//  HarmonicViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class HarmonicViewController : NSViewController, ScaleDisplayViewController {

	func setIntervals( intervals anIntervals : [EqualTemperamentEntry], intervalCount anIntervalCount : UInt, enabled anEnable : Bool ) { }
	func hideIntervalRelatedColumn( aHide : Bool ) { }

	func setSelectionIntervals( aSelectionIntervals : [Interval]) {
		if let theHarmonicView = self.view as? HarmonicView {
			theHarmonicView.selectedRatios = aSelectionIntervals.map({ return $0.ratio; });
		}
	}

}
