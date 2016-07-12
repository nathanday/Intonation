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

	override func viewDidLoad() {
		if let theIntervalsData = document?.intervalsData as? EqualTemperamentIntervalsData {
			theIntervalsData.addObserver(self, forKeyPath:"interval", options: NSKeyValueObservingOptions.prior, context:nil);
		}
	}

	deinit {
		(document!.intervalsData as! EqualTemperamentIntervalsData).removeObserver(self, forKeyPath:"interval");
	}

	override func observeValue( forKeyPath aKeyPath: String?, of anObject: AnyObject?, change aChange: [NSKeyValueChangeKey : AnyObject]?, context aContext: UnsafeMutablePointer<Void>?) {
		if anObject as? IntervalsData == document!.intervalsData {
			if let theKey = aKeyPath {
				if theKey == "degrees" {
					if aChange?[NSKeyValueChangeKey.notificationIsPriorKey] != nil {
						willChangeValue(forKey: "intervalString");

					} else {
						didChangeValue(forKey: "intervalString");
					}
				}
			}
		}
	}

	@IBAction func setOctaveAction( _ aSender : NSButton ) {
		if let theIntervalsData = document?.intervalsData as? EqualTemperamentIntervalsData {
			willChangeValue(forKey: "intervalString");
			theIntervalsData.interval = RationalInterval(2);
			didChangeValue(forKey: "intervalString");
		}
	}

	var intervalString : String {
		get {
			return (document!.intervalsData as! EqualTemperamentIntervalsData).interval.ratio.ratioString ?? "";
		}
		set {
			if let theValue = RationalInterval.from(string:newValue) {
				(document!.intervalsData as! EqualTemperamentIntervalsData).interval = theValue;
				document?.calculateAllIntervals();
			}
		}
	}

	@IBAction func changeDegreesAction( _ aSender: NSPopUpButton) {
		(document!.intervalsData as! EqualTemperamentIntervalsData).degrees = UInt(aSender.selectedTag());
	}
}
