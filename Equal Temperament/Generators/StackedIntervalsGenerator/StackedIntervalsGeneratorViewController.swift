//
//  StackedIntervalsGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 24/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class StackedIntervalsGeneratorViewController: GeneratorViewController {

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "StackedIntervalsGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
        if let theStackedIntervalSetBaseString = UserDefaults.standard.string(forKey: "stackedIntervalSetBaseString") {
            stackedIntervalSetBaseString = theStackedIntervalSetBaseString;
        } else {
            stackedIntervalSetBaseString = "3:2";
        }
		stackedIntervalSetSteps = UInt(UserDefaults.standard.integer(forKey: "stackedIntervalSetSteps"));
		if stackedIntervalSetSteps == 0 {
			stackedIntervalSetSteps = 7;
		}
		stackedIntervalSetOctaves = UInt(UserDefaults.standard.integer(forKey: "stackedIntervalSetOctaves"));
        if stackedIntervalSetOctaves == 0 {
            stackedIntervalSetOctaves = 12;
        }
	}

	@IBOutlet var stackedIntervalsTableView: NSTableView!
    @objc dynamic var	stackedIntervalSetBaseString : String = "3:2" {
        didSet {
            UserDefaults.standard.set(stackedIntervalSetBaseString, forKey:"stackedIntervalSetBaseString");
        }
    }
	@objc dynamic var	stackedIntervalSetSteps : UInt = 7 {
		didSet {
			UserDefaults.standard.set(Int(stackedIntervalSetSteps), forKey:"stackedIntervalSetSteps");
		}
	}
	@objc dynamic var	stackedIntervalSetOctaves : UInt = 12 {
		didSet {
			UserDefaults.standard.set(Int(stackedIntervalSetSteps), forKey:"stackedIntervalSetOctaves");
		}
	}

	var _sortedStackIntervalSets : [StackedIntervalSet]?
	var sortedStackIntervalSets : [StackedIntervalSet]? {
		if _sortedStackIntervalSets == nil {
			if let theData = document?.intervalsData as? StackedIntervalsIntervalsData {
				_sortedStackIntervalSets = theData.stackedIntervals.sorted { (a:StackedIntervalSet, b:StackedIntervalSet) -> Bool in
					return a.interval < b.interval;
				}
			}
		}
		return _sortedStackIntervalSets;
	}

	var stackedIntervalSet : StackedIntervalSet? {
		get {
			var		theResult : StackedIntervalSet?;
            if var theInterval = Interval.from(string:stackedIntervalSetBaseString) {
                while theInterval < 1 {
                    theInterval *= 2;
                }
                theResult = StackedIntervalSet( interval: theInterval, steps: stackedIntervalSetSteps, octaves: stackedIntervalSetOctaves );
            }
			return theResult;
		}
		set {
			if let theValue = newValue {
				stackedIntervalSetBaseString = theValue.interval.toString;
				stackedIntervalSetSteps = theValue.steps;
				stackedIntervalSetOctaves = theValue.octaves;
			}
		}
	}

	var selectedStackedIntervalSet : StackedIntervalSet? {
		if let theSortedStackIntervalSets = _sortedStackIntervalSets {
			let		theRow = stackedIntervalsTableView.selectedRow;
			if theRow >= 0 && theRow < theSortedStackIntervalSets.count {
				return theSortedStackIntervalSets[theRow];
			}
		}
		return nil;
	}

	@IBAction func delete( _ aSender: Any?) {
		if let theSelectedStackedIntervalSet = selectedStackedIntervalSet {
			removeStackedIntervalSet(theSelectedStackedIntervalSet);
		}
	}

	@IBAction func addStackIntervalAction( _ aSender: Any ) {
		if let theStackedIntervalSet = stackedIntervalSet {
			addStackedIntervalSet(theStackedIntervalSet);
		}
	}
	
	@objc dynamic var		stackedIntervalsExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "stackedIntervalsExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "stackedIntervalsExpanded"); }
	}
	func addStackedIntervalSet( _ aStackedInterval : StackedIntervalSet ) {
		if let theData = document?.intervalsData as? StackedIntervalsIntervalsData {
			theData.insertStackedInterval(aStackedInterval);
			document?.calculateAllIntervals();
			reloadStackedIntervalsTable();
		}
	}

	func removeStackedIntervalSet( _ aStackedInterval : StackedIntervalSet ) {
		if let theData = document?.intervalsData as? StackedIntervalsIntervalsData {
			theData.removeStackedInterval(aStackedInterval);
			document?.calculateAllIntervals();
			reloadStackedIntervalsTable();
		}
	}

	internal func reloadStackedIntervalsTable() {
		_sortedStackIntervalSets = nil;
		stackedIntervalsTableView.reloadData();
	}
}

extension StackedIntervalsGeneratorViewController : NSTableViewDataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		guard let theData = document?.intervalsData as? StackedIntervalsIntervalsData else {
			return 0;
		}
		return theData.stackedIntervals.count;
	}

	public func tableView(_ aTable: NSTableView, objectValueFor aTableColumn: NSTableColumn?, row aRow: Int) -> Any?
	{
		var		theResult : Any?
		if let theSortedStackIntervalSet = sortedStackIntervalSets?[aRow] {
			if aTableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"interval") {
				theResult = theSortedStackIntervalSet.interval.ratioString;
			}
			else if aTableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"steps") {
				theResult = theSortedStackIntervalSet.steps;
			}
			else if aTableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"octaves") {
				theResult = theSortedStackIntervalSet.octaves;
			}
		}
		return theResult;
	}

	func tableView(_ aTable: NSTableView, setObjectValue anObject: Any?, for aTableColumn: NSTableColumn?, row aRow: Int) {
		if let theSortedStackIntervalSet = sortedStackIntervalSets?[aRow] {
			if aTableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"steps") {
				if let theIntegerValue = anObject as? UInt {
					theSortedStackIntervalSet.steps = theIntegerValue;
				}
			}
			else if aTableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"octaves") {
				if let theIntegerValue = anObject as? UInt {
					theSortedStackIntervalSet.octaves =  theIntegerValue;
				}
			}
			document?.calculateAllIntervals();
			reloadStackedIntervalsTable();
		}
	}
}

extension StackedIntervalsGeneratorViewController : NSTableViewDelegate {
	func tableView( _ aTableView: NSTableView, shouldEdit aTableColumn: NSTableColumn?, row aRow: Int) -> Bool {
		let		theColumns : Set<String> = ["steps","octaves"];
		guard let theTableColumn = aTableColumn else {
			return false
		}
		return theColumns.contains(theTableColumn.identifier.rawValue);
	}
}

extension StackedIntervalsIntervalsData {
	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return StackedIntervalsGeneratorViewController(windowController:aWindowController);
	}
}
