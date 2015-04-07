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
	@IBOutlet var	scaleView : ScaleView?;
	@IBOutlet var	tableView : NSTableView?;

	var		primeNumber = UInt.primes(upTo: 100 );

	var		intervalCount : UInt = 12 {
		didSet {
			enableInterval = true;
			calculateAllIntervals();
		}
	}
	var		enableInterval : Bool = true {
		didSet { hideIntervalRelatedColumn(!enableInterval); }
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
	var		filtered : Bool = false { didSet { calculateAllIntervals(); } }

	var		baseFrequency : Double = 261.626;
	var		equalTemperament : Bool = false;
	
	dynamic var     everyInterval : [EqualTemperamentEntry] = [];
	dynamic var		smallestError : Double { get { return !smallestErrorEntries.isEmpty ? smallestErrorEntries.first!.errorPercent : 0.0; } }
	dynamic var     averageError : Double = 0.0
	dynamic var		biggestError : Double { get { return !biggestErrorEntries.isEmpty ? biggestErrorEntries.first!.errorPercent : 0.0; } }

	dynamic var		smallestErrorEntries : Set<EqualTemperamentEntry> = [] {
		willSet { self.willChangeValueForKey("smallestError"); }
		didSet { self.didChangeValueForKey("smallestError"); }
	}
	dynamic var		biggestErrorEntries : Set<EqualTemperamentEntry> = [] {
		willSet { self.willChangeValueForKey("biggestError"); }
		didSet { self.didChangeValueForKey("biggestError"); }
	}

	@IBAction func selectPresetInterval( aSender: NSMenuItem ) {
		intervalCount = UInt(aSender.tag);
	}
	
	override var windowNibName: String! { return "Document"; }

	override func windowControllerDidLoadNib(aWindowController: NSWindowController) {
		super.windowControllerDidLoadNib(aWindowController);
		calculateAllIntervals();
	}

	override class func autosavesInPlace() -> Bool { return true; }

	func calculateAllIntervals() {
		let		theDenominator = separatePrimeLimit ? denominatorPrimeLimit : numeratorPrimeLimit;
		var		theEntries = EqualTemperamentCollection(limits: (numeratorPrime:numeratorPrimeLimit,denominatorPrime:theDenominator,numeratorOdd:oddLimit,denominatorOdd:oddLimit), intervalCount: enableInterval ? intervalCount : 0, maximumError: maximumError, filtered: filtered );

		smallestErrorEntries = theEntries.smallestError;
		biggestErrorEntries = theEntries.biggestError;
		everyInterval.removeAll(keepCapacity: true);
		averageError = theEntries.averageError;
		everyInterval = theEntries.everyEntry;
		scaleView?.numberOfIntervals = enableInterval ? intervalCount : 0;
		scaleView?.justIntonationRatio = everyInterval.map { return $0.justIntonationRatio; };
	}

	var everyTableColumn : [NSTableColumn] {
		return tableView != nil ? tableView!.tableColumns as! [NSTableColumn] : [];
	}

	func hideIntervalRelatedColumn( aHide : Bool ) {
		for theTableColumn in everyTableColumn.filter( { return $0.identifier != nil && contains(["interval","percent","error"],$0.identifier);} ) {
			theTableColumn.hidden = aHide;
		}
	}
}

extension Document : NSTableViewDelegate {
	static let		cellColors = ( backgroundAlpha:CGFloat(0.1), maxErrorTextAlpha:CGFloat(0.25) );
	func tableView( aTableView: NSTableView, willDisplayCell aCell: AnyObject, forTableColumn aTableColumn: NSTableColumn?, row aRowIndex: Int) {
		if let	theEntry = arrayController!.arrangedObjects[aRowIndex] as? EqualTemperamentEntry, theCell = aCell as? NSTextFieldCell {
			let		theExceedsError = abs(theEntry.errorPercent) > 100.0*self.maximumError;
			if smallestErrorEntries.contains(theEntry) {
				theCell.backgroundColor = NSColor(calibratedRed:0.0, green:0.0, blue:1.0, alpha:Document.cellColors.backgroundAlpha);
				theCell.textColor = NSColor(calibratedRed:0.0, green:0.0, blue:0.6, alpha:theExceedsError ? Document.cellColors.maxErrorTextAlpha : 1.0);
			}
			else if biggestErrorEntries.contains(theEntry) {
				theCell.backgroundColor = NSColor(calibratedRed:0.8, green:0.0, blue:0.0, alpha:Document.cellColors.backgroundAlpha);
				theCell.textColor = NSColor(calibratedRed:0.52, green:0.0, blue:0.0, alpha:theExceedsError ? Document.cellColors.maxErrorTextAlpha : 1.0);
			}
			else {
				theCell.backgroundColor = NSColor.clearColor();
				theCell.textColor = NSColor(calibratedWhite: 0.0, alpha: theExceedsError ? Document.cellColors.maxErrorTextAlpha : 1.0);
			}
		}
	}
}

