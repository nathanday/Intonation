//
//  ChordOrScaleSelectorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 9/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

protocol ChordOrScaleSelector {
	func chordOrScaleSelectorViewController( _ aSelf : ChordOrScaleSelectorViewController, selected aSelected: Bool  );
}

class ChordOrScaleSelectorViewController: NSViewController {

	@IBOutlet var	browser : NSBrowser?;
//	@IBOutlet var	chordSelectorWindowController : ChordSelectorWindowController?
//	@IBOutlet var	delegate :

	required init?(coder aCoder: NSCoder) {
		if let theURL = Bundle.main.url(forResource:"PresetChordsAndScales", withExtension: "plist"),
			let theChordData = NSArray(contentsOf: theURL) as? [[String : Any]] {
			everyChordRoot = RootChordSelectorGroup(propertyList: theChordData );
		} else {
			print( "failed to open PresetChordsAndScales" );
			return nil;
		}
		super.init(coder: aCoder);
	}

	@objc dynamic var	everyChordRoot : RootChordSelectorGroup;

	@objc dynamic var hasLeafSelected : Bool = false;
	var selectedIntervalSet : IntervalSet? {
		didSet {
			hasLeafSelected = selectedIntervalSet != nil;
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
	@IBAction func selectScaleOrChord( _ aSender: Any?) {
//		chordSelectorWindowController?.selectIntervalSet();
	}
}

extension ChordOrScaleSelectorViewController : NSBrowserDelegate {

	func browser(_ aBrowser: NSBrowser, numberOfChildrenOfItem anItem: Any?) -> Int {
		return (anItem as? ChordSelectorGroup)?.count ?? 0;
	}

	func browser(_ aBrowser: NSBrowser, child anIndex: Int, ofItem anItem: Any?) -> Any {
		return ((anItem as? ChordSelectorGroup)?[anIndex])!;
	}

	func browser(_ aBrowser: NSBrowser, isLeafItem anItem: Any?) -> Bool {
		return (anItem as? ChordSelectorItem)?.isLeaf ?? false;
	}

	func browser(_ aBrowser: NSBrowser, objectValueForItem anItem: Any?) -> Any? {
		return (anItem as? ChordSelectorItem)?.name ?? "";
	}

	func rootItem(for aBrowser: NSBrowser) -> Any? { return everyChordRoot; }

	func browser( _ browser: NSBrowser, previewViewControllerForLeafItem anItem: Any ) -> NSViewController? {
		guard let theItem = anItem as? ChordSelectorLeaf else {
			return nil;
		}
		return ChordPreviewViewController(theItem);
	}

	func browser( _ aBrowser : NSBrowser, selectRow aRow: Int , inColumn aColumn: Int) -> Bool {
		if let theItem = aBrowser.item( atRow: aRow, inColumn: aColumn) as? ChordSelectorLeaf {
			selectedIntervalSet = theItem.everyInterval;
		} else {
			selectedIntervalSet = nil;
		}
		return true;
	}

	func browser( _ aBrowser: NSBrowser, selectionIndexesForProposedSelection anIndexes: IndexSet, inColumn aColumn: Int) -> IndexSet {
		if let theRow = anIndexes.first{
			if let theItem = aBrowser.item( atRow: theRow, inColumn: aColumn) as? ChordSelectorLeaf {
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

