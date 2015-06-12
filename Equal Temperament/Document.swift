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
	@IBOutlet var	linearScaleView : ScaleView?;
	@IBOutlet var	pitchConstellationView : ScaleView?;
	@IBOutlet var	harmonicView : HarmonicView?;
	@IBOutlet var	waveView : WaveView?;
	@IBOutlet var	spectrumView : SpectrumView?;
	@IBOutlet var	tableView : NSTableView?;
	@IBOutlet var	baseFrequencyTextField : NSTextField?;
	@IBOutlet var	documentWindow : NSWindow?;
	@IBOutlet var	harmonicTitleTextField : NSTextField?;

	var		primeNumber = UInt.primes(upTo: 100 );

	var		intervalCount : UInt = 12 {
		didSet {
			enableInterval = true;
			calculateAllIntervals();
		}
	}
	dynamic var		enableInterval : Bool = true {
		didSet {
			hideIntervalRelatedColumn(!enableInterval);
		}
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
	var		oddLimit : UInt = 17 {
		didSet {
			if( oddLimit%2 == 0 ) { oddLimit++; }
			calculateAllIntervals();
		}
	}
	var		maximumError : Double = 0.18 { didSet { calculateAllIntervals(); } }
	var		filtered : Bool = false { didSet { calculateAllIntervals(); } }

	var		selectedIndicies : [Int] {
		var		theResult : [Int] = [];
		if let theTableView = tableView {
			for theIndex in theTableView.selectedRowIndexes {
				theResult.append(theIndex);
			}
		}
		return theResult;
	}
	var		selectedEqualTemperamentEntry : [EqualTemperamentEntry] {
		var		theResult : [EqualTemperamentEntry] = [];
		if let theArrangedRations = arrayController?.selectedObjects as? [EqualTemperamentEntry] {
			theResult = theArrangedRations;
		}
		return theResult;
	}
	var		selectedJustIntonationRatio : [Rational] {
		return selectedEqualTemperamentEntry.map { return $0.justIntonationRatio; };
	}

	var		equalTemperament : Bool = false;

	var		baseFrequency : Double {
		get { return tonePlayer.baseFrequency; }
		set( aValue ) { tonePlayer.baseFrequency = aValue; }
	}

	var		allOvertonesAmount : Double {
		get { return overtones.amount; }
		set( aValue ) { overtones = HarmonicsDescription(amount: aValue, evenAmount: overtones.evenAmount); }
	}
	var		evenOvertonesAmount : Double {
		get { return overtones.evenAmount; }
		set( aValue ) { overtones = HarmonicsDescription(amount: overtones.amount, evenAmount: aValue); }
	}
	var		overtones : HarmonicsDescription {
		set( aValue ) { tonePlayer.harmonics = aValue; }
		get { return tonePlayer.harmonics; }
	}
	var		tonePlayer = TonePlayer();

	dynamic var		selectedScaleDisplayType : Int {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setInteger(aValue, forKey: "selectedScaleDisplayType"); }
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedScaleDisplayType"); }
	}

	dynamic var		selectedWaveViewMode : Int {
		set(aValue) {
			NSUserDefaults.standardUserDefaults().setInteger(aValue, forKey: "selectedWaveViewMode");
			updateWaveViewDisplayMode();
		}
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedWaveViewMode"); }
	}

	dynamic var		selectedWaveViewScale : Int {
		set( aValue ) {
			NSUserDefaults.standardUserDefaults().setInteger(aValue, forKey: "selectedWaveViewScale");
			updateWaveViewScale();
		}
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedWaveViewScale"); }
	}
	
	dynamic var		selectedSpectrumType : Int {
		set( aValue ) {
			NSUserDefaults.standardUserDefaults().setInteger( aValue, forKey: "selectedSpectrumType");
			updateSelectedSpectrumType();
		}
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedSpectrumType"); }
	}
	
	dynamic var		selectedPlaybackType : Int {
		set( aValue ) {
			NSUserDefaults.standardUserDefaults().setInteger( aValue, forKey: "selectedPlaybackType");
		}
		get { return NSUserDefaults.standardUserDefaults().integerForKey("selectedPlaybackType"); }
	}
	
	/*
	Disclosure views
	*/
	dynamic var		limitExpanded : Bool {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setBool(aValue, forKey: "limitExpanded"); }
		get { return NSUserDefaults.standardUserDefaults().boolForKey("limitExpanded"); }
	}
	dynamic var		errorExpanded : Bool {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setBool(aValue, forKey: "errorExpanded"); }
		get { return NSUserDefaults.standardUserDefaults().boolForKey("errorExpanded"); }
	}
	dynamic var		audioExpanded : Bool {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setBool(aValue, forKey: "audioExpanded"); }
		get { return NSUserDefaults.standardUserDefaults().boolForKey("audioExpanded"); }
	}

	private func updateWaveViewDisplayMode() {
		if let theWaveView = waveView {
			switch selectedWaveViewMode {
			case 1:
				theWaveView.displayMode = .combined;
			default:
				theWaveView.displayMode = .overlayed;
			}
		}
	}
	
	private func updateWaveViewScale() {
		if let theWaveView = waveView {
			switch selectedWaveViewScale {
			case 1:
				theWaveView.xScale = 50.0;
			case 2:
				theWaveView.xScale = 100.0;
			default:
				theWaveView.xScale = 25.0;
			}
		}
	}
	
	private func updateSelectedSpectrumType() {
		if let theSpectrumView = spectrumView {
			switch selectedSpectrumType {
			case 1:
				theSpectrumView.spectrumType = .saw;
			case 2:
				theSpectrumView.spectrumType = .square;
			default:
				theSpectrumView.spectrumType = .sine;
			}
		}
	}

	dynamic var     everyInterval : [EqualTemperamentEntry] = [];
	dynamic var		smallestError : Double { get { return !smallestErrorEntries.isEmpty ? smallestErrorEntries.first!.error : 0.0; } }
	dynamic var     averageError : Double = 0.0
	dynamic var		biggestError : Double { get { return !biggestErrorEntries.isEmpty ? biggestErrorEntries.first!.error : 0.0; } }

	dynamic var		smallestErrorEntries : Set<EqualTemperamentEntry> = [] {
		willSet { self.willChangeValueForKey("smallestError"); }
		didSet { self.didChangeValueForKey("smallestError"); }
	}
	dynamic var		biggestErrorEntries : Set<EqualTemperamentEntry> = [] {
		willSet { self.willChangeValueForKey("biggestError"); }
		didSet { self.didChangeValueForKey("biggestError"); }
	}

	private func updateChordRatioTitle( ) {
		if let theHarmonicTitleTextField = harmonicTitleTextField {
			if selectedJustIntonationRatio.count > 1 {
				var		theRatiosString : String = "";
				var		theCommonFactor = 1;
				for theValue in selectedJustIntonationRatio {
					theCommonFactor *= theValue.denominator/greatestCommonDivisor(theCommonFactor,v: theValue.denominator);
				}
				for theRatio in selectedJustIntonationRatio {
					if let theValue = theRatio.numeratorForDenominator(theCommonFactor) {
						if theRatiosString.startIndex == theRatiosString.endIndex {
							theRatiosString = "\(theValue)"
						}
						else {
							theRatiosString.write( ":\(theValue)" );
						}
					}
				}
				theHarmonicTitleTextField.stringValue = theRatiosString;
			}
			else if let theSingle = selectedJustIntonationRatio.first {
				theHarmonicTitleTextField.stringValue = theSingle.ratioString;
			}
			else {
				theHarmonicTitleTextField.stringValue = "";
			}
		}
	}

	override func awakeFromNib() {
		updateWaveViewDisplayMode();
		updateSelectedSpectrumType();
		updateWaveViewScale();
	}

	override func dataOfType( typeName: String) throws -> NSData {
		var anError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
		let		thePropertyList = [
			"intervalCount":intervalCount,
			"limits":[
				"numeratorPrime":numeratorPrimeLimitIndex,
				"denominatorPrime":denominatorPrimeLimitIndex,
				"odd":oddLimit],
			"enableInterval":enableInterval,
			"maximumError":maximumError,
			"filtered":filtered,
			"tone":[
				"baseFrequency":baseFrequency,
				"allOvertonesAmount":allOvertonesAmount,
				"evenOvertonesAmount":evenOvertonesAmount]
		];
		let		theResult: NSData?
		do {
			theResult = try NSPropertyListSerialization.dataWithPropertyList(thePropertyList, format:.XMLFormat_v1_0, options:0)
		} catch let error as NSError {
			anError = error
			theResult = nil
		};
		if let value = theResult {
			return value
		}
		throw anError;
	}

	override func readFromData( aData: NSData, ofType typeName: String) throws {
		let		theFormat : UnsafeMutablePointer<NSPropertyListFormat> = nil;
		do {
			if let thePropertList = try NSPropertyListSerialization.propertyListWithData(aData, options:.Immutable, format:theFormat) as? [String:AnyObject] {
				if let theIntervalCount = thePropertList["intervalCount"] as? UInt,
					theLimits = thePropertList["limits"] as? [String:Int],
					theEnableInterval = thePropertList["enableInterval"] as? Bool,
					themMaximumError = thePropertList["maximumError"] as? Double,
					theFiltered = thePropertList["filtered"] as? Bool,
					theTone = thePropertList["tone"] as? [String:AnyObject]
				{
					intervalCount = theIntervalCount
					if let theNumeratorPrimeLimitIndex = theLimits["numeratorPrime"] {
						numeratorPrimeLimitIndex = theNumeratorPrimeLimitIndex;
					}
					if let theDenominatorPrimeLimitIndex = theLimits["denominatorPrime"] {
						denominatorPrimeLimitIndex = theDenominatorPrimeLimitIndex;
					}
					if let theOddLimit : Int = theLimits["odd"] {
						oddLimit = UInt(theOddLimit);
					}
					enableInterval = theEnableInterval;
					maximumError = themMaximumError;
					filtered = theFiltered;
					if let theBaseFrequency = theTone["baseFrequency"] as? Double {
						baseFrequency = theBaseFrequency;
					}
					if let theAllOvertonesAmount = theTone["allOvertonesAmount"] as? Double {
						allOvertonesAmount = theAllOvertonesAmount;
					}
					if let theEvenOvertonesAmount = theTone["evenOvertonesAmount"] as? Double {
						evenOvertonesAmount = theEvenOvertonesAmount;
					}
				}
			}
			else {
				NSLog( "Failed to cast property list elements" );
			}
		}
		catch {
			NSLog( "Failed to parse property list" );
		}
	}

	@IBAction func selectPresetInterval( aSender: NSMenuItem ) {
		intervalCount = UInt(aSender.tag);
	}

	@IBAction func playAction( aSender: NSSegmentedControl ) {
		tonePlayer.playType( PlaybackType(rawValue:selectedPlaybackType) ?? .Unison );
	}


	override var windowNibName: String! { return "Document"; }

	override func windowControllerDidLoadNib(aWindowController: NSWindowController) {
		super.windowControllerDidLoadNib(aWindowController);
		calculateAllIntervals();
	}

	override class func autosavesInPlace() -> Bool { return true; }

	func calculateAllIntervals() {
		let		theDenominator = separatePrimeLimit ? denominatorPrimeLimit : numeratorPrimeLimit;
		let		theEntries = EqualTemperamentCollection(limits: (numeratorPrime:numeratorPrimeLimit,denominatorPrime:theDenominator,numeratorOdd:oddLimit,denominatorOdd:oddLimit), intervalCount: enableInterval ? intervalCount : 0, maximumError: maximumError, filtered: filtered );

		smallestErrorEntries = theEntries.smallestError;
		biggestErrorEntries = theEntries.biggestError;
		everyInterval.removeAll(keepCapacity: true);
		averageError = theEntries.averageError;
		everyInterval = theEntries.everyEntry;
		if let theLinearScaleView = linearScaleView {
			theLinearScaleView.numberOfIntervals = enableInterval ? intervalCount : 0;
			theLinearScaleView.everyRatios = everyInterval.map { return $0.justIntonationRatio; };
			theLinearScaleView.useIntervals = enableInterval;
		}
		if let thePitchConstellationView = pitchConstellationView {
			thePitchConstellationView.numberOfIntervals = enableInterval ? intervalCount : 0;
			thePitchConstellationView.everyRatios = everyInterval.map { return $0.justIntonationRatio; };
			thePitchConstellationView.useIntervals = enableInterval;
		}
	}

	var everyTableColumn : [NSTableColumn] {
		return tableView != nil ? tableView!.tableColumns as [NSTableColumn] : [];
	}

	func hideIntervalRelatedColumn( aHide : Bool ) {
		for theTableColumn in everyTableColumn {
			if ["interval","percent","error"].contains(theTableColumn.identifier) {
				theTableColumn.hidden = aHide;
			}
		}
		if let theLinearScaleView = linearScaleView {
			theLinearScaleView.useIntervals = !aHide;
		}
		if let thePitchConstellationView = pitchConstellationView {
			thePitchConstellationView.useIntervals = !aHide;
		}
	}
}

