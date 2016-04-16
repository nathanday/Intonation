//
//  ChordSelectorItem.swift
//  Intonation
//
//  Created by Nathan Day on 6/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

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
			else if let theChildren = aPropertyList["everyChild"] as? [[String:AnyObject]] {
				let		theChordSelectorGroup = ChordSelectorGroup(name:theName);
				theChordSelectorGroup.everyChild = chordSelectorItemsForPropertyList(theChildren);
				theResult = theChordSelectorGroup;
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
		if let theURL = NSBundle.mainBundle().URLForResource("PresetChordsAndScales", withExtension: "plist"),
			theChordData = NSArray(contentsOfURL: theURL) {
			everyChild = ChordSelectorItem.chordSelectorItemsForPropertyList( theChordData as! [[String : AnyObject]] );
		}
	}
}
