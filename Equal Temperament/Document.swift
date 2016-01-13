/*
    Document.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Cocoa

class Document : NSDocument {
	static let		minimumBaseFrequency = 20.0;
	static let		maximumBaseFrequency = 4_200.0;

	@IBOutlet var	tableParentContainerView : NSView?
	@IBOutlet var	arrayController : NSArrayController?
	@IBOutlet var	scaleViewController : ScaleViewController?
	@IBOutlet var	harmonicViewController : HarmonicViewController?
	@IBOutlet var	waveViewController : WaveViewController?
	@IBOutlet var	spectrumViewController : SpectrumViewController?;
	@IBOutlet var	tableView : NSTableView?;
	@IBOutlet var	baseFrequencyTextField : NSTextField?;
	@IBOutlet var	documentWindow : NSWindow?;
	@IBOutlet var	harmonicTitleTextField : NSTextField?;
	@IBOutlet var	baseFrequencyDeltaSlider : NSSlider?;

	var		previousBaseFrequencyDelta : Double = 0.0;

	static private var		onceToken = false;
	override class func initialize() {
		if onceToken {
			if let theURL = NSBundle.mainBundle().URLForResource( "InitialUserDefaults", withExtension:"plist" ) {
				if let theDictionary = NSDictionary(contentsOfURL:theURL ) as? [String : AnyObject] {
					NSUserDefaults.standardUserDefaults().registerDefaults(theDictionary);
					onceToken = true;
				}
			}
		}
	}

	var		selectedMethod : UInt = 0 {
		didSet {
			calculateAllIntervals();
		}
	}

	var		primeNumber = UInt.primes(upTo: 100 );
	func	indexForLargestPrimeLessThanOrEuqalTo( aPrime : UInt ) -> Int? {
		for i in 1...primeNumber.endIndex {
			if primeNumber[i] > aPrime { return i-1; }
		}
		return nil;
	}

	var		intervalCount : UInt = 12 {
		didSet {
			enableInterval = true;
			calculateAllIntervals();
		}
	}
	var		octavesCount : UInt = 1 {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(octavesCount), forKey:"octavesCount");
			calculateAllIntervals();
		}
	}
	dynamic var		enableInterval : Bool = true {
		didSet {
			hideIntervalRelatedColumn(!enableInterval);
		}
	}
	var		numeratorPrimeLimit : UInt {
		get { return primeNumber[numeratorPrimeLimitIndex]; }
		set { numeratorPrimeLimitIndex = indexForLargestPrimeLessThanOrEuqalTo(newValue) ?? 2; }
	}
	var		numeratorPrimeLimitIndex : Int = 2 {
		didSet {
			willChangeValueForKey("numeratorPrimeLimit");
			NSUserDefaults.standardUserDefaults().setInteger(Int(numeratorPrimeLimit), forKey:"numeratorPrimeLimit");
			calculateAllIntervals();
			didChangeValueForKey("numeratorPrimeLimit");
		}
	}
	var		denominatorPrimeLimit : UInt {
		get { return primeNumber[denominatorPrimeLimitIndex]; }
		set { denominatorPrimeLimitIndex = indexForLargestPrimeLessThanOrEuqalTo(newValue) ?? 2; }
	}
	var		denominatorPrimeLimitIndex : Int = 1 {
		didSet {
			willChangeValueForKey("denominatorPrimeLimit");
			NSUserDefaults.standardUserDefaults().setInteger(Int(denominatorPrimeLimit), forKey:"denominatorPrimeLimit");
			calculateAllIntervals();
			didChangeValueForKey("denominatorPrimeLimit");
		}
	}
	var		separatePrimeLimit : Bool = false {
		didSet {
			NSUserDefaults.standardUserDefaults().setBool( separatePrimeLimit, forKey:"separatePrimeLimit");
			calculateAllIntervals();
		}
	}
	var		numeratorOddLimit : UInt = 15 {
		didSet {
			if( numeratorOddLimit%2 == 0 ) { numeratorOddLimit++; }
			NSUserDefaults.standardUserDefaults().setInteger( Int(numeratorOddLimit), forKey:"numeratorOddLimit");
			calculateAllIntervals();
		}
	}
	var		denominatorOddLimit : UInt = 15 {
		didSet {
			if( denominatorOddLimit%2 == 0 ) { denominatorOddLimit++; }
			NSUserDefaults.standardUserDefaults().setInteger( Int(denominatorOddLimit), forKey:"denominatorOddLimit");
			calculateAllIntervals();
		}
	}
	var		separateOddLimit : Bool = false {
		didSet {
			NSUserDefaults.standardUserDefaults().setBool( separateOddLimit, forKey:"separateOddLimit");
			calculateAllIntervals();
		}
	}
	var		maximumError : Double = 0.18 {
		didSet {
			NSUserDefaults.standardUserDefaults().setDouble( maximumError, forKey:"maximumError");
			calculateAllIntervals();
		}
	}
	var		filtered : Bool = false {
		didSet {
			NSUserDefaults.standardUserDefaults().setBool( separateOddLimit, forKey:"separateOddLimit");
			calculateAllIntervals();
		}
	}
	var		autoAnchor : Bool = false {
		didSet { NSUserDefaults.standardUserDefaults().setBool( autoAnchor, forKey:"autoAnchor"); }
	}
	var		equalTemperament : Bool = false {
		didSet {
			NSUserDefaults.standardUserDefaults().setBool( separateOddLimit, forKey:"equalTemperament");
			tonePlayer.equalTemperament = equalTemperament;
		}
	}

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
		set(anEqualTemperamentEntries) {
			if let theArrangedController = arrayController {
				let		theIndicies = NSMutableIndexSet();
				for theEntry in anEqualTemperamentEntries {
					if let theIndex = everyInterval.indexOf(theEntry) {
						theIndicies.addIndex(theIndex);
					}
				}
				theArrangedController.setSelectionIndexes(theIndicies);
			}
		}
		get {
			var		theResult : [EqualTemperamentEntry] = [];
			if let theArrangedRations = arrayController?.selectedObjects as? [EqualTemperamentEntry] {
				theResult = theArrangedRations;
			}
			return theResult;
		}
	}
	var		selectedJustIntonationIntervals : [Interval] {
		return selectedEqualTemperamentEntry.map { return $0.interval; };
	}

	var		baseFrequency : Double {
		get { return tonePlayer.baseFrequency; }
		set( aValue ) {
			let		theValue = max(min(aValue,Document.maximumBaseFrequency), Document.minimumBaseFrequency);
			self.willChangeValueForKey("baseFrequency");
			tonePlayer.baseFrequency = theValue;
			self.didChangeValueForKey("baseFrequency");
		}
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
	var		arpeggioBeatPerMinute : Double {
		get { return 60.0/tonePlayer.arpeggioInterval; }
		set( aValue ) { tonePlayer.arpeggioInterval = 60.0/aValue }
	}
	var		tonePlayer = TonePlayer();

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
	dynamic var		midiExpanded : Bool {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setBool(aValue, forKey: "midiExpanded"); }
		get { return NSUserDefaults.standardUserDefaults().boolForKey("midiExpanded"); }
	}
	dynamic var		audioExpanded : Bool {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setBool(aValue, forKey: "audioExpanded"); }
		get { return NSUserDefaults.standardUserDefaults().boolForKey("audioExpanded"); }
	}
	dynamic var		savedExpanded : Bool {
		set( aValue ) { NSUserDefaults.standardUserDefaults().setBool(aValue, forKey: "savedExpanded"); }
		get { return NSUserDefaults.standardUserDefaults().boolForKey("savedExpanded"); }
	}

	dynamic var     everyInterval : [EqualTemperamentEntry] = [];
	dynamic var		smallestError : Double { get { return !smallestErrorEntries.isEmpty ? smallestErrorEntries.first!.error : 0.0; } }
	dynamic var     averageError : Double = 0.0
	dynamic var		biggestError : Double { get { return !biggestErrorEntries.isEmpty ? biggestErrorEntries.first!.error : 0.0; } }
	dynamic var		midiAnchor : Int = 60 {
		didSet { NSUserDefaults.standardUserDefaults().setInteger(midiAnchor, forKey: "midiAnchor"); }
	}
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
			if selectedJustIntonationIntervals.count > 1 {
				var		theRatiosString : String = "";
				var		theCommonFactor = 1;
				for theValue in selectedJustIntonationIntervals {
					theCommonFactor *= theValue.denominator/greatestCommonDivisor(theCommonFactor, theValue.denominator);
				}
				for theRatio in selectedJustIntonationIntervals {
					if let theValue = theRatio.ratio.numeratorForDenominator(theCommonFactor) {
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
			else if let theSingle = selectedJustIntonationIntervals.first {
				theHarmonicTitleTextField.stringValue = theSingle.ratio.ratioString;
			}
			else {
				theHarmonicTitleTextField.stringValue = "";
			}
		}
	}

	override func windowControllerWillLoadNib(aWindowController: NSWindowController) {
		numeratorPrimeLimit = UInt(NSUserDefaults.standardUserDefaults().integerForKey("numeratorPrimeLimit"));
		denominatorPrimeLimit = UInt(NSUserDefaults.standardUserDefaults().integerForKey("denominatorPrimeLimit"));
		numeratorOddLimit = UInt(NSUserDefaults.standardUserDefaults().integerForKey("numeratorOddLimit")) | 1;
		denominatorOddLimit = UInt(NSUserDefaults.standardUserDefaults().integerForKey("denominatorOddLimit")) | 1;
		octavesCount = min(max(UInt(NSUserDefaults.standardUserDefaults().integerForKey("octavesCount")),1),3);
		midiAnchor = NSUserDefaults.standardUserDefaults().integerForKey("midiAnchor");
		tonePlayer.harmonics = overtones;
		tonePlayer.baseFrequency = baseFrequency;
		tonePlayer.equalTempIntervalCount = intervalCount;

		if let theBaseFrequencyDeltaSlider = baseFrequencyDeltaSlider {
			theBaseFrequencyDeltaSlider.continuous = true;
			previousBaseFrequencyDelta = theBaseFrequencyDeltaSlider.doubleValue;
		}
	}

	override func dataOfType( typeName: String) throws -> NSData {
		var anError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
		let		thePropertyList = [
			"selectedMethod":selectedMethod,
			"intervalCount":intervalCount,
			"limits":[
				"numeratorPrime":numeratorPrimeLimit,
				"denominatorPrime":denominatorPrimeLimit,
				"numeratorOdd":numeratorOddLimit,
				"denominatorOddLimit":denominatorOddLimit],
			"enableInterval":enableInterval,
			"maximumError":maximumError,
			"filtered":filtered,
			"autoAnchor":autoAnchor,
			"equalTemperament":equalTemperament,
			"octavesCount":octavesCount,
			"midiAnchor":midiAnchor,
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
			if let thePropertyList = try NSPropertyListSerialization.propertyListWithData(aData, options:.Immutable, format:theFormat) as? [String:AnyObject] {
				if let theSelectedMethod = thePropertyList["selectedMethod"] as? UInt,
					theIntervalCount = thePropertyList["intervalCount"] as? UInt,
					theLimits = thePropertyList["limits"] as? [String:Int],
					theEnableInterval = thePropertyList["enableInterval"] as? Bool,
					themMaximumError = thePropertyList["maximumError"] as? Double,
					theFiltered = thePropertyList["filtered"] as? Bool,
					theOctavesCount = thePropertyList["octavesCount"] as? UInt,
					theAutoAnchor = thePropertyList["autoAnchor"] as? Bool,
					theEqualTemperament = thePropertyList["equalTemperament"] as? Bool,
					theMidiAnchor = thePropertyList["midiAnchor"] as? Int,
					theTone = thePropertyList["tone"] as? [String:AnyObject]
				{
					selectedMethod = theSelectedMethod;
					intervalCount = theIntervalCount
					if let theNumeratorPrimeLimit = theLimits["numeratorPrime"] {
						numeratorPrimeLimit = UInt(theNumeratorPrimeLimit);
					}
					if let theDenominatorPrimeLimit = theLimits["denominatorPrime"] {
						denominatorPrimeLimit = UInt(theDenominatorPrimeLimit);
					}
					if let theNumeratorOddLimit : Int = theLimits["numeratorOdd"] {
						numeratorOddLimit = UInt(theNumeratorOddLimit);
					}
					if let theDenominatorOddLimit : Int = theLimits["denominatorOdd"] {
						denominatorOddLimit = UInt(theDenominatorOddLimit);
					}
					enableInterval = theEnableInterval;
					maximumError = themMaximumError;
					filtered = theFiltered;
					octavesCount = theOctavesCount;
					autoAnchor = theAutoAnchor;
					equalTemperament = theEqualTemperament;
					midiAnchor = theMidiAnchor;
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

	var		previouslySelectedSegment : Int = -1;

	@IBAction func playAction( aSender: NSSegmentedControl ) {
		if aSender.selectedSegment == previouslySelectedSegment && tonePlayer.playing {
			tonePlayer.stop();
			aSender.setSelected( false, forSegment: previouslySelectedSegment);
			previouslySelectedSegment = -1;
		}
		else {
			let			thePlaybackType = PlaybackType(rawValue:aSender.selectedSegment) ?? .Unison;
			if tonePlayer.playing {
				aSender.setSelected( false, forSegment: previouslySelectedSegment);
			}
			previouslySelectedSegment = aSender.selectedSegment;
			tonePlayer.stop();
			tonePlayer.playType(thePlaybackType);
			aSender.setSelected( true, forSegment: aSender.selectedSegment);
		}
	}

	@IBAction func baseFrequencyDeltaChanged( aSender: NSSlider ) {
		let		theMinValue = aSender.minValue;
		let		theMaxValue = aSender.maxValue;
		let		theBaseFrequencyDelta = aSender.doubleValue;
		var		theNegativeDelta = 0.0;
		var		thePositiveDelta = 0.0;

		if previousBaseFrequencyDelta > theBaseFrequencyDelta {
			theNegativeDelta = previousBaseFrequencyDelta - theBaseFrequencyDelta;
			thePositiveDelta = (theBaseFrequencyDelta - theMinValue) + (theMaxValue - previousBaseFrequencyDelta);
		}
		else if previousBaseFrequencyDelta < theBaseFrequencyDelta {
			theNegativeDelta = (previousBaseFrequencyDelta - theMinValue) + (theMaxValue - theBaseFrequencyDelta);
			thePositiveDelta = theBaseFrequencyDelta - previousBaseFrequencyDelta;
		}

		assert( theNegativeDelta >= 0.0 );
		assert( thePositiveDelta >= 0.0 );
		assert( theNegativeDelta <= (theMaxValue-theMinValue) && thePositiveDelta <= (theMaxValue-theMinValue)/2.0
				|| theNegativeDelta <= (theMaxValue-theMinValue)/2.0 && thePositiveDelta <= (theMaxValue-theMinValue) );

		if theNegativeDelta < thePositiveDelta {
			baseFrequency /= theNegativeDelta+1.0;
		} else if theNegativeDelta > thePositiveDelta {
			baseFrequency *= thePositiveDelta+1.0;
		}

		previousBaseFrequencyDelta = theBaseFrequencyDelta;
	}

	override var windowNibName: String! { return "Document"; }

	override func windowControllerDidLoadNib(aWindowController: NSWindowController) {
		super.windowControllerDidLoadNib(aWindowController);
		calculateAllIntervals();
	}

	override class func autosavesInPlace() -> Bool { return true; }

	func calculateAllIntervals() {
		let		theSelectedEntries = selectedEqualTemperamentEntry;
		let		theDenominatorPrimeLimit = separatePrimeLimit ? denominatorPrimeLimit : numeratorPrimeLimit;
		let		theDenominatorOddLimit = separateOddLimit ? denominatorOddLimit : numeratorOddLimit;
		let		theEntries = EqualTemperamentCollection(limits: (numeratorPrime:numeratorPrimeLimit,denominatorPrime:theDenominatorPrimeLimit,numeratorOdd:numeratorOddLimit,denominatorOdd:theDenominatorOddLimit), intervalCount: enableInterval ? intervalCount : 0, octaves: octavesCount, maximumError: maximumError, filtered: filtered );
		smallestErrorEntries = theEntries.smallestError;
		biggestErrorEntries = theEntries.biggestError;
		averageError = theEntries.averageError;
		everyInterval = theEntries.everyEntry;
		if let theScaleViewController = scaleViewController {
			theScaleViewController.setIntervals(intervals: everyInterval, intervalCount: intervalCount, enabled: enableInterval);
		}
		selectedEqualTemperamentEntry = theSelectedEntries;
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
		if let theScaleViewController = scaleViewController { theScaleViewController.hideIntervalRelatedColumn(!aHide); }
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
		let		theSelectedIntervals = selectedJustIntonationIntervals;
		updateChordRatioTitle();
		assert(scaleViewController != nil, "Failed to get ScaleViewController")
		if let theScaleViewController = scaleViewController {
			theScaleViewController.setSelectionIntervals(theSelectedIntervals);
		}
		assert(harmonicViewController != nil, "Failed to get HarmonicViewController")
		if let theHarmonicViewController = harmonicViewController {
			theHarmonicViewController.setSelectionIntervals(theSelectedIntervals);
		}
		assert(waveViewController != nil, "Failed to get WaveViewController")
		if let theWaveViewController = waveViewController {
			theWaveViewController.setSelectionIntervals(theSelectedIntervals);
		}
		assert(spectrumViewController != nil, "Failed to get SpectrumViewController")
		if let theSpectrumViewController = spectrumViewController {
			theSpectrumViewController.setSelectionIntervals(theSelectedIntervals);
		}
		tonePlayer.intervals = theSelectedIntervals;
	}
}

