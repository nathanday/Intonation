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
	@IBOutlet var	linearScaleView : ScaleView?;
	@IBOutlet var	pitchConstellationView : ScaleView?;
	@IBOutlet var	harmonicView : HarmonicView?;
	@IBOutlet var	waveView : WaveView?;
	@IBOutlet var	spectrumView : SpectrumView?;
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
		didSet {
			willChangeValueForKey("numeratorPrimeLimit");
			NSUserDefaults.standardUserDefaults().setInteger(numeratorPrimeLimitIndex, forKey:"numeratorPrimeLimit");
			calculateAllIntervals();
			didChangeValueForKey("numeratorPrimeLimit");
		}
	}
	var		denominatorPrimeLimit : UInt { get { return primeNumber[denominatorPrimeLimitIndex]; } }
	var		denominatorPrimeLimitIndex : Int = 1 {
		didSet {
			willChangeValueForKey("denominatorPrimeLimit");
			NSUserDefaults.standardUserDefaults().setInteger(denominatorPrimeLimitIndex, forKey:"denominatorPrimeLimit");
			calculateAllIntervals();
			didChangeValueForKey("denominatorPrimeLimit");
		}
	}
	var		separatePrimeLimit : Bool = false { didSet { calculateAllIntervals(); } }
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
	var		separateOddLimit : Bool = false { didSet { calculateAllIntervals(); } }
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
					theCommonFactor *= theValue.denominator/greatestCommonDivisor(theCommonFactor, theValue.denominator);
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
		numeratorPrimeLimitIndex = NSUserDefaults.standardUserDefaults().integerForKey("numeratorPrimeLimit");
		denominatorPrimeLimitIndex = NSUserDefaults.standardUserDefaults().integerForKey("denominatorPrimeLimit");
		numeratorOddLimit = UInt(NSUserDefaults.standardUserDefaults().integerForKey("numeratorOddLimit"));
		denominatorOddLimit = UInt(NSUserDefaults.standardUserDefaults().integerForKey("denominatorOddLimit"));
		tonePlayer.harmonics = overtones;
		tonePlayer.baseFrequency = baseFrequency;

		if let theBaseFrequencyDeltaSlider = baseFrequencyDeltaSlider {
			theBaseFrequencyDeltaSlider.continuous = true;
			previousBaseFrequencyDelta = theBaseFrequencyDeltaSlider.doubleValue;
		}
	}

	override func dataOfType( typeName: String) throws -> NSData {
		var anError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
		let		thePropertyList = [
			"intervalCount":intervalCount,
			"limits":[
				"numeratorPrime":numeratorPrimeLimitIndex,
				"denominatorPrime":denominatorPrimeLimitIndex,
				"numeratorOdd":numeratorOddLimit,
				"denominatorOddLimit":denominatorOddLimit],
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
					if let theNumeratorOddLimit : Int = theLimits["numeratorOdd"] {
						numeratorOddLimit = UInt(theNumeratorOddLimit);
					}
					if let theDenominatorOddLimit : Int = theLimits["denominatorOdd"] {
						denominatorOddLimit = UInt(theDenominatorOddLimit);
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

		if theNegativeDelta < thePositiveDelta {
			baseFrequency -= pow(baseFrequency,pow(theNegativeDelta,4.0));
		} else if theNegativeDelta > thePositiveDelta {
			baseFrequency += pow(baseFrequency,pow(thePositiveDelta,4.0));
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
		let		theDenominatorPrimeLimit = separatePrimeLimit ? denominatorPrimeLimit : numeratorPrimeLimit;
		let		theDenominatorOddLimit = separateOddLimit ? denominatorOddLimit : numeratorOddLimit;
		let		theEntries = EqualTemperamentCollection(limits: (numeratorPrime:numeratorPrimeLimit,denominatorPrime:theDenominatorPrimeLimit,numeratorOdd:numeratorOddLimit,denominatorOdd:theDenominatorOddLimit), intervalCount: enableInterval ? intervalCount : 0, maximumError: maximumError, filtered: filtered );
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
		tonePlayer.ratios = theSelectedRatios;
	}
}

