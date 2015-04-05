/*
    Document.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright (c) 2014 Nathan Day. All rights reserved.
 */

import Cocoa

let kThumbSize = NSSize(width:7.0,height:42.0);

class Document : NSDocument {
	@IBOutlet var	tableParentContainerView : NSView?
	@IBOutlet var	arrayController : NSArrayController?

	var		primeNumber = UInt.primes(upTo: 100 );

	var		intervalCount : UInt = 12 {
		didSet { calculateAllIntervals(); }
	}
	var		numeratorPrimeLimit : UInt { get { return primeNumber[numeratorPrimeLimitIndex]; } }
	var		numeratorPrimeLimitIndex : Int = 2 {
		willSet { willChangeValueForKey("numeratorPrimeLimit"); }
		didSet {
			didChangeValueForKey("numeratorPrimeLimit");
			calculateAllIntervals();
		}
	}
	var		denominatorPrimeLimit : UInt { get { return primeNumber[denominatorPrimeLimitIndex]; } }
	var		denominatorPrimeLimitIndex : Int = 1 {
		willSet { willChangeValueForKey("denominatorPrimeLimit"); }
		didSet {
			didChangeValueForKey("denominatorPrimeLimit");
			calculateAllIntervals();
		}
	}
	var		separatePrimeLimit : Bool = false { didSet { calculateAllIntervals(); } }
	var		oddLimit : UInt = 15 {
		didSet {
			if( oddLimit%2 == 0 ) { oddLimit++; }
			calculateAllIntervals();
		}
	}
	var		maximumError : Double = 0.18 { didSet { calculateAllIntervals(); } }
	var		filtered : Bool = true { didSet { calculateAllIntervals(); } }
	
	dynamic var     everyInterval : [EqualTemperamentEntry] = [];
	dynamic var		smallestError : Double { get { return !smallestErrorEntries.isEmpty ? smallestErrorEntries.first!.errorCent : 0.0; } }
	dynamic var     averageError : Double = 0.0
	dynamic var		biggestError : Double { get { return !biggestErrorEntries.isEmpty ? biggestErrorEntries.first!.errorCent : 0.0; } }

	dynamic var		smallestErrorEntries : Set<EqualTemperamentEntry> = [];
	dynamic var		biggestErrorEntries : Set<EqualTemperamentEntry> = [];

	@IBAction func selectPresetInterval( aSender: NSMenuItem ) {
		intervalCount = UInt(aSender.tag);
	}
	
	override var windowNibName: String! { return "Document"; }

	override func windowControllerDidLoadNib(aWindowController: NSWindowController) {
		super.windowControllerDidLoadNib(aWindowController);
		calculateAllIntervals();
	}

	override class func autosavesInPlace() -> Bool { return true; }

	final func calculateAllIntervals() {
		let		theDenominator = separatePrimeLimit ? denominatorPrimeLimit : numeratorPrimeLimit;
		var		theEntries = EqualTemperament(limits: (numeratorPrime:numeratorPrimeLimit,denominatorPrime:theDenominator,numeratorOdd:oddLimit,denominatorOdd:oddLimit), intervalCount: intervalCount, maximumError: maximumError, filtered: filtered );

		smallestErrorEntries = theEntries.smallestError;
		biggestErrorEntries = theEntries.biggestError;
		everyInterval.removeAll(keepCapacity: true);
		averageError = theEntries.averageError;
		everyInterval = theEntries.everyEntry();
	}
}

extension Document : NSTableViewDelegate {
	func tableView( aTableView: NSTableView, willDisplayCell aCell: AnyObject, forTableColumn aTableColumn: NSTableColumn?, row aRowIndex: Int) {
		if let	theEntry = arrayController!.arrangedObjects[aRowIndex] as? EqualTemperamentEntry, theCell = aCell as? NSTextFieldCell {
			if smallestErrorEntries.contains(theEntry) {
				theCell.backgroundColor = NSColor(calibratedRed:0.0, green:0.0, blue:1.0, alpha:0.3);
				theCell.textColor = NSColor(calibratedRed:0.0, green:0.0, blue:0.6, alpha:1.0);
			}
			else if biggestErrorEntries.contains(theEntry) {
				theCell.backgroundColor = NSColor(calibratedRed:0.8, green:0.0, blue:0.0, alpha:0.3);
				theCell.textColor = NSColor(calibratedRed:0.52, green:0.0, blue:0.0, alpha:1.0);
			}
			else {
				theCell.backgroundColor = NSColor.clearColor();
				theCell.textColor = NSColor.blackColor();
			}
		}
	}
}

