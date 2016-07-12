//
//  FindIntervalsViewController.swift
//  Intonation
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
	dynamic var			centErrorsString : String = "";

	var	windowController : MainWindowController? {
		return self.view.window?.windowController as? MainWindowController
	}

	var				findMethod = IntervalsFindMethod.findMethodClosest;
	var				searchValueHaseRoot = true;
	var				searchTransposeToFit = true;

	var				ratios : [Interval] {
		get {
			func	getIntervalValues() -> [Double] {
				var		theResult = [Double]();
				for theString in ratiosString.components(separatedBy: CharacterSet(charactersIn:":∶ ")) {
					if theString.contains("/") {
						let		theComponents = theString.components(separatedBy: "/");
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
			func isInteger( _ aValue : Double ) -> Bool { return aValue == floor(aValue); }

			var		theResult : [Interval] = [];
			let		theComponents = getIntervalValues();
			if theComponents.count == 1 {
				theResult.append(IrrationalInterval(theComponents[0]));
			} else if theComponents.count == 2 && isInteger(theComponents[0]) && isInteger(theComponents[1]) && theComponents[0] > theComponents[1] {
				theResult.append(RationalInterval( Int(theComponents[0]), Int(theComponents[1])));
			} else if theComponents.count > 0 {
				let		theBase : Double = theComponents[0] ?? 1.0;
				for theEnumValue in theComponents {
					var		theValue = theEnumValue;
					while theValue < theBase {		// if a value is less than base then we need to move it n octaves
						theValue *= 2.0;
					}
					if isInteger(theValue) && isInteger(theBase) {
						theResult.append(RationalInterval( Int(theValue), Int(theBase)));
					} else {
						theResult.append(IrrationalInterval(theValue/theBase));
					}
				}
			}
			return theResult;
		}
	}

	var		centErrors : [Double] = [] {
		didSet {
			var		theCentErrorsString = "";
			for theCents in centErrors {
				if !theCentErrorsString.isEmpty {
					theCentErrorsString.append( ", " );
				}
				theCentErrorsString.append("\(theCents.toString(decimalPlaces:2)) ¢");
			}
			centErrorsString =  theCentErrorsString;
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
		theSearchMenu.addItem(withTitle: "Closest", action: #selector(FindIntervalsViewController.findMethodClosestAction(_:)), keyEquivalent: "").target = self;
		theSearchMenu.addItem(withTitle: "Exact", action: #selector(FindIntervalsViewController.findMethodExactAction(_:)), keyEquivalent: "").target = self;
		theSearchMenu.addItem(NSMenuItem.separator());

		theSearchMenu.addItem(withTitle: "Has Root", action: #selector(FindIntervalsViewController.searchValueHasRootChangedAction(_:)), keyEquivalent: "").target = self;

		theSearchMenu.addItem(withTitle: "Transpose To Fit", action: #selector(FindIntervalsViewController.searchTransposeToFitChangedAction(_:)), keyEquivalent: "").target = self;

		theSearchMenu.addItem(NSMenuItem.separator());

		theSearchMenu.addItem(withTitle: "Recent Searches", action: nil, keyEquivalent: "").tag = Int(NSSearchFieldRecentsTitleMenuItemTag);
		theSearchMenu.addItem(withTitle: "No recent searches", action: nil, keyEquivalent: "").tag = Int(NSSearchFieldNoRecentsMenuItemTag);
		theSearchMenu.addItem(withTitle: "Recents", action: nil, keyEquivalent: "").tag = Int(NSSearchFieldRecentsMenuItemTag);
		let		theRecentSeperator = NSMenuItem.separator();
		theSearchMenu.addItem(theRecentSeperator);
		theRecentSeperator.tag = Int(NSSearchFieldRecentsTitleMenuItemTag)
		theSearchMenu.addItem(withTitle: "Clear", action: nil, keyEquivalent: "").tag = Int(NSSearchFieldClearRecentsMenuItemTag);

		return theSearchMenu;
	}

	@IBAction override func dismiss( _ aSender: AnyObject? ) { hidden = true; }

	@IBAction func find( _ aSender: AnyObject? ) {
		performFindEntries();
	}

	@IBAction func findMethodClosestAction( _ aSender: AnyObject? ) {
		findMethod = .findMethodClosest;
		performFindEntries();
	}

	@IBAction func findMethodExactAction( _ aSender: AnyObject? ) {
		findMethod = .findMethodExact;
		performFindEntries();
	}

	@IBAction func searchValueHasRootChangedAction( _ aSender: AnyObject? ) {
		searchValueHaseRoot = !searchValueHaseRoot;
		performFindEntries();
	}

	@IBAction func searchTransposeToFitChangedAction( _ aSender: AnyObject? ) {
		searchTransposeToFit = !searchTransposeToFit;
		performFindEntries();
	}

	func performFindEntries() {
		if let theDocument = windowController?.document as? Document {
			let			theSearchIntervals = theDocument.everyInterval;
			let			theNumberOfOctaves = theDocument.intervalsData!.octavesCount;

			switch findMethod {
			case .findMethodClosest:
				(theDocument.selectedEqualTemperamentEntry,centErrors) = findClosestEntries(ratios, searchIntervales:theSearchIntervals, octaves:theNumberOfOctaves);
			case .findMethodExact:
				(theDocument.selectedEqualTemperamentEntry,centErrors) = findClosestEntries(ratios, searchIntervales:theSearchIntervals, octaves:theNumberOfOctaves);
				//				theDocument.selectedEqualTemperamentEntry = findExactEntries(ratios);
			}
		}
	}

	dynamic override func validateMenuItem( _ aMenuItem: NSMenuItem) -> Bool {
		switch aMenuItem.action {
		case (#selector(FindIntervalsViewController.findMethodClosestAction(_:)))?:
			aMenuItem.state = findMethod == .findMethodClosest ? NSOnState : NSOffState;
		case (#selector(FindIntervalsViewController.findMethodExactAction(_:)))?:
			aMenuItem.state = findMethod == .findMethodExact ? NSOnState : NSOffState;
		case (#selector(FindIntervalsViewController.searchValueHasRootChangedAction(_:)))?:
			aMenuItem.state = searchValueHaseRoot ? NSOnState : NSOffState;
		case (#selector(FindIntervalsViewController.searchTransposeToFitChangedAction(_:)))?:
			aMenuItem.state = searchTransposeToFit ? NSOnState : NSOffState;
		default:
			assertionFailure("Got selector \(aMenuItem.action)");
		}
		return true;
	}

	func findExactEntries( _ anRationals : [Interval], searchIntervales aSearchIntervales: [EqualTemperamentEntry], octaves anOctaves: UInt ) -> [EqualTemperamentEntry] {
		var		theResult = Array<EqualTemperamentEntry>();
		for theRatio in anRationals {
			var		theClosestEntry : EqualTemperamentEntry?
			for theInterval in aSearchIntervales {
				if let theCurrentInterval = theClosestEntry?.interval {
					if theCurrentInterval == theRatio {
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

	func findClosestEntries( _ anIntervals : [Interval], searchIntervales aSearchIntervales: [EqualTemperamentEntry], octaves anOctaves: UInt ) -> ([EqualTemperamentEntry],[Double]) {
		return findEntries( anIntervals, searchIntervales: aSearchIntervales, octaves: anOctaves) {
			(intervalA:Interval,intervalB:Interval,inputRatio:Interval) -> Bool in
			var		theInputRatio = inputRatio.toDouble;
			while theInputRatio > Double(anOctaves+1) {
				theInputRatio /= 2.0;
			}
			return abs((intervalA.toDouble) - theInputRatio) > abs(intervalB.toDouble - theInputRatio);
		}
	}

	func findEntries( _ anIntervals : [Interval], searchIntervales aSearchIntervales: [EqualTemperamentEntry], octaves anOctaves: UInt, _ aMethod: (Interval,Interval,Interval) -> Bool ) -> ([EqualTemperamentEntry],[Double]) {
		var		theResult = [EqualTemperamentEntry]();
		var		theResultErrors = [Double]();
		for theInterval in anIntervals {
			var		theClosestEntry : EqualTemperamentEntry?
			for theCompareEntry in aSearchIntervales {
				if searchTransposeToFit || theCompareEntry.interval.toDouble <= pow(2.0,Double(anOctaves)) {
					if let theCurrentInterval = theClosestEntry?.interval {
						if aMethod(theCurrentInterval,theCompareEntry.interval,theInterval) {
							theClosestEntry = theCompareEntry;
						}
					} else {
						theClosestEntry = theCompareEntry;
					}
				}
			}
			if let theFoundEntry = theClosestEntry {
				theResult.append(theFoundEntry);
				theResultErrors.append(theFoundEntry.toCents-theInterval.toDouble.toCents);
			}
		}
		return (theResult,theResultErrors);
	}

}

extension FindIntervalsViewController : NSTextFieldDelegate {
	internal func textDidChange(notification: Notification) {
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
