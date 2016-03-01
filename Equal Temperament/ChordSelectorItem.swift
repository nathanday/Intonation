//
//  ChordSelectorItem.swift
//  Equal Temperament
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
			if let theEveryRatioString = aPropertyList["everyChild"] as? [[String:AnyObject]],
				theKind = aPropertyList["kind"] as? Int {
				let theAbbreviations = aPropertyList["abbreviations"] as? [String];
				let	theMode = aPropertyList["mode"] as? Set<String>;
				if let theEveryRatio = chordSelectorItemsForPropertyList( theEveryRatioString ) as? [ChordSelectorRatio] {
					switch( theKind )
					{
					case 1:
						theResult = ChordSelectorScale(name:theName, everyRatio: theEveryRatio );
						break;
					default:
						theResult = ChordSelectorChord(name:theName, abbreviations:theAbbreviations, modes:theMode, everyRatio: theEveryRatio );
						break;
					}
				}
			}
			else if let theChildren = aPropertyList["everyChild"] as? [[String:AnyObject]] {
				let		theChordSelectorGroup = ChordSelectorGroup(name:theName);
				theChordSelectorGroup.everyChild = chordSelectorItemsForPropertyList(theChildren);
				theResult = theChordSelectorGroup;
			}
			else if let theNumerator = aPropertyList["numerator"] as? Int,
				theDenominator = aPropertyList["denominator"] as? Int {
				theResult = ChordSelectorRatio( name: theName, ratio: Rational(theNumerator,theDenominator) );
			}
			else if let theRatio = aPropertyList["value"] as? Double {
				theResult = ChordSelectorRatio( name: theName, ratio: theRatio );
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

class ChordSelectorRatio : ChordSelectorItem {
	let				ratio : Ratio;

	init( name aName: String, ratio aRatio: Rational ) {
		ratio = .rational(aRatio);
		super.init( name: aName );
	}
	init( name aName: String, ratio aRatio: Double ) {
		ratio = .irrational(aRatio);
		super.init( name: aName );
	}
}

class ChordSelectorLeaf : ChordSelectorItem {
	let				everyRatio : Array<ChordSelectorRatio>;

	override var	isLeaf : Bool { get { return true; } }

	init( name aName: String, everyRatio anEveryRatio: [ChordSelectorRatio] ) {
		everyRatio = anEveryRatio;
		super.init( name: aName );
	}

	func previewViewControllerForLeafItem() -> NSViewController? { return ChordPreviewViewController(self); }
}

class ChordSelectorChord : ChordSelectorLeaf {
	let				abbreviations : Array<String>;
	let				modes : Set<String>;
	init( name aName: String, abbreviations anAbbreviations: [String]?, modes aMode: Set<String>?, everyRatio anEveryRatio: [ChordSelectorRatio] ) {
		abbreviations = anAbbreviations ?? [];
		modes = aMode ?? [];
		super.init( name: aName, everyRatio: anEveryRatio );
	}
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
