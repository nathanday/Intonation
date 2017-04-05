//
//  WaveViewController.swift
//  Intonation
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
			UserDefaults.standard.set(aValue, forKey: "selectedWaveViewMode");
			updateWaveViewDisplayMode();
		}
		get { return UserDefaults.standard.integer(forKey: "selectedWaveViewMode"); }
	}

	dynamic var		selectedWaveViewScale : Int {
		set( aValue ) {
			UserDefaults.standard.set(aValue, forKey: "selectedWaveViewScale");
			updateWaveViewScale();
		}
		get { return UserDefaults.standard.integer(forKey: "selectedWaveViewScale"); }
	}

	func setIntervals( intervals anIntervals : [IntervalEntry], degree anDegree : UInt, enabled anEnable : Bool ) {
	}

	func hideIntervalRelatedColumn( _ aHide : Bool ) {
	}

	func setSelectionIntervals( _ aSelectionIntervals : [Interval]) {
		waveView?.selectedRatios = aSelectionIntervals;
	}

	private func updateWaveViewDisplayMode() {
		switch selectedWaveViewMode {
		case 1:
			waveView?.displayMode = .combined;
		default:
			waveView?.displayMode = .overlayed;
		}
	}

	private func updateWaveViewScale() {
		switch selectedWaveViewScale {
		case 1:
			waveView?.xScale = 50.0;
		case 2:
			waveView?.xScale = 100.0;
		default:
			waveView?.xScale = 25.0;
		}
	}
}
