//
//  FindIntervalsViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 28/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class FindIntervalsViewController: NSViewController {
	@IBOutlet weak var	document : Document? = nil;
	dynamic var			hidden : Bool = true {
		didSet {
			NSUserDefaults.standardUserDefaults().setBool( hidden, forKey:"findIntervalesHidded");
		}
	}
	dynamic var		findMethod : Int = 0;
	dynamic var		ratiosString : String = "";

	var				ratios : [Double] {
		get {
			var		theResult : [Double] = [];
			var		theComponents = ratiosString.componentsSeparatedByString(":");
			var		theBase : Double = 1.0;
			if let theValue = Double(theComponents[0]) {
				theBase = theValue;
			}
			for theComp in theComponents {
				if let theValue = Double(theComp) {
					theResult.append(theValue/theBase);
				}
			}
			return theResult;
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		hidden = NSUserDefaults.standardUserDefaults().boolForKey("findIntervalesHidded");
    }

	@IBAction override func dismissController( aSender: AnyObject? ) { hidden = true; }

	@IBAction func find( aSender: AnyObject? ) {
		if let theDocument = document {
			switch findMethod {
			case 0:
				theDocument.selectedEqualTemperamentEntry = findClosestEntries(ratios);
			default:
				theDocument.selectedEqualTemperamentEntry = findClosestEntries(ratios);
//				theDocument.selectedEqualTemperamentEntry = findExactEntries(ratios);
			}
		}
	}

	func findExactEntries( anRationals : [Rational] ) -> [EqualTemperamentEntry] {
		var		theResult = Array<EqualTemperamentEntry>();
		if let theDocument = document {
			for theRatio in anRationals {
				var		theClosestEntry : EqualTemperamentEntry?
				for theInterval in theDocument.everyInterval {
					if let theCurrentInterval = theClosestEntry?.interval {
						if theCurrentInterval.ratio == theRatio {
							theClosestEntry = theInterval;
						}
					} else {
						theClosestEntry = theInterval;
					}
				}
				if let theFoundEntry = theClosestEntry {
					theResult.append(theFoundEntry);
				}
			}
		}
		return theResult;
	}

	func findClosestEntries( anIntervals : [Double] ) -> [EqualTemperamentEntry] {
		var		theResult = Array<EqualTemperamentEntry>();
		if let theDocument = document {
			for theRatio in anIntervals {
				var		theClosestEntry : EqualTemperamentEntry?
				for theInterval in theDocument.everyInterval {
					if let theCurrentInterval = theClosestEntry?.interval {
						if abs((theCurrentInterval.ratio.toDouble) - theRatio) > abs(theInterval.interval.ratio.toDouble - theRatio) {
							theClosestEntry = theInterval;
						}
					} else {
						theClosestEntry = theInterval;
					}
				}
				if let theFoundEntry = theClosestEntry {
					theResult.append(theFoundEntry);
				}
			}
		}
		return theResult;
	}

}
