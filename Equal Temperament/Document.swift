/*
    Document.swift
    Intonation

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Cocoa

public let PlayBackMethodChangedNotification = "PlayBackMethodChanged";
public let PlayBackMethodUserInfoKey = "PlayBackMethod";

class Document : NSDocument, MIDIReceiverObserver {
	var		tonePlayer = TonePlayer();
	var		midiReceiver = MIDIReceiver(clientName:"Intonation");
	var		midiToHarmonicRatio = MIDIToHarmonicRatio();


	var		intervalsData : IntervalsData? {
		willSet {
			removeIntervalsDataObservers();
		}
		didSet {
			if let theIntervalData = intervalsData {
				tonePlayer.harmonics = theIntervalData.overtones;
				tonePlayer.baseFrequency = theIntervalData.baseFrequency;
				setUpIntervalsDataObservers();
			}
		}
	}
	let watchedKeys : Set = ["documentType", "octavesCount", "numeratorPrimeLimitIndex", "denominatorPrimeLimitIndex", "separatePrimeLimit", "oddLimit", "additiveDissonance", "stackedIntervals", "degrees", "interval", "adHocEntries"];

	override func observeValueForKeyPath( aKeyPath: String?, ofObject anObject: AnyObject?, change aChange: [String : AnyObject]?, context aContext: UnsafeMutablePointer<Void>) {
		if anObject as? IntervalsData == intervalsData {
			if let theKey = aKeyPath {
				if watchedKeys.contains(theKey) {
					calculateAllIntervals();
				}
			}
		}
	}

	func setUpIntervalsDataObservers() {
		for theKey in watchedKeys {
			intervalsData?.addObserver(self, forKeyPath:theKey, options: NSKeyValueObservingOptions.New, context:nil)
		}
	}

	func removeIntervalsDataObservers() {
		for theKey in watchedKeys {
			intervalsData?.removeObserver(self, forKeyPath:theKey);
		}
	}

	func showWithIntervals( anItervals : [Interval]) {
		let		theIntervalsData = AdHocIntervalsData();
		intervalsData = theIntervalsData;
		theIntervalsData.addIntervals(anItervals);
		makeWindowControllers();
		showWindows();
	}

	deinit {
		removeIntervalsDataObservers();
	}

	dynamic var		baseFrequency : Double {
		get { return intervalsData?.baseFrequency ?? 220.0; }
		set( aValue ) {
			let		theValue = max(min(aValue,IntervalsData.maximumBaseFrequency), IntervalsData.minimumBaseFrequency);
			intervalsData?.baseFrequency = theValue;
			tonePlayer.baseFrequency = intervalsData?.baseFrequency ?? 220.0;
			midiToHarmonicRatio.baseFrequency = intervalsData?.baseFrequency ?? 220.0;
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
		set( aValue ) {
			if let theIntervalsData = intervalsData {
				theIntervalsData.overtones = aValue;
				tonePlayer.harmonics = theIntervalsData.overtones;
			}
		}
		get { return intervalsData?.overtones ?? HarmonicsDescription(amount: 0.5, evenAmount: 1.0); }
	}
	var		arpeggioBeatPerMinute : Double {
		set( aValue ) {
			if let theIntervalsData = intervalsData {
				theIntervalsData.arpeggioInterval = 60.0/aValue
				tonePlayer.arpeggioInterval = theIntervalsData.arpeggioInterval;
			}
		}
		get { return 60.0/(intervalsData?.arpeggioInterval ?? 1); }
	}

	var		currentlySelectedMethod : Int? = nil;

	@IBAction func baseFrequencyChangedAction( aSender: NSTextField? ) {
		if let theTextField = aSender {
			intervalsData?.baseFrequency = theTextField.doubleValue;
		}
	}

	@IBAction func newDocumentFromSelection( aSender: AnyObject? ) {
		do {
			if let theDocument = try NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(false) as?
			Document {
				theDocument.showWithIntervals(selectedJustIntonationIntervals);
			}
		}
		catch {
			print( "error" );
		}
	}

	func playUsingMethod( aMethod: Int ) {
		if aMethod == currentlySelectedMethod && tonePlayer.playing {
			tonePlayer.stop();
			currentlySelectedMethod = nil;
			NSNotificationCenter.defaultCenter().postNotificationName(PlayBackMethodChangedNotification, object: self);
		}
		else {
			let			thePlaybackType = PlaybackType(rawValue:aMethod) ?? .Unison;
			if tonePlayer.playing {
			}
			currentlySelectedMethod = aMethod;
			tonePlayer.stop();
			tonePlayer.playType(thePlaybackType);
			NSNotificationCenter.defaultCenter().postNotificationName(PlayBackMethodChangedNotification, object: self, userInfo: [PlayBackMethodUserInfoKey: aMethod]);
		}
	}

	override class func autosavesInPlace() -> Bool { return true; }
	override func dataOfType( typeName: String) throws -> NSData {
		var anError: NSError = NSError(domain: "Migrator", code: 0, userInfo: nil)
		let		theResult: NSData?
		do {
			theResult = try NSPropertyListSerialization.dataWithPropertyList(intervalsData!.propertyListValue, format:.XMLFormat_v1_0, options:0)
		} catch let error as NSError {
			anError = error
			theResult = nil
		};
		if theResult == nil {
			throw anError;
		}
		return theResult!;
	}

	override func readFromData( aData: NSData, ofType typeName: String) throws {
		let		theFormat : UnsafeMutablePointer<NSPropertyListFormat> = nil;
		do {
			if let thePropertyList = try NSPropertyListSerialization.propertyListWithData(aData, options:.Immutable, format:theFormat) as? [String:AnyObject] {
				intervalsData = IntervalsData.from(propertyList:thePropertyList);
			}
		}
		catch {
			NSLog( "Failed to parse property list" );
		}
	}

	override func makeWindowControllers() {
		let		theWindowController = MainWindowController();
		self.addWindowController(theWindowController);
		setUpIntervalsDataObservers();
		midiReceiver.observer = self;
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

	func	indexFor(equalTemperamentEntry anEqualTemperamentEntry: EqualTemperamentEntry) -> Int? {
		return everyInterval.indexOf(anEqualTemperamentEntry);
	}
	func	select( index anIndex: Int ) {
		let		theIndicies = NSMutableIndexSet(indexSet: selectedIndicies);
		theIndicies.addIndex(anIndex);
		selectedIndicies = theIndicies;
	}
	func	unselect( index anIndex: Int ) {
		let		theIndicies = NSMutableIndexSet(indexSet: selectedIndicies);
		theIndicies.removeIndex(anIndex);
		selectedIndicies = theIndicies;
	}
	dynamic var		selectedIndicies = NSIndexSet() {
		didSet {
			tonePlayer.intervals = selectedJustIntonationIntervals;
		}
	}
	var		selectedEqualTemperamentEntry : [EqualTemperamentEntry] {
		set(anEqualTemperamentEntries) {
			let		theIndicies = NSMutableIndexSet();
			for theEntry in anEqualTemperamentEntries {
				if let theIndex = everyInterval.indexOf(theEntry) {
					theIndicies.addIndex(theIndex);
				}
			}
			selectedIndicies = theIndicies;
		}
		get {
			var		theResult = [EqualTemperamentEntry]();
			for theIndex in selectedIndicies {
				theResult.append(everyInterval[theIndex]);
			}
			return theResult;
		}
	}
	var		selectedJustIntonationIntervals : [Interval] {
		return selectedEqualTemperamentEntry.map { return $0.interval; };
	}

	func calculateAllIntervals() {
		if let theIntervalData = intervalsData {
			let		theSelectedEntries = selectedEqualTemperamentEntry;
			let		theGenerator = theIntervalData.intervalsDataGenerator( );
			smallestErrorEntries = theGenerator.smallestError;
			biggestErrorEntries = theGenerator.biggestError;
			averageError = theGenerator.averageError;
			everyInterval = theGenerator.everyEntry;
			selectedEqualTemperamentEntry = theSelectedEntries;
		}
	}

	// MIDIReceiverObserver methods
	func midiReceiverNoteOff( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) {
		if let theEntry = midiToHarmonicRatio.popRatioFor(midiNote: aNote) {
			if let theIndex = indexFor(equalTemperamentEntry: theEntry) {
				unselect(index: theIndex);
			}
		}
	}
	func midiReceiverNoteOn( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) {
		let		theEntry = midiToHarmonicRatio.pushRatioFor(midiNote: aNote, everyInterval: everyInterval );
		if let theIndex = indexFor(equalTemperamentEntry: theEntry) {
			select(index: theIndex);
		}
	}
}
