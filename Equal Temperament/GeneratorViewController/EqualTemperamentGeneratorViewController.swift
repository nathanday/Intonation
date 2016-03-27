//
//  EqualTemperamentGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class EqualTemperamentGeneratorViewController: GeneratorViewController {
	var		originalInterval : RationalInterval = RationalInterval(2);
	override var nibName: String? { return "EqualTemperamentGeneratorViewController"; }

	override func viewDidLoad() {
		originalInterval = document!.intervalsData.equalTemperamentInterval;
		document!.intervalsData.addObserver(self, forKeyPath:"equalTemperamentInterval", options: NSKeyValueObservingOptions.Prior, context:nil)
	}

	deinit {
		document!.intervalsData.removeObserver(self, forKeyPath:"equalTemperamentInterval");
	}

	override func observeValueForKeyPath( aKeyPath: String?, ofObject anObject: AnyObject?, change aChange: [String : AnyObject]?, context aContext: UnsafeMutablePointer<Void>) {
		if anObject as? IntervalsData == document!.intervalsData {
			if let theKey = aKeyPath {
				if theKey == "equalTemperamentDegrees" {
					if aChange?[NSKeyValueChangeNotificationIsPriorKey] != nil {
						willChangeValueForKey("equalTemperamentIntervalString");

					} else {
						didChangeValueForKey("equalTemperamentIntervalString");
					}
				}
			}
		}
	}

	var		octaveInterval : Bool = true {
		didSet {
			if octaveInterval {
				originalInterval = document!.intervalsData.equalTemperamentInterval;
				document!.intervalsData.equalTemperamentInterval = RationalInterval(2);
			} else {
				document!.intervalsData.equalTemperamentInterval = originalInterval;
			}
		}
	}


	var equalTemperamentIntervalString : String {
		get {
			return document?.intervalsData.equalTemperamentInterval.toString ?? "";
		}
		set {
			if let theValue = RationalInterval.fromString(newValue) {
				document!.intervalsData.equalTemperamentInterval = theValue;
			}
		}
	}

	@IBAction func changeDegreesAction( aSender: NSPopUpButton) {
		self.document!.intervalsData.equalTemperamentDegrees = UInt(aSender.selectedTag());
	}
}
