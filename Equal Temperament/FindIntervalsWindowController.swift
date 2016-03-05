//
//  FindIntervalsViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 28/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

enum IntervalsFindMethod {
	case findMethodClosest;
	case findMethodExact;
}

class FindIntervalsViewController: NSViewController {
	@IBOutlet weak var	searchField : NSSearchField? = nil;
	dynamic var			hidden : Bool = true;
	dynamic var			ratiosString : String = "";

	var	windowController : MainWindowController? {
		return self.view.window?.windowController as? MainWindowController
	}

	var				findMethod = IntervalsFindMethod.findMethodClosest;
	var				searchValueHaseRoot = true;
	var				searchTransposeToFit = true;

	var				ratios : [Ratio] {
		get {
			func	getRatioValues() -> [Double] {
				var		theResult = [Double]();
				for theString in ratiosString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:":∶ ")) {
					if theString.containsString("/") {
						let		theComponents = theString.componentsSeparatedByString("/");
						if let theNumerator = Double(theComponents[0]), theDenominator = Double(theComponents[1]) {
							if theNumerator != 0.0 && theDenominator != 0.0 {
								theResult.append(theNumerator/theDenominator);
							}
						}
					}
					else if let theValue = Double(theString){
						theResult.append(theValue);
					}
				}
				return theResult;
			}
			func isInteger( aValue : Double ) -> Bool { return aValue == floor(aValue); }

