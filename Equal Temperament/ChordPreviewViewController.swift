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

	override func viewDidLoad() {
		super.viewDidLoad();
	}
}

extension ChordPreviewViewController : NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int { return chordOrScale.everyInterval.numberOfDegrees; }

	func tableView( _ aTableView: NSTableView, objectValueFor aTableColumn: NSTableColumn?, row aRow: Int) -> AnyObject? {
		var		theResult = "";
		if aTableColumn?.identifier == "name" {
			theResult = chordOrScale.everyInterval[aRow].names?.first ?? "";
		}
		else if aTableColumn?.identifier == "interval"{
			theResult = chordOrScale.everyInterval[aRow].toString;
		}
		return theResult;
	}

	func tableView( _ aTableView: NSTableView, writeRowsWith aRowIndexes: IndexSet, to aPboard: NSPasteboard) -> Bool {
		var		theResult = "";
		for theIndex in aRowIndexes {
			theResult.append("\(chordOrScale.everyInterval[theIndex].names?.first ?? "")\t\(chordOrScale.everyInterval[theIndex].toString)\n");
		}
		aPboard.setString(theResult, forType: NSPasteboardTypeTabularText);
		return true;
	}

}
