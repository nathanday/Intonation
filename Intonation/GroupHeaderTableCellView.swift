//
//  GroupHeaderTableCellView.swift
//  Intonation
//
//  Created by Nathaniel Day on 3/01/19.
//  Copyright © 2019 Nathan Day. All rights reserved.
//

import Cocoa

class GroupHeaderTableCellView: NSTableCellView {

	@IBOutlet var		toggleButton: NSButton!;

	var	exapanded: Bool = true {
		didSet {
			toggleButton.state = exapanded ? .on : .off;
		}
	}

	override func awakeFromNib() {
		toggleButton.state = exapanded ? .on : .off;
		toggleButton.target = self;
		toggleButton.action = #selector(GroupHeaderTableCellView.toggleAction);
	}

	@IBAction func toggleAction( _ aSender: NSButton ) {
		func tableView() -> NSTableView? {
			var		theView = superview;
			while theView != nil {
				if let theTableView = theView as? NSTableView {
					return theTableView;
				}
				theView = theView?.superview;
			}
			return nil;
		}

		let		theTableView = tableView();
		let		theRow = theTableView?.row(for: self) ?? -1;
		toggleButton.state = toggleButton.state == .on ? .off : .on;
		if theRow >= 0 {
			theTableView?.selectRowIndexes( IndexSet(integer: theRow), byExtendingSelection: false);
		}
	}
}
