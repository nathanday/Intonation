//
//  WaveViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class WaveViewController: NSViewController, ScaleDisplayViewController {

	@IBOutlet var	waveView : WaveView?;

	override func viewWillAppear() {
		super.viewWillAppear()
		updateWaveViewDisplayMode();
		updateWaveViewScale();
	}


	dynamic var		selectedWaveViewMode : Int {
		set(aValue) {
			NSUserDefaults.standardUserDefaults().setInteger(aValue, forKey: "selectedWaveViewMode");
			updateWaveViewDisplayMode();
		}
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedWaveViewMode"); }
	}

	dynamic var		selectedWaveViewScale : Int {
		set( aValue ) {
			NSUserDefaults.standardUserDefaults().setInteger(aValue, forKey: "selectedWaveViewScale");
			updateWaveViewScale();
		}
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedWaveViewScale"); }
	}

	func setIntervals( intervals anIntervals : [EqualTemperamentEntry], intervalCount anIntervalCount : UInt, enabled anEnable : Bool ) {
	}

	func hideIntervalRelatedColumn( aHide : Bool ) {
	}

	func setSelectionIntervals( aSelectionIntervals : [Interval]) {
		if let theWaveView = waveView {
			theWaveView.selectedRatios = aSelectionIntervals.map({ return $0.ratio; });
		}
	}

	private func updateWaveViewDisplayMode() {
		if let theWaveView = waveView {
			switch selectedWaveViewMode {
			case 1:
				theWaveView.displayMode = .combined;
			default:
				theWaveView.displayMode = .overlayed;
			}
		}
	}

	private func updateWaveViewScale() {
		if let theWaveView = waveView {
			switch selectedWaveViewScale {
			case 1:
				theWaveView.xScale = 50.0;
			case 2:
				theWaveView.xScale = 100.0;
			default:
				theWaveView.xScale = 25.0;
			}
		}
	}
}
