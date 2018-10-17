//
//  ScaleViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ScaleViewController: ResultViewController {

	@IBOutlet var		linearScaleView : ScaleView?;
	@IBOutlet var		pitchConstellationView : ScaleView?;

	override func awakeFromNib() {
		super.awakeFromNib();
		linearScaleView?.dataSource = self;
//		linearScaleView?.delegate = self;
		pitchConstellationView?.dataSource = self;
//		pitchConstellationView?.delegate = self;
	}

	@objc dynamic var		selectedScaleDisplayType : Int {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "selectedScaleDisplayType"); }
		get { return UserDefaults.standard.integer(forKey: "selectedScaleDisplayType"); }
	}


	func setIntervals( intervals anIntervals : [IntervalEntry], degree anIntervalCount : Int, enabled anEnable : Bool ) {
		if let theLinearScaleView = linearScaleView {
			theLinearScaleView.numberOfIntervals = anEnable ? anIntervalCount : 0;
//			theLinearScaleView.everyRatios = anIntervals.map { return $0.interval; };
			theLinearScaleView.useIntervals = anEnable;
		}
		if let thePitchConstellationView = pitchConstellationView {
			thePitchConstellationView.numberOfIntervals = anEnable ? anIntervalCount : 0;
//			thePitchConstellationView.everyRatios = anIntervals.map { return $0.interval; };
			thePitchConstellationView.useIntervals = anEnable;
		}
	}

	override  func hideIntervalRelatedColumn( _ aHide : Bool ) {
		linearScaleView?.useIntervals = !aHide;
		pitchConstellationView?.useIntervals = !aHide;
	}

	override func selectionChanged(notification aNotification: Notification ) {
		linearScaleView?.reloadData();
		pitchConstellationView?.reloadData();
	}
}

extension ScaleViewController : ResultViewDelegate {
	func resultView( _ resultView: ResultView, willSelectIntervalAtIndex anIndex: Int ) {

	}
	func resultView( _ resultView: ResultView, didSelectIntervalAtIndex anIndex: Int ) {
		mainWindowController.arrayController.addSelectionIndexes(IndexSet(integer:anIndex));
	}
	func resultView( _ resultView: ResultView, willDeselectIntervalAtIndex anIndex: Int ) {

	}
	func resultView( _ resultView: ResultView, didDeselectIntervalAtIndex anIndex: Int ) {
		mainWindowController.arrayController.removeSelectionIndexes(IndexSet(integer:anIndex));
	}
}

