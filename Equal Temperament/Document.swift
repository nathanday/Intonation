/*
    Document.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright (c) 2014 Nathan Day. All rights reserved.
 */

import Cocoa

let kThumbSize = NSSize(width:7.0,height:42.0);

class Document : NSDocument
{
	@IBOutlet var	tableParentContainerView : NSView?
	@IBOutlet var	arrayController : NSArrayController?

	var		numberOfIntervals : UInt = 12
	{
		didSet { calculateAllIntervals(maximumDenominator:maximumDenominator,numberOfIntervals:numberOfIntervals); }
	}
	var		maximumDenominator : UInt = 8
	{
		didSet { calculateAllIntervals(maximumDenominator:maximumDenominator,numberOfIntervals:numberOfIntervals); }
	}
	dynamic var     everyInterval : [EqualTemperamentEntry] =  [];
	dynamic var		smallestError : Double = 0.0
	dynamic var     averageError : Double = 0.0
	dynamic var		biggestError : Double = 0.0

	@IBAction func selectPresetInterval( aSender: NSMenuItem )
	{
		let theMenuItem = aSender
		numberOfIntervals = UInt(theMenuItem.tag);
	}

	override var windowNibName: String! { return "Document"; }

	override func windowControllerDidLoadNib(aWindowController: NSWindowController!)
	{
		super.windowControllerDidLoadNib(aWindowController);
		calculateAllIntervals(maximumDenominator:maximumDenominator,numberOfIntervals:numberOfIntervals);
	}

	override class func autosavesInPlace() -> Bool { return true; }

	final func calculateAllIntervals( maximumDenominator aMaxDenum:UInt, numberOfIntervals aNumIntervals:UInt )
	{
		let		theRatios = NSMutableSet();
		var		theAverageError = 0.0;
        var     theFirst = true;

		for theDenominator in 2..<aMaxDenum
		{
			for theNumerator in 1..<theDenominator
			{
				let			theNumber = Rational(Int64(theNumerator+theDenominator),Int64(theDenominator));
				let			theEntry = EqualTemperamentEntry(justIntonationRatio:theNumber, numberOfIntervals:aNumIntervals);
				theRatios.addObject(theEntry);
				if theFirst == true || fabs(smallestError) > fabs(theEntry.errorCent)
				{
					smallestError = theEntry.errorCent;
				}

				if( theFirst == true || fabs(biggestError) < fabs(theEntry.errorCent) )
				{
					biggestError = theEntry.errorCent;
				}
                theFirst = false;
			}
		}
		everyInterval.removeAll(keepCapacity: true);
		for theEntry : AnyObject in theRatios.allObjects
		{
			let theEqualTemperamentEntry = theEntry as? EqualTemperamentEntry
			if theEqualTemperamentEntry != nil { everyInterval.append(theEqualTemperamentEntry!); }
		}
		sort( &everyInterval, { return $0.justIntonationCents < $1.justIntonationCents; } );

		for theEntry in everyInterval {
			theAverageError += fabs(theEntry.errorCent);
		}
		averageError = theAverageError/Double(theRatios.count)
	}
}

extension Document : NSSplitViewDelegate
{
	func splitView(splitView: NSSplitView!, additionalEffectiveRectOfDividerAtIndex aDividerIndex: Int) -> NSRect
	{
		let		theFrame = tableParentContainerView!.frame;
		return NSMakeRect( NSMaxX(theFrame)-kThumbSize.width, NSMinY(theFrame), kThumbSize.width, theFrame.height );
	}
}

extension Document : NSTableViewDelegate
{
	func tableView( aTableView: NSTableView!, willDisplayCell aCell: AnyObject!, forTableColumn aTableColumn: NSTableColumn!, row aRowIndex: Int)
	{
		let	theEntry = arrayController!.arrangedObjects[aRowIndex] as EqualTemperamentEntry;
		let theCell = aCell as NSTextFieldCell;

		if theEntry.error == smallestError
		{
			theCell.backgroundColor = NSColor(calibratedRed:0.0, green:0.0, blue:1.0, alpha:0.3);
			theCell.textColor = NSColor(calibratedRed:0.0, green:0.0, blue:0.6, alpha:1.0);
		}
		else if theEntry.error == biggestError
		{
			theCell.backgroundColor = NSColor(calibratedRed:0.8, green:0.0, blue:0.0, alpha:0.3);
			theCell.textColor = NSColor(calibratedRed:0.52, green:0.0, blue:0.0, alpha:1.0);
		}
		else
		{
			theCell.backgroundColor = NSColor.clearColor();
			theCell.textColor = NSColor.blackColor();
		}
	}
}

