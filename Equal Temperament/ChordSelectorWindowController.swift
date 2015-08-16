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
		var		theResult = true;
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
}


class ChordSelectorItem : NSObject {
	class func chordSelectorItemsForPropertyList( aPropertyList: [[String:AnyObject]] ) -> [ChordSelectorItem] {
		var		theResult : [ChordSelectorItem] = [];
		for theData in aPropertyList {
			if let theItem = chordSelectorItemForPropertyList( theData ) {
				theResult.append(theItem);
			}
		}
		return theResult;
	}
	class func chordSelectorItemForPropertyList( aPropertyList: [String:AnyObject] ) -> ChordSelectorItem? {
		var		theResult : ChordSelectorItem? = nil;
		if let theName = aPropertyList["name"] as? String {
			if let theChildren = aPropertyList["everyChild"] as? [[String:AnyObject]] {
				let		theChordSelectorGroup = ChordSelectorGroup(name:theName);
				theChordSelectorGroup.everyChild = chordSelectorItemsForPropertyList(theChildren);
				theResult = theChordSelectorGroup;
			}
			else if let theAbbreviations = aPropertyList["abbreviations"] as? [String], theMode = aPropertyList["mode"] as? [String], theEveryRatioString = aPropertyList["everyRatio"] as? [String] {
				var		theEveryRatio : [Rational] = [];
				for theRationalString in theEveryRatioString {
					if let theRational = theRationalString.toRational() {
						theEveryRatio.append(theRational);
					}
				}
				theResult = ChordSelectorChord(name:theName, abbreviations:theAbbreviations, mode:theMode, everyRatio: theEveryRatio );
			}
		}
		return theResult;
	}
	
	dynamic let		name : String;
	dynamic var		isLeaf : Bool { get { return false; } }
	weak var		parent : ChordSelectorGroup? = nil;

	init( name aName: String ) { name = aName; }
}

class ChordSelectorChord : ChordSelectorItem {
	override var	isLeaf : Bool { get { return true; } }
	let				everyRatio : Array<Rational>;

	init( name aName: String, abbreviations anAbbreviations: [String], mode aMode: [String], everyRatio anEveryRatio: [Rational] ) {
		everyRatio = anEveryRatio;
		super.init( name: aName );
	}
}

class ChordSelectorGroup : ChordSelectorItem, MutableCollectionType {
	dynamic var			everyChild : [ChordSelectorItem] = [];
	dynamic var			count : Int { get { return everyChild.endIndex-everyChild.startIndex; } }
	subscript (anIndex: Int) -> ChordSelectorItem {
		get { return everyChild[anIndex]; }
		set( aValue ) {
			everyChild[anIndex] = aValue;
			aValue.parent = self;
		}
	}
	func generate() -> IndexingGenerator<[ChordSelectorItem]> { return everyChild.generate(); }
	var startIndex: Int { get { return everyChild.startIndex; } }
	var endIndex: Int { get { return everyChild.endIndex; } }
}

class RootChordSelectorGroup : ChordSelectorGroup {
	init() {
		super.init(name:"root");
		if let theURL = NSBundle.mainBundle().URLForResource("Chords", withExtension: "plist"), theChordData = NSArray(contentsOfURL: theURL) {
			everyChild = ChordSelectorItem.chordSelectorItemsForPropertyList( theChordData as! [[String : AnyObject]] );
		}
	}
}
