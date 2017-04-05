//
//  ScaleViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ScaleViewController: NSViewController, ScaleDisplayViewController {

	@IBOutlet var	linearScaleView : ScaleView?;
	@IBOutlet var	pitchConstellationView : ScaleView?;

	dynamic var		selectedScaleDisplayType : Int {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "selectedScaleDisplayType"); }
		get { return UserDefaults.standard.integer(forKey: "selectedScaleDisplayType"); }
	}


	func setIntervals( intervals anIntervals : [IntervalEntry], degree anIntervalCount : UInt, enabled anEnable : Bool ) {
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

	func hideIntervalRelatedColumn( _ aHide : Bool ) {
		linearScaleView?.useIntervals = !aHide;
		pitchConstellationView?.useIntervals = !aHide;
	}

	func setSelectionIntervals( _ aSelectionIntervals : [Interval]) {
		linearScaleView?.selectedRatios = aSelectionIntervals;
		pitchConstellationView?.selectedRatios = aSelectionIntervals;
	}

}
