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
		stackedIntervalSetSteps = UInt(UserDefaults.standard.integer(forKey: "stackedIntervalSetSteps"));
		if stackedIntervalSetSteps == 0 {
			stackedIntervalSetSteps = 7;
		}
		stackedIntervalSetOctaves = UInt(UserDefaults.standard.integer(forKey: "stackedIntervalSetOctaves"));
		if stackedIntervalSetOctaves == 0 {
			stackedIntervalSetOctaves = 12;
		}
	}

	@IBOutlet weak var stackedIntervalSetBaseTextField : NSTextField?;
	@IBOutlet weak var stackedIntervalsTableView: NSTableView!
	dynamic var	stackedIntervalSetSteps : UInt = 7 {
		didSet {
			UserDefaults.standard.set(Int(stackedIntervalSetSteps), forKey:"stackedIntervalSetSteps");
		}
	}
	dynamic var	stackedIntervalSetOctaves : UInt = 12 {
		didSet {
			UserDefaults.standard.set(Int(stackedIntervalSetSteps), forKey:"stackedIntervalSetOctaves");
		}
	}

	var _sortedStackIntervalSets : [StackedIntervalSet]?
	var sortedStackIntervalSets : [StackedIntervalSet]? {
		if _sortedStackIntervalSets == nil {
			_sortedStackIntervalSets = (document!.intervalsData as! StackedIntervalsIntervalsData).stackedIntervals.sorted { (a:StackedIntervalSet, b:StackedIntervalSet) -> Bool in
				return a.interval < b.interval;
			}
		}
		return _sortedStackIntervalSets;
	}

	var stackedIntervalSet : StackedIntervalSet? {
		get {
			var		theResult : StackedIntervalSet?;
			if let theIntervalString = stackedIntervalSetBaseTextField?.stringValue {
				if var theInterval = Interval.from(string:theIntervalString) {
					while theInterval < 1 {
						theInterval *= 2;
					}
					theResult = StackedIntervalSet( interval: theInterval, steps: stackedIntervalSetSteps, octaves: stackedIntervalSetOctaves );
				}
			}
			return theResult;
		}
		set {
			if let theValue = newValue {
				stackedIntervalSetBaseTextField?.stringValue = theValue.interval.toString;
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

	@IBAction func delete( _ aSender: AnyObject?) {
		if let theSelectedStackedIntervalSet = selectedStackedIntervalSet {
			removeStackedIntervalSet(theSelectedStackedIntervalSet);
		}
	}

	@IBAction func addStackIntervalAction( _ aSender: AnyObject ) {
		if let theStackedIntervalSet = stackedIntervalSet {
			addStackedIntervalSet(theStackedIntervalSet);
		}
	}
	
	dynamic var		stackedIntervalsExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "stackedIntervalsExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "stackedIntervalsExpanded"); }
	}
	func addStackedIntervalSet( _ aStackedInterval : StackedIntervalSet ) {
		if let theDocument = document {
			(document!.intervalsData as! StackedIntervalsIntervalsData).insertStackedInterval(aStackedInterval);
			theDocument.calculateAllIntervals();
			reloadStackedIntervalsTable();
		}
	}

	func removeStackedIntervalSet( _ aStackedInterval : StackedIntervalSet ) {
		if let theDocument = document {
			(document!.intervalsData as! StackedIntervalsIntervalsData).removeStackedInterval(aStackedInterval);
			theDocument.calculateAllIntervals();
			reloadStackedIntervalsTable();
		}
	}

	private func reloadStackedIntervalsTable() {
		_sortedStackIntervalSets = nil;
		stackedIntervalsTableView.reloadData();
	}
}

extension StackedIntervalsGeneratorViewController : NSTableViewDataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		return (document!.intervalsData as! StackedIntervalsIntervalsData).stackedIntervals.count ?? 0;
	}

	func tableView(_ aTable: NSTableView, objectValueFor aTableColumn: NSTableColumn?, row aRow: Int) -> AnyObject?
	{
		var		theResult : AnyObject?
		if let theSortedStackIntervalSet = sortedStackIntervalSets?[aRow] {
			if aTableColumn?.identifier == "interval" {
				theResult = theSortedStackIntervalSet.interval.ratioString;
			}
			else if aTableColumn?.identifier == "steps" {
				theResult = theSortedStackIntervalSet.steps;
			}
			else if aTableColumn?.identifier == "octaves" {
				theResult = theSortedStackIntervalSet.octaves;
			}
		}
		return theResult;
	}

	func tableView(_ aTable: NSTableView, setObjectValue anObject: AnyObject?, for aTableColumn: NSTableColumn?, row aRow: Int) {
		if let theSortedStackIntervalSet = sortedStackIntervalSets?[aRow] {
			if aTableColumn?.identifier == "steps" {
				if let theIntegerValue = anObject as? UInt {
					theSortedStackIntervalSet.steps = theIntegerValue;
				}
			}
			else if aTableColumn?.identifier == "octaves" {
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
		return aTableColumn != nil && theColumns.contains(aTableColumn!.identifier);
	}
}
