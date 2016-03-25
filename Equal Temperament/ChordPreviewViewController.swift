//
//  ChordPreviewViewController.swift
//  Intonation
//
//  Created by Nathan Day on 7/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class ChordPreviewViewController: NSViewController {
	let		chordOrScale : ChordSelectorLeaf;
	init( _ aChordOrScale : ChordSelectorLeaf ) {
		chordOrScale = aChordOrScale;
		super.init(nibName: "ChordPreviewViewController", bundle:nil)!;
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	var		kindDescription : String {
		var		theResult = "";
		if( chordOrScale is ChordSelectorChord ) {
			theResult = "Chord";
		}
		else if( chordOrScale is ChordSelectorScale ) {
			theResult = "Scale";
		}
		return theResult;
	}

	override var	title: String? {
		get { return chordOrScale.name; }
		set { }
	}

	var		itemDescription: String { return ""; }
}

extension ChordPreviewViewController : NSTableViewDataSource {
	func numberOfRowsInTableView(tableView: NSTableView) -> Int { return chordOrScale.everyRatio.count; }

	func tableView( aTableView: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?, row aRow: Int) -> AnyObject? {
		var		theResult = "";
		if aTableColumn?.identifier == "name"{
			theResult = chordOrScale.everyRatio[aRow].name;
		}
		else if aTableColumn?.identifier == "interval"{
			theResult = chordOrScale.everyRatio[aRow].interval.toString;
		}
		return theResult;
	}

	func tableView( aTableView: NSTableView, writeRowsWithIndexes aRowIndexes: NSIndexSet, toPasteboard aPboard: NSPasteboard) -> Bool {
		var		theResult = "";
		for theIndex in aRowIndexes {
			theResult.appendContentsOf("\(chordOrScale.everyRatio[theIndex].name)\t\(chordOrScale.everyRatio[theIndex].interval.toString)\n");
		}
		aPboard.setString(theResult, forType: NSPasteboardTypeTabularText);
		return true;
	}

}
