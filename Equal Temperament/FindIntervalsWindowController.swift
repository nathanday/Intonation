//
//  FindIntervalsWindowController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 28/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class FindIntervalsWindowController: NSWindowController {
	var		everyRatio = Array<Double>();
	var		rootRatio : Double?
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var windowNibName: String? { get { return  "FindIntervalsWindowController"; } }

	override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

	@IBAction func addRow( aSender: AnyObject? ) {

	}

	@IBAction func removeRow( aSender: AnyObject? ) {
		
	}
}

extension FindIntervalsWindowController : NSTableViewDataSource {
	func numberOfRowsInTableView(tableView: NSTableView) -> Int { return everyRatio.count; }

	func tableView(tableView: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?, row aRow: Int) -> AnyObject? {
		let		theValue = everyRatio[aRow];
		if aTableColumn?.identifier == "ratio" {
			return theValue;
		}
		else if aTableColumn?.identifier == "isRoot" {
			return theValue == rootRatio;
		}
		else {
			return nil;
		}
	}

	func tableView(tableView: NSTableView, setObjectValue anObject: AnyObject?, forTableColumn aTableColumn: NSTableColumn?, row aRow: Int) {
		if aTableColumn?.identifier == "ratio" {
			if let theString = anObject as? String, theValue = Double(theString) {
				everyRatio[aRow] = Double(theValue);
			}
		}
		else if aTableColumn?.identifier == "isRoot" {
			rootRatio = everyRatio[aRow];
		}
	}

	func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {

	}

//	func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting {
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
//
//	}
//
//	func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
//
//	}
//
//	func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
//
//	}
//
//	func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
//
//	}
}

extension FindIntervalsWindowController : NSTableViewDelegate {

}
