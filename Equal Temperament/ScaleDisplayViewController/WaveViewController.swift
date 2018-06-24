//
//  WaveViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class WaveViewController: ResultViewController {

	@IBOutlet var		waveView : WaveView?;

	override func awakeFromNib() {
		super.awakeFromNib();
		waveView?.dataSource = self;
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		updateWaveViewDisplayMode();
		updateWaveViewScale();
	}


	@objc dynamic var		selectedWaveViewMode : Int {
		set(aValue) {
			UserDefaults.standard.set(aValue, forKey: "selectedWaveViewMode");
			updateWaveViewDisplayMode();
		}
		get { return UserDefaults.standard.integer(forKey: "selectedWaveViewMode"); }
	}

	@objc dynamic var		selectedWaveViewScale : Int {
		set( aValue ) {
			UserDefaults.standard.set(aValue, forKey: "selectedWaveViewScale");
			updateWaveViewScale();
		}
		get { return UserDefaults.standard.integer(forKey: "selectedWaveViewScale"); }
	}

	func setIntervals( intervals anIntervals : [IntervalEntry], degree anDegree : Int, enabled anEnable : Bool ) {
	}

	override func hideIntervalRelatedColumn( _ aHide : Bool ) {
	}

	override func selectionChanged(notification aNotification: Notification ) {
		waveView?.reloadData();
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
