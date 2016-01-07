/*
	ChordSelectorWindowController.swift
	Equal Temperament

	Created by Nathan Day on 12/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

class ChordSelectorWindowController: NSWindowController {
	@IBOutlet var	treeController : NSTreeController?;
	@IBOutlet var	browser : NSBrowser?;

	dynamic var	everyChordRoot = RootChordSelectorGroup();

	override var	windowNibName: String? { get { return "ChordSelectorWindowController"; } }
	
    override func windowDidLoad() {
        super.windowDidLoad()
    }

	@IBAction func toggleWindow(aSender: AnyObject?) {
		if let theWindow = self.window {
			if theWindow.visible {
				close();
			}
			else {
				showWindow(aSender);
			}
		}
	}
}

extension ChordSelectorWindowController : NSBrowserDelegate {
	
	func browser(aBrowser: NSBrowser, numberOfChildrenOfItem anItem: AnyObject?) -> Int {
		var		theResult = 0;
		if let theItem = anItem as? ChordSelectorGroup {
			theResult = theItem.count;
		}
		return theResult;
	}
	
	func browser(aBrowser: NSBrowser, child anIndex: Int, ofItem anItem: AnyObject?) -> AnyObject {
		var		theResult : ChordSelectorItem? = nil;
		if let theItem = anItem as? ChordSelectorGroup {
			theResult = theItem[anIndex];
		}
		return theResult!;
	}
	
	func browser(aBrowser: NSBrowser, isLeafItem anItem: AnyObject?) -> Bool {
		var		theResult = false;
		if let theItem = anItem as? ChordSelectorItem {
			theResult = theItem.isLeaf;
		}
		return theResult;
	}
	
	func browser(aBrowser: NSBrowser, objectValueForItem anItem: AnyObject?) -> AnyObject? {
		var		theResult = "";
		if let theItem = anItem as? ChordSelectorItem {
			theResult = theItem.name;
		}
		return theResult;
	}
	func rootItemForBrowser(aBrowser: NSBrowser) -> AnyObject? {
		return everyChordRoot;
	}
	func browser( browser: NSBrowser, previewViewControllerForLeafItem anItem: AnyObject ) -> NSViewController? {
		var		theResult : NSViewController?
		if let theChordSelectorSubChild = anItem as? ChordSelectorLeaf {
			theResult = theChordSelectorSubChild.previewViewControllerForLeafItem();
		}
		return theResult;
	}
}

