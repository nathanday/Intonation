//
//  EqualTemperamentGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class EqualTemperamentGeneratorViewController: GeneratorViewController {
	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "EqualTemperamentGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var		originalInterval : RationalInterval = RationalInterval(2);

	override func viewDidLoad() {
		let		theIntervalsData = document!.intervalsData as! EqualTemperamentIntervalsData;
		originalInterval = theIntervalsData.interval;
		theIntervalsData.addObserver(self, forKeyPath:"interval", options: NSKeyValueObservingOptions.Prior, context:nil)
	}

	deinit {
		(document!.intervalsData as! EqualTemperamentIntervalsData).removeObserver(self, forKeyPath:"interval");
	}

	override func observeValueForKeyPath( aKeyPath: String?, ofObject anObject: AnyObject?, change aChange: [String : AnyObject]?, context aContext: UnsafeMutablePointer<Void>) {
		if anObject as? IntervalsData == document!.intervalsData {
			if let theKey = aKeyPath {
				if theKey == "degrees" {
					if aChange?[NSKeyValueChangeNotificationIsPriorKey] != nil {
						willChangeValueForKey("intervalString");

					} else {
						didChangeValueForKey("intervalString");
					}
				}
			}
		}
	}

	var		octaveInterval : Bool = true {
		didSet {
			let		theIntervalsData = document!.intervalsData as! EqualTemperamentIntervalsData;
			if octaveInterval {
				originalInterval = theIntervalsData.interval;
				theIntervalsData.interval = RationalInterval(2);
			} else {
				theIntervalsData.interval = originalInterval;
			}
		}
	}


	var intervalString : String {
		get {
			return (document!.intervalsData as! EqualTemperamentIntervalsData).interval.ratio.ratioString ?? "";
		}
		set {
			if let theValue = RationalInterval.fromString(newValue) {
				(document!.intervalsData as! EqualTemperamentIntervalsData).interval = theValue;
			}
		}
	}

	@IBAction func changeDegreesAction( aSender: NSPopUpButton) {
		(document!.intervalsData as! EqualTemperamentIntervalsData).degrees = UInt(aSender.selectedTag());
	}
}
