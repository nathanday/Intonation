/*
	ChordSelectorWindowController.swift
	Intonation

	Created by Nathan Day on 12/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

class ChordSelectorWindowController: NSWindowController {

	override var	windowNibName: String? {
		get { return "ChordSelectorWindowController"; }
	}

	var		selectionBlock : ((IntervalSet?) -> ())?;

    override func windowDidLoad() {
        super.windowDidLoad()
    }

	@IBAction func toggleWindow( _ aSender: Any?) {
		if let theWindow = self.window {
			if theWindow.isVisible {
				close();
			}
			else {
				showWindow(aSender);
			}
		}
	}

	func showAsSheet(parentWindow aWindow: NSWindow ) {
		if let theWindow = self.window {
			theWindow.parent = aWindow;
			aWindow.beginSheet( theWindow, completionHandler: {
				(aResponse: NSModalResponse) -> Void in
			});
		}
	}

	func selectIntervalSet( _ anIntervalSet : IntervalSet ) {
	}
}
