//
//  ChordOrScaleSelectorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 9/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

protocol ChordOrScaleSelector {
	func chordOrScaleSelectorViewController( aSelf : ChordOrScaleSelectorViewController, selected aSelected: Bool  );
}

class ChordOrScaleSelectorViewController: NSViewController {

	@IBOutlet var	browser : NSBrowser?;
//	@IBOutlet var	chordSelectorWindowController : ChordSelectorWindowController?
//	@IBOutlet var	delegate :

	dynamic var	everyChordRoot = RootChordSelectorGroup();

	dynamic var hasLeafSelected : Bool = false;
	var selectedIntervalSet : IntervalSet? {
		didSet {
			hasLeafSelected = selectedIntervalSet != nil;
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
	@IBAction func selectScaleOrChord(aSender: AnyObject?) {
//		chordSelectorWindowController?.selectIntervalSet();
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

	func browser( aBrowser : NSBrowser, selectRow aRow: Int , inColumn aColumn: Int) -> Bool {
		if let theItem = aBrowser.itemAtRow( aRow, inColumn: aColumn) as? ChordSelectorLeaf {
			selectedIntervalSet = theItem.everyInterval;
		} else {
			selectedIntervalSet = nil;
		}
		return true;
	}

	func browser( aBrowser: NSBrowser, selectionIndexesForProposedSelection anIndexes: NSIndexSet, inColumn aColumn: Int) -> NSIndexSet {
		let		theRow = anIndexes.firstIndex;
		if theRow != NSNotFound {
			if let theItem = aBrowser.itemAtRow( theRow, inColumn: aColumn) as? ChordSelectorLeaf {
				selectedIntervalSet = theItem.everyInterval;
			} else {
				selectedIntervalSet = nil;
			}
		} else {
			selectedIntervalSet = nil;
		}
		return anIndexes;
	}
}

