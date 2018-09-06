//
//  HarmonicSeriesGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class HarmonicSeriesGeneratorViewController: GeneratorViewController {

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "HarmonicSeriesGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc dynamic var octave : Int {
		get {
			return (document!.intervalsData as! HarmonicSeriesIntervalsData).octave;
		}
		set {
			(document!.intervalsData as! HarmonicSeriesIntervalsData).octave = newValue;
			document?.calculateAllIntervals();
		}
	}
}
