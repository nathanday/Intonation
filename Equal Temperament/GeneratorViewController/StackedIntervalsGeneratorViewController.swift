//
//  StackedIntervalsGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 24/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class StackedIntervalsGeneratorViewController: GeneratorViewController {

	@IBOutlet weak var stackedIntervalSetBaseTextField : NSTextField?;
	@IBOutlet weak var stackedIntervalsTableView: NSTableView!
	dynamic var	stackedIntervalSetSteps : UInt = 5;
	dynamic var	stackedIntervalSetOctaves : UInt = 12;

	override var nibName: String? { return "StackedIntervalsGeneratorViewController"; }

	var _sortedStackIntervalSets : [StackedIntervalSet]?
	var sortedStackIntervalSets : [StackedIntervalSet]? {
		if _sortedStackIntervalSets == nil {
			_sortedStackIntervalSets = document?.intervalsData.stackedIntervals.sort { (a:StackedIntervalSet, b:StackedIntervalSet) -> Bool in
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
			if theDocument.intervalsData.documentType == .StackedIntervals {
				theDocument.intervalsData.stackedIntervals.insert(aStackedInterval);
				theDocument.calculateAllIntervals();
				reloadStackedIntervalsTable();
			}
		}
	}

	func removeStackedIntervalSet( aStackedInterval : StackedIntervalSet ) {
		if let theDocument = document {
			if theDocument.intervalsData.documentType == .StackedIntervals {
				theDocument.intervalsData.stackedIntervals.remove(aStackedInterval);
				theDocument.calculateAllIntervals();
				reloadStackedIntervalsTable();
			}
		}
	}

	private func reloadStackedIntervalsTable() {
		_sortedStackIntervalSets = nil;
		stackedIntervalsTableView.reloadData();
	}
}

extension StackedIntervalsGeneratorViewController : NSTableViewDataSource {

	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return document?.intervalsData.stackedIntervals.count ?? 0;
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

	func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
	}

//	func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
//	}
//
//	func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
//
//	}
//
//	func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forRowIndexes rowIndexes: NSIndexSet) {
//
//	}
//
//	func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, operation: NSDragOperation) {
//
//	}
//
//	func tableView(tableView: NSTableView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
//	}
//
//	func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
//	}
//
//	func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
//	}
//
//	func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
//	}
//
//	func tableView(tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: NSURL, forDraggedRowsWithIndexes indexSet: NSIndexSet) -> [String] {
//	}

}
