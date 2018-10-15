//
//  SpectrumViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class SpectrumViewController: ResultViewController {

	@IBOutlet var		spectrumView : SpectrumView?;

	override func awakeFromNib() {
		super.awakeFromNib();
		spectrumView?.dataSource = self;
	}

	@objc dynamic var		selectedSpectrumType : Int {
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

	func setIntervals( intervals anIntervals : [IntervalEntry], degree anIntervalCount : UInt, enabled anEnable : Bool ) { }
	override func hideIntervalRelatedColumn( _ aHide : Bool ) { }
	override func selectionChanged(notification aNotification: Notification ) {
		spectrumView?.reloadData();
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
