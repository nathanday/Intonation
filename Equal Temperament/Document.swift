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


	dynamic var		intervalsData : IntervalsData? {
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
	let watchedKeys : Set = ["additiveDissonance", "adHocEntries", "degrees", "denominatorPrimeLimitIndex", "documentType", "interval", "numeratorPrimeLimitIndex", "octavesCount", "oddLimit", "separatePrimeLimit", "stackedIntervals"];

	override func observeValue( forKeyPath aKeyPath: String?, of anObject: Any?, change aChange: [NSKeyValueChangeKey : Any]?, context aContext: UnsafeMutableRawPointer?) {
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
			intervalsData?.addObserver(self, forKeyPath:theKey, options: NSKeyValueObservingOptions.new, context:nil)
		}
	}

	func removeIntervalsDataObservers() {
		if let theIntervalsData = intervalsData {
			for theKey in watchedKeys {
				theIntervalsData.removeObserver(self, forKeyPath:theKey);
			}
		}
	}

	func showWithIntervals( _ anItervals : [Interval]) {
		let		theIntervalsData = AdHocIntervalsData();
		willChangeValue(forKey: "intervalsData");
		intervalsData = theIntervalsData;
		didChangeValue(forKey: "intervalsData");
		theIntervalsData.addIntervals(anItervals);
		makeWindowControllers();
		showWindows();
	}

	deinit {
		tonePlayer.stop();
		removeIntervalsDataObservers();
	}

	var		playbackPaused : Bool = false {
		didSet {
			switch playbackPaused {
			case true:
				tonePlayer.stop();
			default:
				if currentlySelectedMethod != nil {
					tonePlayer.resume();
				}
			}
		}
	}

	override func canClose(withDelegate delegate: Any, shouldClose shouldCloseSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		tonePlayer.stop();
		super.canClose(withDelegate: delegate, shouldClose: shouldCloseSelector, contextInfo: contextInfo);
	}

	dynamic var		baseFrequency : Double {
		get {
			return intervalsData?.baseFrequency ?? 220.0;
		}
		set( aValue ) {
			let		theMinimumBaseFrequency = max(UserDefaults.standard.double(forKey: "minimumBaseFrequency"),4.0);
			let		theMaximumBaseFrequency = max(UserDefaults.standard.double(forKey: "maximumBaseFrequency"),20_000.0);
			let		theValue = max(min(aValue,theMaximumBaseFrequency), theMinimumBaseFrequency);
			intervalsData?.baseFrequency = theValue;
			tonePlayer.baseFrequency = intervalsData?.baseFrequency ?? 220.0;
			midiToHarmonicRatio.baseFrequency = intervalsData?.baseFrequency ?? 220.0;
		}
	}
	var		allOvertonesAmount : Double {
		get { return overtones.amount; }
		set( aValue ) { overtones = HarmonicsDescription(amount: aValue, evenAmount: overtones.evenAmount, spectrumStretch: overtones.spectrumStretch ); }
	}
	var		evenOvertonesAmount : Double {
		get { return overtones.evenAmount; }
		set( aValue ) { overtones = HarmonicsDescription(amount: overtones.amount, evenAmount: aValue, spectrumStretch: overtones.spectrumStretch); }
	}
	var		spectrumStretch : Double {
		get { return overtones.spectrumStretch; }
		set( aValue ) { overtones = HarmonicsDescription(amount: overtones.amount, evenAmount: overtones.evenAmount, spectrumStretch: aValue ); }
	}


	var		overtones : HarmonicsDescription {
		set( aValue ) {
			if let theIntervalsData = intervalsData {
				theIntervalsData.overtones = aValue;
				tonePlayer.harmonics = theIntervalsData.overtones;
			}
		}
		get {
			return intervalsData?.overtones ?? HarmonicsDescription();
		}
	}
	var		arpeggioBeatPerMinute : Double {
		set( aValue ) {
			if let theIntervalsData = intervalsData {
				theIntervalsData.arpeggioInterval = 60.0/aValue
				tonePlayer.arpeggioInterval = theIntervalsData.arpeggioInterval;
			}
		}
		get {
			return 60.0/(intervalsData?.arpeggioInterval ?? 1);
		}
	}

	var		currentlySelectedMethod : Int? = nil;

	@IBAction func baseFrequencyChangedAction( _ aSender: NSTextField? ) {
		if let theTextField = aSender {
			intervalsData?.baseFrequency = theTextField.doubleValue;
		}
	}

	@IBAction func newDocumentFromSelection( _ aSender: Any? ) {
		do {
			if let theDocument = try NSDocumentController.shared().openUntitledDocumentAndDisplay(false) as?
			Document {
				theDocument.showWithIntervals(selectedJustIntonationIntervals);
			}
		}
		catch {
			self.print( "error" );
		}
	}

	func playUsingMethod( _ aMethod: Int ) {
		if aMethod == currentlySelectedMethod && tonePlayer.playing {
			tonePlayer.stop();
			currentlySelectedMethod = nil;
			NotificationCenter.default.post(name: Notification.Name(rawValue: PlayBackMethodChangedNotification), object: self);
		}
		else {
			let			thePlaybackType = PlaybackType(rawValue:aMethod) ?? .unison;
			if tonePlayer.playing {
			}
			currentlySelectedMethod = aMethod;
			tonePlayer.stop();
			tonePlayer.playType(thePlaybackType);
			NotificationCenter.default.post(name: Notification.Name(rawValue: PlayBackMethodChangedNotification), object: self, userInfo: [PlayBackMethodUserInfoKey: aMethod]);
		}
	}

	override class func autosavesInPlace() -> Bool { return true; }
	override func data( ofType typeName: String) throws -> Data {
		var anError: NSError = NSError(domain: "Migrator", code: 0, userInfo: nil)
		let		theResult: Data?
		do {
			theResult = try PropertyListSerialization.data(fromPropertyList: intervalsData!.propertyListValue, format:.xml, options:0)
		} catch let error as NSError {
			anError = error
			theResult = nil
		};
		if theResult == nil {
			throw anError;
		}
		return theResult!;
	}

	override func read( from aData: Data, ofType typeName: String) throws {
		let		theFormat : UnsafeMutablePointer<PropertyListSerialization.PropertyListFormat>? = nil;
		do {
			if let thePropertyList = try PropertyListSerialization.propertyList(from: aData, options:PropertyListSerialization.MutabilityOptions(), format:theFormat) as? [String:Any] {
				willChangeValue(forKey: "intervalsData");
				intervalsData = IntervalsData.from(propertyList:thePropertyList);
				didChangeValue(forKey: "intervalsData");
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

	dynamic var     everyInterval : [IntervalEntry] = [];
	dynamic var		smallestError : Double { get { return !smallestErrorEntries.isEmpty ? smallestErrorEntries.first!.error : 0.0; } }
	dynamic var     averageError : Double = 0.0
	dynamic var		biggestError : Double { get { return !biggestErrorEntries.isEmpty ? biggestErrorEntries.first!.error : 0.0; } }
	dynamic var		smallestErrorEntries : Set<IntervalEntry> = [] {
		willSet { self.willChangeValue(forKey: "smallestError"); }
		didSet { self.didChangeValue(forKey: "smallestError"); }
	}
	dynamic var		biggestErrorEntries : Set<IntervalEntry> = [] {
		willSet { self.willChangeValue(forKey: "biggestError"); }
		didSet { self.didChangeValue(forKey: "biggestError"); }
	}

	func	indexFor(equalTemperamentEntry anIntervalEntry: IntervalEntry) -> Int? {
		return everyInterval.index(of: anIntervalEntry);
	}
	func	select( index anIndex: Int ) {
		let		theIndicies = NSMutableIndexSet(indexSet:selectedIndicies);
		theIndicies.add(anIndex);
		selectedIndicies = theIndicies as IndexSet;
	}
	func	unselect( index anIndex: Int ) {
		let		theIndicies = NSMutableIndexSet(indexSet:selectedIndicies);
		theIndicies.remove(anIndex);
		selectedIndicies = theIndicies as IndexSet;
	}
	dynamic var		selectedIndicies = IndexSet() {
		didSet {
			tonePlayer.intervals = selectedJustIntonationIntervals;
		}
	}
	var		selectedIntervalEntry : [IntervalEntry] {
		set(anIntervalEntries) {
			let		theIndicies = NSMutableIndexSet();
			for theEntry in anIntervalEntries {
				if let theIndex = everyInterval.index(of: theEntry) {
					theIndicies.add(theIndex);
				}
			}
			selectedIndicies = theIndicies as IndexSet;
		}
		get {
			var		theResult = [IntervalEntry]();
			for theIndex in selectedIndicies {
				theResult.append(everyInterval[theIndex]);
			}
			return theResult;
		}
	}
	var		selectedJustIntonationIntervals : [Interval] {
		return selectedIntervalEntry.map { return $0.interval; };
	}

	func calculateAllIntervals() {
		if let theIntervalData = intervalsData {
			let		theSelectedEntries = selectedIntervalEntry;
			let		theGenerator = theIntervalData.intervalsDataGenerator( );
			smallestErrorEntries = theGenerator.smallestError;
			biggestErrorEntries = theGenerator.biggestError;
			averageError = theGenerator.averageError;
			everyInterval = theGenerator.everyEntry;
			selectedIntervalEntry = theSelectedEntries;
		}
	}

	// MIDIReceiverObserver methods
	func midiReceiverNoteOff( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) {
		if let theEntry = midiToHarmonicRatio.popRatioFor(midiNote: aNote) {
			if let theIndex = indexFor(equalTemperamentEntry: theEntry) {
				unselect(index: theIndex);
			}
		}
	}
	func midiReceiverNoteOn( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) {
		let		theEntry = midiToHarmonicRatio.pushRatioFor(midiNote: aNote, everyInterval: everyInterval );
		if let theIndex = indexFor(equalTemperamentEntry: theEntry) {
			select(index: theIndex);
		}
	}
}
