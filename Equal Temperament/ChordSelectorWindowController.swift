//
//  ChordSelectorWindowController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 12/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ChordSelectorWindowController: NSWindowController {

	override var windowNibName: String? { get { return "ChordSelectorWindowController"; } }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}

class ChordSelectorItem : NSObject {
	class func chordSelectorItemForPropertyList( aPropertyList: [String:AnyObject] ) -> ChordSelectorItem? {
		return nil;
	}
	
	let			name : String;
	var			isLeaf : Bool { get { return false; } }
	weak var	parent : ChordSelectorGroup? = nil;

	init( name aName: String ) { name = aName; }
}

class ChordSelectorChord : ChordSelectorItem {
	override var	isLeaf : Bool { get { return true; } }
	let				everyRatio : Array<Rational>;

	init( name aName: String, everyRatio anEveryRatio: Array<Rational> ) {
		everyRatio = anEveryRatio;
		super.init( name: aName );
	}
}

class ChordSelectorGroup : ChordSelectorItem, MutableCollectionType {
	var		everyChild = Array<ChordSelectorItem>();
	subscript (anIndex: Int) -> ChordSelectorItem {
		get { return everyChild[anIndex]; }
		set { everyChild[anIndex] = newValue; }
	}
	func generate() -> IndexingGenerator<[ChordSelectorItem]> { return everyChild.generate(); }
	var startIndex: Int { get { return everyChild.startIndex; } }
	var endIndex: Int { get { return everyChild.endIndex; } }
}