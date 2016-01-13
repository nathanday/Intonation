//
//  ChordOrScaleSelectorViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 9/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

//protocol ChordOrScaleSelector {
//	func selectedChordOrScale();
//}

class ChordOrScaleSelectorViewController: NSViewController {

	@IBOutlet var	browser : NSBrowser?;
//	@IBOutlet var	delegate :

	dynamic var	everyChordRoot = RootChordSelectorGroup();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
	@IBAction func selectScaleOrChord(aSender: AnyObject?) {
	}

}

extension ChordOrScaleSelectorViewController : NSBrowserDelegate {

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

	func rootItemForBrowser(aBrowser: NSBrowser) -> AnyObject? { return everyChordRoot; }

	func browser( browser: NSBrowser, previewViewControllerForLeafItem anItem: AnyObject ) -> NSViewController? {
		var		theResult : NSViewController?
		if let theChordSelectorSubChild = anItem as? ChordSelectorLeaf {
			theResult = theChordSelectorSubChild.previewViewControllerForLeafItem();
		}
		return theResult;
	}
}

