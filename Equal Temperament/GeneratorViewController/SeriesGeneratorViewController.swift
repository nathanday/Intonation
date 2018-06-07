//
//  SeriesGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class SeriesGeneratorViewController: GeneratorViewController {

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "SeriesGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		if let theIntervalsData = document?.intervalsData as? SeriesIntervalsData {
			theIntervalsData.addObserver(self, forKeyPath:"steps", options: NSKeyValueObservingOptions.prior, context:nil);
		}
	}

	deinit {
		(document!.intervalsData as! SeriesIntervalsData).removeObserver(self, forKeyPath:"steps");
	}

	@objc dynamic var stepSize : Double {
		get {
			return (document!.intervalsData as! SeriesIntervalsData).stepSize;
		}
		set {
			(document!.intervalsData as! SeriesIntervalsData).stepSize = newValue;
			document?.calculateAllIntervals();
		}
	}

	@objc dynamic var steps : UInt {
		get {
			return (document!.intervalsData as! SeriesIntervalsData).steps;
		}
		set {
			(document!.intervalsData as! SeriesIntervalsData).steps = newValue;
			document?.calculateAllIntervals();
		}
	}

	@IBAction func changeStepsAction( _ aSender: NSPopUpButton) {
		(document!.intervalsData as! SeriesIntervalsData).steps = UInt(aSender.selectedTag());
	}
}