extension Document : NSTableViewDelegate {
	static let		cellColors = ( backgroundAlpha:CGFloat(0.1), maxErrorTextAlpha:CGFloat(0.25) );
	func tableView( aTableView: NSTableView, willDisplayCell aCell: AnyObject, forTableColumn aTableColumn: NSTableColumn?, row aRowIndex: Int) {
		if let	theEntry = arrayController!.arrangedObjects[UInt(aRowIndex)] as? EqualTemperamentEntry, theCell = aCell as? NSTextFieldCell {
			let		theExceedsError = enableInterval && abs(theEntry.error12ETCent) > 100.0*self.maximumError;
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

	func tableViewSelectionDidChange(notification: NSNotification) {
		let		theSelectedRatios = selectedJustIntonationRatio;
		updateChordRatioTitle();
		if let theLinearScaleView = linearScaleView {
			theLinearScaleView.selectedRatios = theSelectedRatios;
		}
		if let thePitchConstellationView = pitchConstellationView {
			thePitchConstellationView.selectedRatios = theSelectedRatios;
		}
		if let theHarmonicView = harmonicView {
			theHarmonicView.selectedRatios = theSelectedRatios;
		}
		if let theWaveView = waveView {
			theWaveView.selectedRatios = theSelectedRatios;
		}
		if let theSpectrumView = spectrumView {
			theSpectrumView.selectedRatios = theSelectedRatios;
		}
	}
}

