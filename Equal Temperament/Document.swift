/*
    Document.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Cocoa

public let PlayBackMethodChangedNotification = "PlayBackMethodChanged";
public let PlayBackMethodUserInfoKey = "PlayBackMethod";

class Document : NSDocument, MIDIReceiverObserver {
	var		tonePlayer = TonePlayer();
	var		midiReceiver = MIDIReceiver(clientName:"Equal Temperament");
	var		playingRatioForNote : [UInt:EqualTemperamentEntry] = [UInt:EqualTemperamentEntry]();

	var		intervalsData : IntervalsData = IntervalsData() {
		willSet {
			removeIntervalsDataObservers();
		}
		didSet {
			tonePlayer.harmonics = intervalsData.overtones;
			tonePlayer.baseFrequency = intervalsData.baseFrequency;
			tonePlayer.equalTempIntervalCount = intervalsData.intervalCount;
			setUpIntervalsDataObservers();
		}
	}

	override func observeValueForKeyPath( aKeyPath: String?, ofObject anObject: AnyObject?, change aChange: [String : AnyObject]?, context aContext: UnsafeMutablePointer<Void>) {
		if anObject as? IntervalsData == intervalsData {
			let theMatchingKeys : Set = ["selectedMethod", "intervalCount", "octavesCount", "numeratorPrimeLimitIndex", "denominatorPrimeLimitIndex", "separatePrimeLimit", "oddLimit", "additiveDissonance", "maximumError", "filtered"];
			if let theKey = aKeyPath {
				if theMatchingKeys.contains(theKey) {
					if aChange?[NSKeyValueChangeNotificationIsPriorKey] != nil {
						willChangeValueForKey("intervalsData");

					} else {
						calculateAllIntervals();
						didChangeValueForKey("intervalsData");
					}
				}
			}

		}
	}

	func setUpIntervalsDataObservers() {
		intervalsData.addObserver(self, forKeyPath:"selectedMethod", options: NSKeyValueObservingOptions.Prior, context:nil)
		intervalsData.addObserver(self, forKeyPath:"intervalCount", options: NSKeyValueObservingOptions.Prior, context:nil)
		intervalsData.addObserver(self, forKeyPath:"octavesCount", options: NSKeyValueObservingOptions.Prior, context:nil)
		intervalsData.addObserver(self, forKeyPath:"numeratorPrimeLimitIndex", options: NSKeyValueObservingOptions.Prior, context:nil)
		intervalsData.addObserver(self, forKeyPath:"denominatorPrimeLimitIndex", options: NSKeyValueObservingOptions.Prior, context:nil)
		intervalsData.addObserver(self, forKeyPath:"separatePrimeLimit", options: NSKeyValueObservingOptions.Prior, context:nil)
		intervalsData.addObserver(self, forKeyPath:"oddLimit", options: NSKeyValueObservingOptions.Prior, context:nil)
		intervalsData.addObserver(self, forKeyPath:"additiveDissonance", options: NSKeyValueObservingOptions.Prior, context: nil);
		intervalsData.addObserver(self, forKeyPath:"maximumError", options: NSKeyValueObservingOptions.Prior, context:nil)
		intervalsData.addObserver(self, forKeyPath:"filtered", options: NSKeyValueObservingOptions.Prior, context:nil)
	}

	func removeIntervalsDataObservers() {
		intervalsData.removeObserver(self, forKeyPath:"selectedMethod");
		intervalsData.removeObserver(self, forKeyPath:"intervalCount");
		intervalsData.removeObserver(self, forKeyPath:"octavesCount");
		intervalsData.removeObserver(self, forKeyPath:"numeratorPrimeLimitIndex");
		intervalsData.removeObserver(self, forKeyPath:"denominatorPrimeLimitIndex");
		intervalsData.removeObserver(self, forKeyPath:"separatePrimeLimit");
		intervalsData.removeObserver(self, forKeyPath:"oddLimit");
		intervalsData.removeObserver(self, forKeyPath:"additiveDissonance");
		intervalsData.removeObserver(self, forKeyPath:"maximumError");
		intervalsData.removeObserver(self, forKeyPath:"filtered");
	}

	deinit {
		removeIntervalsDataObservers();
	}

	var		baseFrequency : Double {
		get { return intervalsData.baseFrequency; }
		set( aValue ) {
			let		theValue = max(min(aValue,IntervalsData.maximumBaseFrequency), IntervalsData.minimumBaseFrequency);
			self.willChangeValueForKey("baseFrequency");
			intervalsData.baseFrequency = theValue;
			tonePlayer.baseFrequency = intervalsData.baseFrequency;
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
		set( aValue ) {
			intervalsData.overtones = aValue;
			tonePlayer.harmonics = intervalsData.overtones;
		}
		get { return intervalsData.overtones; }
	}
	var		arpeggioBeatPerMinute : Double {
		set( aValue ) {
			intervalsData.arpeggioInterval = 60.0/aValue
			tonePlayer.arpeggioInterval = intervalsData.arpeggioInterval;
		}
		get { return 60.0/intervalsData.arpeggioInterval; }
	}

	var		currentlySelectedMethod : Int? = nil;

	@IBAction func baseFrequencyChangedAction( aSender: NSTextField? ) {
		if let theTextField = aSender {
			intervalsData.baseFrequency = theTextField.doubleValue;
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
			NSNotificationCenter.defaultCenter().postNotificationName(PlayBackMethodChangedNotification, object: self, userInfo: [PlayBackMethodUserInfoKey: currentlySelectedMethod!]);
		}
	}

	override class func autosavesInPlace() -> Bool { return true; }
	override func dataOfType( typeName: String) throws -> NSData {
		var anError: NSError = NSError(domain: "Migrator", code: 0, userInfo: nil)
		let		theResult: NSData?
		do {
			theResult = try NSPropertyListSerialization.dataWithPropertyList(intervalsData.propertyListValue, format:.XMLFormat_v1_0, options:0)
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
				intervalsData = IntervalsData(withPropertyList:thePropertyList);
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

	var		selectedIndicies = NSIndexSet();
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
		let		theSelectedEntries = selectedEqualTemperamentEntry;
		let		theDenominatorPrimeLimit = intervalsData.separatePrimeLimit ? intervalsData.denominatorPrimeLimit : intervalsData.numeratorPrimeLimit;
		let		theEntries = EqualTemperamentCollection(limits: (numeratorPrime:intervalsData.numeratorPrimeLimit, denominatorPrime:theDenominatorPrimeLimit, odd:intervalsData.oddLimit, additiveDissonance:intervalsData.additiveDissonance), intervalCount: intervalsData.enableInterval ? intervalsData.intervalCount : 0, octaves: intervalsData.octavesCount, maximumError: intervalsData.maximumError, filtered: intervalsData.filtered );
		smallestErrorEntries = theEntries.smallestError;
		biggestErrorEntries = theEntries.biggestError;
		averageError = theEntries.averageError;
		everyInterval = theEntries.everyEntry;
		selectedEqualTemperamentEntry = theSelectedEntries;
	}

	// MIDIReceiverObserver methods
	func midiReceiverNoteOff( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) {
		print( "note off, channel=\(aChannel), note=\(aNote), velocity=\(aVelocity)");
	}
	func midiReceiverNoteOn( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) {
		print( "note on, channel=\(aChannel), note=\(aNote), velocity=\(aVelocity)");
	}
	func midiReceiverPolyphonicKeyPressure( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverControlChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverProgramChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverChannelPressure( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverPitchBendChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
}
