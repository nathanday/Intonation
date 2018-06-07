/*
	ChordSelectorWindowController.swift
	Intonation

	Created by Nathan Day on 12/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

class ChordSelectorWindowController: NSWindowController {

	override var	windowNibName: NSNib.Name { return NSNib.Name("ChordSelectorWindowController"); }

	var		selectionBlock : ((IntervalSet?) -> ())?;

    override func windowDidLoad() {
        super.windowDidLoad()
    }

	@IBAction func toggleWindow( _ aSender: Any?) {
		if let theWindow = window {
			if theWindow.isVisible {
				close();
			}
			else {
				showWindow(aSender);
			}
		}
	}

	func showAsSheet(parentWindow aWindow: NSWindow ) {
		if let theWindow = window {
			aWindow.beginSheet( theWindow, completionHandler: {
				(aResponse: NSApplication.ModalResponse) -> Void in
			});
		}
	}

	func selectIntervalSet( _ anIntervalSet : IntervalSet ) {
	}
}
