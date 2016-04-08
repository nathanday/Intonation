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
		stackedIntervalSetSteps = UInt(NSUserDefaults.standardUserDefaults().integerForKey("stackedIntervalSetSteps"));
		if stackedIntervalSetSteps == 0 {
			stackedIntervalSetSteps = 7;
		}
		stackedIntervalSetOctaves = UInt(NSUserDefaults.standardUserDefaults().integerForKey("stackedIntervalSetOctaves"));
		if stackedIntervalSetOctaves == 0 {
			stackedIntervalSetOctaves = 12;
		}
	}

	@IBOutlet weak var stackedIntervalSetBaseTextField : NSTextField?;
	@IBOutlet weak var stackedIntervalsTableView: NSTableView!
	dynamic var	stackedIntervalSetSteps : UInt = 7 {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(stackedIntervalSetSteps), forKey:"stackedIntervalSetSteps");
		}
	}
	dynamic var	stackedIntervalSetOctaves : UInt = 12 {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(stackedIntervalSetSteps), forKey:"stackedIntervalSetOctaves");
		}
	}

	var _sortedStackIntervalSets : [StackedIntervalSet]?
	var sortedStackIntervalSets : [StackedIntervalSet]? {
		if _sortedStackIntervalSets == nil {
			_sortedStackIntervalSets = (document!.intervalsData as! StackedIntervalsIntervalsData).stackedIntervals.sort { (a:StackedIntervalSet, b:StackedIntervalSet) -> Bool in
				return a.interval < b.interval;
			}
		}
		return _sortedStackIntervalSets;
	}

	var stackedIntervalSet : StackedIntervalSet? {
		get {
			var		theResult : StackedIntervalSet?;
			if let theInterval = stackedIntervalSetBaseTextField?.stringValue {
				if let theInterval = Interval.fromString(theInterval) {
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

	@IBAction func delete( aSender: AnyObject?) {
		if let theSelectedStackedIntervalSet = selectedStackedIntervalSet {
			removeStackedIntervalSet(theSelectedStackedIntervalSet);
		}
	}

	@IBAction func addStackIntervalAction( aSender: AnyObject ) {
		if let theStackedIntervalSet = stackedIntervalSet {
			addStackedIntervalSet(theStackedIntervalSet);
		}
	}
	
	dynamic var		stackedIntervalsExpanded : Bool {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setBool(aValue, forKey: "stackedIntervalsExpanded"); }
		get { return NSUserDefaults.standardUserDefaults().boolForKey("stackedIntervalsExpanded"); }
	}
	func addStackedIntervalSet( aStackedInterval : StackedIntervalSet ) {
		if let theDocument = document {
			(document!.intervalsData as! StackedIntervalsIntervalsData).insertStackedInterval(aStackedInterval);
			theDocument.calculateAllIntervals();
			reloadStackedIntervalsTable();
		}
	}

	func removeStackedIntervalSet( aStackedInterval : StackedIntervalSet ) {
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

	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return (document!.intervalsData as! StackedIntervalsIntervalsData).stackedIntervals.count ?? 0;
	}

	func tableView(aTable: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?, row aRow: Int) -> AnyObject?
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

	func tableView(aTable: NSTableView, setObjectValue anObject: AnyObject?, forTableColumn aTableColumn: NSTableColumn?, row aRow: Int) {
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
	func tableView( aTableView: NSTableView, shouldEditTableColumn aTableColumn: NSTableColumn?, row aRow: Int) -> Bool {
		let		theColumns : Set<String> = ["steps","octaves"];
		return aTableColumn != nil && theColumns.contains(aTableColumn!.identifier);
	}
}
