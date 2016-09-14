//
//  ChordSelectorItem.swift
//  Intonation
//
//  Created by Nathan Day on 6/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class ChordSelectorItem : NSObject {
	class func chordSelectorItemsForPropertyList( _ aPropertyList: [[String:Any]] ) -> [ChordSelectorItem] {
		var		theResult : [ChordSelectorItem] = [];
		for theData in aPropertyList {
			if let theItem = chordSelectorItemForPropertyList( theData ) {
				theResult.append(theItem);
			}
		}
		return theResult;
	}
	class func chordSelectorItemForPropertyList( _ aPropertyList: [String:Any] ) -> ChordSelectorItem? {
		var		theResult : ChordSelectorItem? = nil;
		if let theName = aPropertyList["name"] as? String {
			if let theKind = aPropertyList["kind"] as? Int {
				let theAbbreviations = aPropertyList["abbreviations"] as? [String];
				let	theMode = aPropertyList["mode"] as? Set<String>;
				if let theIntervalSet = Scale( propertyList: aPropertyList ) {
					switch( theKind )
					{
					case 1:
						theResult = ChordSelectorScale(name:theName, everyInterval: theIntervalSet );
						break;
					default:
						theResult = ChordSelectorChord(name:theName, abbreviations:theAbbreviations, modes:theMode, everyInterval: theIntervalSet );
						break;
					}
				}
			}
			else if let theChildren = aPropertyList["everyChild"] as? [[String:Any]] {
				theResult = ChordSelectorGroup(name:theName, children:chordSelectorItemsForPropertyList(theChildren));
			}
			else {
				print( "Propertlist entity failed to parse \(aPropertyList)" );
			}
		}
		return theResult;
	}

	dynamic let		name : String;
	dynamic var		isLeaf : Bool { get { return false; } }
	weak var		parent : ChordSelectorGroup? = nil;

	init( name aName: String ) { name = aName; }
}

class ChordSelectorLeaf : ChordSelectorItem {
	let				everyInterval : IntervalSet;

	override var	isLeaf : Bool { get { return true; } }

	init( name aName: String, everyInterval anEveryInterval: IntervalSet ) {
		everyInterval = anEveryInterval;
		super.init( name: aName );
	}

	func previewViewControllerForLeafItem() -> NSViewController? { return ChordPreviewViewController(self); }

	override var description: String { return "name:\(name), everyInterval:\(everyInterval)"; }
}

class ChordSelectorChord : ChordSelectorLeaf {
	let				abbreviations : Array<String>;
	let				modes : Set<String>;
	init( name aName: String, abbreviations anAbbreviations: [String]?, modes aMode: Set<String>?, everyInterval anEveryInterval: IntervalSet ) {
		abbreviations = anAbbreviations ?? [];
		modes = aMode ?? [];
		super.init( name: aName, everyInterval: anEveryInterval );
	}

	override var description: String { return "name:\(name), abbreviations:\(abbreviations), modes:\(modes), everyInterval:\(everyInterval)"; }
}

class ChordSelectorScale : ChordSelectorLeaf {
}

class ChordSelectorGroup : ChordSelectorItem, MutableCollection {
	typealias SubSequence = ChordSelectorGroup
	typealias Index = Int
	dynamic var			everyChild : [ChordSelectorItem] = [ChordSelectorItem]();
	dynamic var			count : Int { get { return everyChild.endIndex-everyChild.startIndex; } }
	override init( name aName: String ) {
		super.init(name:aName);
	}
	init( name aName: String, children aChildren : [ChordSelectorItem] ) {
		everyChild = aChildren;
		super.init(name:aName);
	}
	subscript (anIndex: Int) -> ChordSelectorItem {
		get { return everyChild[anIndex]; }
		set( aValue ) {
			everyChild[anIndex] = aValue;
			aValue.parent = self;
		}
	}
	subscript(aBounds: Range<Int>) -> ChordSelectorGroup {
		get {
			return ChordSelectorGroup( name: "\(name) slice", children: Array(everyChild[aBounds]));
		}
		set(aValue) {
			everyChild.replaceSubrange(aBounds, with: aValue.everyChild);
		}
	}
	func makeIterator() -> IndexingIterator<[ChordSelectorItem]> { return everyChild.makeIterator(); }
	var startIndex: Int { get { return everyChild.startIndex; } }
	var endIndex: Int { get { return everyChild.endIndex; } }
	func formIndex(after anIndex: inout Int) {
		everyChild.formIndex(after : &anIndex);
	}
	func index(after anIndex: Int) -> Int {
		return everyChild.index(after:anIndex);
	}
}

class RootChordSelectorGroup : ChordSelectorGroup {
	init() {
		super.init(name:"root");
		if let theURL = Bundle.main.url(forResource:"PresetChordsAndScales", withExtension: "plist"),
			let theChordData = NSArray(contentsOf: theURL) {
			everyChild = ChordSelectorItem.chordSelectorItemsForPropertyList( theChordData as! [[String : Any]] );
		}
	}
}