			var		theResult : [Ratio] = [];
			let		theComponents = getRatioValues();
			if theComponents.count == 1 {
				theResult.append(Ratio.irrational(theComponents[0]));
			} else if theComponents.count == 2 && isInteger(theComponents[0]) && isInteger(theComponents[1]) && theComponents[0] > theComponents[1] {
				theResult.append(Ratio.rational(Rational(Int(theComponents[0]),Int(theComponents[1]))));
			} else if theComponents.count > 0 {
				let		theBase : Double = theComponents[0] ?? 1.0;
				for theEnumValue in theComponents {
					var		theValue = theEnumValue;
					while theValue < theBase {		// if a value is less than base then we need to move it n octaves
						theValue *= 2.0;
					}
					if isInteger(theValue) && isInteger(theBase) {
						theResult.append(Ratio.rational(Rational(Int(theValue),Int(theBase))));
					} else {
						theResult.append(Ratio.irrational(theValue/theBase));
					}
				}
			}
			return theResult;
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		searchField?.searchMenuTemplate = createSearchMenu();
    }

	func showView() {
		hidden = false;
		self.view.window?.makeFirstResponder(searchField);
	}

	func createSearchMenu( ) -> NSMenu {
		let		theSearchMenu = NSMenu(title: "Search Menu");
		theSearchMenu.autoenablesItems = true;
		theSearchMenu.addItemWithTitle("Closest", action: #selector(FindIntervalsViewController.findMethodClosestAction(_:)), keyEquivalent: "")?.target = self;
		theSearchMenu.addItemWithTitle("Exact", action: #selector(FindIntervalsViewController.findMethodExactAction(_:)), keyEquivalent: "")?.target = self;
		theSearchMenu.addItem(NSMenuItem.separatorItem());

		theSearchMenu.addItemWithTitle("Has Root", action: #selector(FindIntervalsViewController.searchValueHasRootChangedAction(_:)), keyEquivalent: "")?.target = self;

		theSearchMenu.addItemWithTitle("Transpose To Fit", action: #selector(FindIntervalsViewController.searchTransposeToFitChangedAction(_:)), keyEquivalent: "")?.target = self;

		theSearchMenu.addItem(NSMenuItem.separatorItem());

		theSearchMenu.addItemWithTitle("Recent Searches", action: nil, keyEquivalent: "")?.tag = Int(NSSearchFieldRecentsTitleMenuItemTag);
		theSearchMenu.addItemWithTitle("No recent searches", action: nil, keyEquivalent: "")?.tag = Int(NSSearchFieldNoRecentsMenuItemTag);
		theSearchMenu.addItemWithTitle("Recents", action: nil, keyEquivalent: "")?.tag = Int(NSSearchFieldRecentsMenuItemTag);
		let		theRecentSeperator = NSMenuItem.separatorItem();
		theSearchMenu.addItem(theRecentSeperator);
		theRecentSeperator.tag = Int(NSSearchFieldRecentsTitleMenuItemTag)
		theSearchMenu.addItemWithTitle("Clear", action: nil, keyEquivalent: "")?.tag = Int(NSSearchFieldClearRecentsMenuItemTag);

		return theSearchMenu;
	}

	@IBAction override func dismissController( aSender: AnyObject? ) { hidden = true; }

	@IBAction func find( aSender: AnyObject? ) {
		performFindEntries();
	}

	@IBAction func findMethodClosestAction( aSender: AnyObject? ) {
		findMethod = .findMethodClosest;
		performFindEntries();
	}

	@IBAction func findMethodExactAction( aSender: AnyObject? ) {
		findMethod = .findMethodExact;
		performFindEntries();
	}

	@IBAction func searchValueHasRootChangedAction( aSender: AnyObject? ) {
		searchValueHaseRoot = !searchValueHaseRoot;
		performFindEntries();
	}

	@IBAction func searchTransposeToFitChangedAction( aSender: AnyObject? ) {
		searchTransposeToFit = !searchTransposeToFit;
		performFindEntries();
	}

	func performFindEntries() {
		if let theDocument = windowController?.document as? Document {
			let			theSearchIntervals = theDocument.everyInterval;
			let			theNumberOfOctaves = theDocument.intervalsData.octavesCount;

			switch findMethod {
			case .findMethodClosest:
				theDocument.selectedEqualTemperamentEntry = findClosestEntries(ratios, searchIntervales:theSearchIntervals, octaves:theNumberOfOctaves);
			case .findMethodExact:
				theDocument.selectedEqualTemperamentEntry = findClosestEntries(ratios, searchIntervales:theSearchIntervals, octaves:theNumberOfOctaves);
				//				theDocument.selectedEqualTemperamentEntry = findExactEntries(ratios);
			}
		}
	}

	dynamic override func validateMenuItem(aMenuItem: NSMenuItem) -> Bool {
		switch aMenuItem.action {
		case #selector(FindIntervalsViewController.findMethodClosestAction(_:)):
			aMenuItem.state = findMethod == .findMethodClosest ? NSOnState : NSOffState;
		case #selector(FindIntervalsViewController.findMethodExactAction(_:)):
			aMenuItem.state = findMethod == .findMethodExact ? NSOnState : NSOffState;
		case #selector(FindIntervalsViewController.searchValueHasRootChangedAction(_:)):
			aMenuItem.state = searchValueHaseRoot ? NSOnState : NSOffState;
		case #selector(FindIntervalsViewController.searchTransposeToFitChangedAction(_:)):
			aMenuItem.state = searchTransposeToFit ? NSOnState : NSOffState;
		default:
			assertionFailure("Got selector \(aMenuItem.action)");
		}
		return true;
	}

	func findExactEntries( anRationals : [Rational], searchIntervales aSearchIntervales: [EqualTemperamentEntry], octaves anOctaves: UInt ) -> [EqualTemperamentEntry] {
		var		theResult = Array<EqualTemperamentEntry>();
		for theRatio in anRationals {
			var		theClosestEntry : EqualTemperamentEntry?
			for theInterval in aSearchIntervales {
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
		return theResult;
	}

	func findClosestEntries( anIntervals : [Ratio], searchIntervales aSearchIntervales: [EqualTemperamentEntry], octaves anOctaves: UInt ) -> [EqualTemperamentEntry] {
		return findEntries( anIntervals, searchIntervales: aSearchIntervales, octaves: anOctaves) {
			(intervalA:Interval,intervalB:Interval,inputRatio:Ratio) -> Bool in
			var		theInputRatio = inputRatio.toDouble;
			while theInputRatio > Double(anOctaves+1) {
				theInputRatio /= 2.0;
			}
			return abs((intervalA.ratio.toDouble) - theInputRatio) > abs(intervalB.ratio.toDouble - theInputRatio);
		}
	}

	func findEntries( anIntervals : [Ratio], searchIntervales aSearchIntervales: [EqualTemperamentEntry], octaves anOctaves: UInt, _ aMethod: (Interval,Interval,Ratio) -> Bool ) -> [EqualTemperamentEntry] {
		var		theResult = Array<EqualTemperamentEntry>();
		for theRatio in anIntervals {
			var		theClosestEntry : EqualTemperamentEntry?
			for theInterval in aSearchIntervales {
				if (searchTransposeToFit || theInterval.interval.ratio <= Int(anOctaves)) {
					if let theCurrentInterval = theClosestEntry?.interval {
						if aMethod(theCurrentInterval,theInterval.interval,theRatio) {
							theClosestEntry = theInterval;
						}
					} else {
						theClosestEntry = theInterval;
					}
				}
			}
			if let theFoundEntry = theClosestEntry {
				theResult.append(theFoundEntry);
			}
		}
		return theResult;
	}

}

extension FindIntervalsViewController : NSTextFieldDelegate {
	internal func textDidChange(notification: NSNotification) {
		if let theSearchField = searchField {
			var		theResult = "";
			var		thePreviousWasColon = false;
			for theChar in theSearchField.stringValue.characters {
				if theChar >= "0" && theChar <= "9" {
					theResult.append(theChar);
				}
				else if theChar >= ":" && !thePreviousWasColon {
					theResult.append(theChar);
					thePreviousWasColon = true;
				}
			}
		}
	}
}