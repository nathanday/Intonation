/*
    MainWindowController.swift
    Equal Temperament

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Cocoa

func frequencyForMIDINote( aMIDINote : Int ) -> Double {
	let		theBase = 440.0/pow(2.0,(69.0/12.0));
	return pow(2.0,(Double(aMIDINote)/12.0))*theBase;
}

class MainWindowController : NSWindowController {

	static let		midiSelectBounds : Range<Int> = 12...108;

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self);
		document?.removeObserver(self, forKeyPath: "everyInterval");
		splitView?.delegate = nil;
	}

	@IBOutlet var	splitView : NSSplitView?;
	@IBOutlet var	tableParentContainerView : NSView?
	@IBOutlet var	plottingParentContainerView : NSView?

	@IBOutlet var	arrayController : NSArrayController?
	@IBOutlet var	scaleViewController : ScaleViewController?
	@IBOutlet var	harmonicViewController : HarmonicViewController?
	@IBOutlet var	waveViewController : WaveViewController?
	@IBOutlet var	spectrumViewController : SpectrumViewController?;

	@IBOutlet var	findIntervalsViewController : FindIntervalsViewController?

	@IBOutlet var	tableView : NSTableView?;
	@IBOutlet var	baseFrequencyTextField : NSTextField?;
	@IBOutlet var	documentWindow : NSWindow?;
	@IBOutlet var	harmonicTitleTextField : NSTextField?;
	@IBOutlet var	factorsSumTitleTextField : NSTextField?;
	@IBOutlet var	baseFrequencyDeltaSlider : NSSlider?;
	@IBOutlet var	playSegmentedControl : NSSegmentedControl?;

	override func awakeFromNib() {
		super.awakeFromNib();
		document?.addObserver(self, forKeyPath: "enableInterval", options: NSKeyValueObservingOptions.New, context: nil);
		document?.addObserver(self, forKeyPath: "everyInterval", options: NSKeyValueObservingOptions.New, context: nil);
		document?.addObserver(self, forKeyPath: "selectedIndicies", options: NSKeyValueObservingOptions.New, context: nil);
	}

	override func observeValueForKeyPath( aKeyPath: String?, ofObject anObject: AnyObject?, change aChange: [String : AnyObject]?, context aContext: UnsafeMutablePointer<Void>) {
		if let theDocument = document as? Document {
			if anObject as? Document == theDocument {
				if aKeyPath == "enableInterval" {
					hideIntervalRelatedColumn(theDocument.intervalsData.enableInterval);
				} else if aKeyPath == "everyInterval" {
					scaleViewController?.setIntervals(intervals: theDocument.everyInterval, intervalCount: theDocument.intervalsData.intervalCount, enabled: theDocument.intervalsData.enableInterval);
				} else if aKeyPath == "selectedIndicies" {
					let		theSelectedIntervals = theDocument.selectedJustIntonationIntervals;
					arrayController?.setSelectionIndexes(theDocument.selectedIndicies);
					updateChordRatioTitle();
					assert(scaleViewController != nil, "Failed to get ScaleViewController")
					scaleViewController?.setSelectionIntervals(theSelectedIntervals);
					assert(harmonicViewController != nil, "Failed to get HarmonicViewController")
					harmonicViewController?.setSelectionIntervals(theSelectedIntervals);
					assert(waveViewController != nil, "Failed to get WaveViewController")
					waveViewController?.setSelectionIntervals(theSelectedIntervals);
					assert(spectrumViewController != nil, "Failed to get SpectrumViewController")
					spectrumViewController?.setSelectionIntervals(theSelectedIntervals);
				}
			}
		}
	}

	var		selectedJustIntonationIntervals : [Interval] {
		return (document as! Document).selectedEqualTemperamentEntry.map { return $0.interval!; };
	}
	dynamic var		midiNoteNotes : [String] = {
		let		theNoteNames = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"];
		var		theResult = ["Select Note"];
		for theNoteNumber in MainWindowController.midiSelectBounds {
			let		theOctave = theNoteNumber/theNoteNames.count;
			var		theNoteName = "\(theNoteNames[theNoteNumber%theNoteNames.count])\(theOctave)";
			if theNoteNumber == 60 {
				theNoteName = "\(theNoteName) middle";
			} else if theNoteNumber == 69 {
				theNoteName = "\(theNoteName) 440Hz";
			}
			theResult.append(theNoteName);
		}
		return theResult;
	}();

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

	private func updateChordRatioTitle( ) {
		if let theHarmonicTitleTextField = harmonicTitleTextField,
			theFactorsSumTitleTextField = factorsSumTitleTextField {
			if selectedJustIntonationIntervals.count > 1 {
				var		theRatiosString : String = "";
				var		theFactorsString : String = "";
				var		theFactorsSum = UInt(0);
				var		theCommonFactor = 1;
				for theValue in selectedJustIntonationIntervals {
					if let theRationalInterval = theValue as? RationalInterval {
						theCommonFactor *= theRationalInterval.ratio.denominator/greatestCommonDivisor(theCommonFactor, theRationalInterval.ratio.denominator);
					}
				}
				for theRatio in selectedJustIntonationIntervals {
					if let theRationalInterval = theRatio as? RationalInterval {
						if let theValue = theRationalInterval.ratio.numeratorForDenominator(theCommonFactor) {
							let		theFactors = UInt(theValue).factorsString;
							if theRatiosString.startIndex == theRatiosString.endIndex {
								theRatiosString = "\(theValue)"
								theFactorsString = "\(theFactors)"
							}
							else {
								theRatiosString.write( "∶\(theValue)" );
								theFactorsString.write( " + \(theFactors)" );
							}
							theFactorsSum += UInt(theValue);
						}
					}
				}
				theHarmonicTitleTextField.stringValue = theRatiosString;
				theFactorsSumTitleTextField.stringValue = "\(theFactorsString) = \(theFactorsSum)";
				
			}
			else if let theSingle = selectedJustIntonationIntervals.first as? RationalInterval {
				theHarmonicTitleTextField.stringValue = theSingle.ratio.ratioString;
				theFactorsSumTitleTextField.stringValue = "\(UInt(theSingle.ratio.numerator).factorsString) + \(UInt(theSingle.ratio.denominator).factorsString) = \(theSingle.ratio.numerator+theSingle.ratio.denominator)";
			}
			else {
				theHarmonicTitleTextField.stringValue = "";
				theFactorsSumTitleTextField.stringValue = "";
			}
		}
	}

	func playBackMethodChanged(notification aNotification: NSNotification) {
		if let theDocument = document as? Document {
			if let thePlaySegmentedControl = playSegmentedControl {
				if let theSelectedMethod = theDocument.currentlySelectedMethod {
					thePlaySegmentedControl.setSelected( true, forSegment: theSelectedMethod);
				} else {
					thePlaySegmentedControl.setSelected( false, forSegment: thePlaySegmentedControl.selectedSegment);
				}
			}
		}
	}

	var		previousBaseFrequencyDelta : Double = 0.0;

	dynamic var		documentTypeString : String? {
		get { return (document as? Document)?.intervalsData.documentType?.toString(); }
		set { (document as? Document)?.intervalsData.documentType = DocumentType.fromString(newValue); }
	}

	override func windowWillLoad() {
		super.windowWillLoad();
		if let theDocument = document{
			NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playBackMethodChanged(notification:)), name: PlayBackMethodChangedNotification, object: theDocument );
		}

		if let theBaseFrequencyDeltaSlider = baseFrequencyDeltaSlider {
			theBaseFrequencyDeltaSlider.continuous = true;
			previousBaseFrequencyDelta = theBaseFrequencyDeltaSlider.doubleValue;
		}
	}

	@IBAction func enableIntervalChanged( aSender: NSButton? ) {
		if let theButton = aSender, theIntervalData = (document as? Document)?.intervalsData {
			theIntervalData.enableInterval = theButton.state == NSOnState;
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

		if let theDocument = document as? Document {
			if theNegativeDelta < thePositiveDelta {
				theDocument.baseFrequency /= theNegativeDelta+1.0;
			} else if theNegativeDelta > thePositiveDelta {
				theDocument.baseFrequency *= thePositiveDelta+1.0;
			}
		}

		previousBaseFrequencyDelta = theBaseFrequencyDelta;
	}
	
	@IBAction func selectPresetInterval( aSender: NSMenuItem ) {
		if let theIntervalData = (document as? Document)?.intervalsData {
			theIntervalData.intervalCount = UInt(aSender.tag);
		}
	}

	@IBAction func playLastMethod( aSender: AnyObject? ) {
		if let theDocument = document as? Document {
			theDocument.playUsingMethod( theDocument.currentlySelectedMethod ?? 0 );
		}
	}

	@IBAction func playAction( aSender: NSSegmentedControl ) {
		if let theDocument = document as? Document {
			theDocument.playUsingMethod( aSender.selectedSegment );
		}
	}

	@IBAction func showFindClosestIntervlAction( aSender: AnyObject? ) {
		findIntervalsViewController?.showView()
	}

	@IBAction func selectMIDINoteForBaseFrequencyAction( aSender : NSPopUpButton? ) {
		if let theDocument = document as? Document,
			theSelectedIndex = aSender?.indexOfSelectedItem {
			theDocument.baseFrequency = frequencyForMIDINote(theSelectedIndex-1+MainWindowController.midiSelectBounds.startIndex);
		}
	}

	override var windowNibName: String! { return "MainWindowController"; }

	override func windowDidLoad() {
		super.windowDidLoad();
		if let theDocument = document as? Document {
			if let theWindow = self.window {
				if theDocument.intervalsData.documentType == nil {
					let		theWindowController = SelectDocumentType();
					theWindowController.completionBlock = { (aType) in
						if aType != nil {
							self.willChangeValueForKey("documentTypeString");
							theDocument.intervalsData.documentType = aType;
							self.didChangeValueForKey("documentTypeString");
							theDocument.calculateAllIntervals();
						}
						else {
							self.close();
						}
					};
					theWindowController.showAsSheet(parentWindow: theWindow );
				}
			}
			else {
				theDocument.calculateAllIntervals();
			}
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
		scaleViewController?.hideIntervalRelatedColumn(!aHide);
	}
}

extension MainWindowController : NSTableViewDelegate {
	static let		cellColors = ( backgroundAlpha:CGFloat(0.1), maxErrorTextAlpha:CGFloat(0.25) );
	func tableView( aTableView: NSTableView, willDisplayCell aCell: AnyObject, forTableColumn aTableColumn: NSTableColumn?, row aRowIndex: Int) {
		if let	theEntry = arrayController!.arrangedObjects[UInt(aRowIndex)] as? EqualTemperamentEntry, theCell = aCell as? NSTextFieldCell {
			if let theDocument = document as? Document {
				let		theExceedsError = theDocument.intervalsData.enableInterval && abs(theEntry.error12ETCent) > 100.0*theDocument.intervalsData.maximumError;
				if theDocument.smallestErrorEntries.contains(theEntry) {
					theCell.backgroundColor = NSColor(calibratedRed:0.0, green:0.0, blue:1.0, alpha:MainWindowController.cellColors.backgroundAlpha);
					theCell.textColor = NSColor(calibratedRed:0.0, green:0.0, blue:0.6, alpha:theExceedsError ? MainWindowController.cellColors.maxErrorTextAlpha : 1.0);
				}
				else if theDocument.biggestErrorEntries.contains(theEntry) {
					theCell.backgroundColor = NSColor(calibratedRed:0.8, green:0.0, blue:0.0, alpha:MainWindowController.cellColors.backgroundAlpha);
					theCell.textColor = NSColor(calibratedRed:0.52, green:0.0, blue:0.0, alpha:theExceedsError ? MainWindowController.cellColors.maxErrorTextAlpha : 1.0);
				}
				else {
					theCell.backgroundColor = NSColor.clearColor();
					theCell.textColor = NSColor(calibratedWhite: 0.0, alpha: theExceedsError ? MainWindowController.cellColors.maxErrorTextAlpha : 1.0);
				}
			}
		}
	}

	func tableViewSelectionDidChange(notification: NSNotification) {
		if let theSelectedIntervals = arrayController?.selectionIndexes,
			theDocument = document as? Document {
			theDocument.selectedIndicies = theSelectedIntervals;
		}
	}

	func tableViewColumnDidResize(aNotification: NSNotification) {
		if let theTableColumn = aNotification.userInfo!["NSTableColumn"] as? NSTableColumn {
			if theTableColumn.identifier == "description" {
				theTableColumn.hidden = theTableColumn.width <= 20.0;
			}
		}
	}
}

extension MainWindowController : NSSplitViewDelegate {
	func splitView(aSplitView: NSSplitView, canCollapseSubview aSubview: NSView) -> Bool {
		return aSubview == plottingParentContainerView;
	}

	func splitView( aSplitView: NSSplitView, additionalEffectiveRectOfDividerAtIndex aDividerIndex: Int ) -> NSRect {
		let		theRect = tableParentContainerView!.frame;
		return NSRect(x: theRect.maxX-12.0, y: theRect.minY, width: 12.0, height: theRect.height);
	}
}
