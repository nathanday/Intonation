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
		return (anItem as? ChordSelectorGroup)?.count ?? 0;
	}

	func browser(aBrowser: NSBrowser, child anIndex: Int, ofItem anItem: AnyObject?) -> AnyObject {
		return ((anItem as? ChordSelectorGroup)?[anIndex])!;
	}

	func browser(aBrowser: NSBrowser, isLeafItem anItem: AnyObject?) -> Bool {
		return (anItem as? ChordSelectorItem)?.isLeaf ?? false;
	}

	func browser(aBrowser: NSBrowser, objectValueForItem anItem: AnyObject?) -> AnyObject? {
		return (anItem as? ChordSelectorItem)?.name ?? "";
	}

	func rootItemForBrowser(aBrowser: NSBrowser) -> AnyObject? { return everyChordRoot; }

	func browser( browser: NSBrowser, previewViewControllerForLeafItem anItem: AnyObject ) -> NSViewController? {
		return (anItem as? ChordSelectorLeaf)?.previewViewControllerForLeafItem();
	}
}

