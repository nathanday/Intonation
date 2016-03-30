//
//  AdHokGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 24/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class AdHokGeneratorViewController: GeneratorViewController {

	@IBOutlet var	adHocIntervalTextField : NSTextField?;
	override var nibName: String? { return "AdHokGeneratorViewController"; }

	var adHocInterval : Interval? {
		get {
			var		theResult : Interval?;
			if let theInterval = adHocIntervalTextField?.stringValue {
				theResult = Interval.fromString(theInterval);
			}
			return theResult;
		}
		set {
			if let theValue = newValue?.toString {
				adHocIntervalTextField?.stringValue = theValue;
			}
		}
	}

	@IBAction func addAdHocIntervalAction( aSender: AnyObject ) {
		if let theInterval = adHocInterval {
			addInterval(theInterval);
		}
	}

	@IBAction func delete( aSender: AnyObject?) {
		if let theDocument = document {
			removeIntervals(theDocument.selectedJustIntonationIntervals);
		}
	}
	func addInterval( anInterval : Interval ) {
		addIntervals( [anInterval] );
	}
	func addIntervals( anIntervals : [Interval] ) {
		if let theDocument = document {
			for theInterval in anIntervals {
				(document!.intervalsData as! AdHocIntervalsData).adHocEntries.insert(theInterval);
			}
			theDocument.calculateAllIntervals();
		}
	}

	func removeInterval( anInterval : Interval ) {
		removeIntervals( [anInterval] );
	}
	func removeIntervals( anIntervals : [Interval] ) {
		if let theDocument = document {
			for theInterval in anIntervals {
				(document!.intervalsData as! AdHocIntervalsData).adHocEntries.remove(theInterval);
			}
			theDocument.calculateAllIntervals();
		}
	}
	
}
