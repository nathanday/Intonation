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

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "AdHokGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var adHocInterval : Interval? {
		get {
			var		theResult : Interval?;
			if let theInterval = adHocIntervalTextField?.stringValue {
				theResult = Interval.from(string:theInterval);
			}
			return theResult;
		}
		set {
			if let theValue = newValue?.toString {
				adHocIntervalTextField?.stringValue = theValue;
			}
		}
	}

	@IBAction func addAdHocIntervalAction( _ aSender: AnyObject ) {
		if let theInterval = adHocInterval {
			addInterval(theInterval);
		}
	}

	@IBAction func delete( _ aSender: AnyObject?) {
		if let theDocument = document {
			removeIntervals(theDocument.selectedJustIntonationIntervals);
		}
	}
	@IBAction func paste( _ aSender: AnyObject ) {
		let		theEntries = NSPasteboard.general().readObjects(forClasses: [EqualTemperamentEntry.self], options: nil) as? [EqualTemperamentEntry];
		NSLog( "\(theEntries)" );
	}
	func addInterval( _ anInterval : Interval ) {
		addIntervals( [anInterval] );
	}
	func addIntervals( _ anIntervals : [Interval] ) {
		if let theDocument = document {
			for theInterval in anIntervals {
				(document!.intervalsData as! AdHocIntervalsData).adHocEntries.insert(theInterval);
			}
			theDocument.calculateAllIntervals();
		}
	}

	func removeInterval( _ anInterval : Interval ) {
		removeIntervals( [anInterval] );
	}
	func removeIntervals( _ anIntervals : [Interval] ) {
		if let theDocument = document {
			for theInterval in anIntervals {
				(document!.intervalsData as! AdHocIntervalsData).adHocEntries.remove(theInterval);
			}
			theDocument.calculateAllIntervals();
		}
	}
	
}
