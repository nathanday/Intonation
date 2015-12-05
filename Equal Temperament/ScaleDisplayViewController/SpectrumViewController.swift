//
//  SpectrumViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class SpectrumViewController: NSViewController {

	@IBOutlet var	spectrumView : SpectrumView?;

	dynamic var		selectedSpectrumType : Int {
		set( aValue ) {
			NSUserDefaults.standardUserDefaults().setInteger( aValue, forKey: "selectedSpectrumType");
			updateSelectedSpectrumType();
		}
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedSpectrumType"); }
	}

	override func viewWillAppear() {
        super.viewWillAppear()
		updateSelectedSpectrumType();
    }

	func setIntervals( intervals anIntervals : [EqualTemperamentEntry], intervalCount anIntervalCount : UInt, enabled anEnable : Bool ) { }
	func hideIntervalRelatedColumn( aHide : Bool ) { }
	func setSelectionIntervals( aSelectionIntervals : [Interval])
	{
		if let theSpectrumView = spectrumView {
			theSpectrumView.selectedRatios = aSelectionIntervals.map({ return $0.ratio; });
		}
	}

	private func updateSelectedSpectrumType() {
		if let theSpectrumView = spectrumView {
			switch selectedSpectrumType {
			case 1:
				theSpectrumView.spectrumType = .saw;
			case 2:
				theSpectrumView.spectrumType = .square;
			default:
				theSpectrumView.spectrumType = .sine;
			}
		}
	}
}
