//
//  ScaleViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ScaleViewController: NSViewController, ScaleDisplayViewController {

	@IBOutlet var	linearScaleView : ScaleView?;
	@IBOutlet var	pitchConstellationView : ScaleView?;

	dynamic var		selectedScaleDisplayType : Int {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setInteger(aValue, forKey: "selectedScaleDisplayType"); }
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedScaleDisplayType"); }
	}


	func setIntervals( intervals anIntervals : [EqualTemperamentEntry], intervalCount anIntervalCount : UInt, enabled anEnable : Bool ) {
		if let theLinearScaleView = linearScaleView {
			theLinearScaleView.numberOfIntervals = anEnable ? anIntervalCount : 0;
			theLinearScaleView.everyRatios = anIntervals.map { return $0.interval; };
			theLinearScaleView.useIntervals = anEnable;
		}
		if let thePitchConstellationView = pitchConstellationView {
			thePitchConstellationView.numberOfIntervals = anEnable ? anIntervalCount : 0;
			thePitchConstellationView.everyRatios = anIntervals.map { return $0.interval; };
			thePitchConstellationView.useIntervals = anEnable;
		}
	}

	func hideIntervalRelatedColumn( aHide : Bool ) {
		linearScaleView?.useIntervals = !aHide;
		pitchConstellationView?.useIntervals = !aHide;
	}

	func setSelectionIntervals( aSelectionIntervals : [Interval]) {
		linearScaleView?.selectedRatios = aSelectionIntervals;
		pitchConstellationView?.selectedRatios = aSelectionIntervals;
	}

}
