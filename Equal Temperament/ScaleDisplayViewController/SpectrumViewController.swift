//
//  SpectrumViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class SpectrumViewController: NSViewController {

	@IBOutlet var	spectrumView : SpectrumView?;

	dynamic var		selectedSpectrumType : Int {
		set( aValue ) {
			UserDefaults.standard.set( aValue, forKey: "selectedSpectrumType");
			updateSelectedSpectrumType();
		}
		get { return UserDefaults.standard.integer(forKey: "selectedSpectrumType"); }
	}

	override func viewWillAppear() {
        super.viewWillAppear()
		updateSelectedSpectrumType();
    }

	func setIntervals( intervals anIntervals : [EqualTemperamentEntry], degree anIntervalCount : UInt, enabled anEnable : Bool ) { }
	func hideIntervalRelatedColumn( _ aHide : Bool ) { }
	func setSelectionIntervals( _ aSelectionIntervals : [Interval]) {
		spectrumView?.selectedRatios = aSelectionIntervals;
	}

	private func updateSelectedSpectrumType() {
		switch selectedSpectrumType {
		case 1:
			spectrumView?.spectrumType = .saw;
		case 2:
			spectrumView?.spectrumType = .square;
		default:
			spectrumView?.spectrumType = .sine;
		}
	}
}
