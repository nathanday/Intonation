/*
    MainWindowController.swift
    Intonation

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Cocoa

func frequencyForMIDINote( _ aMIDINote : Int ) -> Double {
	let		theBase = 440.0/pow(2.0,(69.0/12.0));
	return pow(2.0,(Double(aMIDINote)/12.0))*theBase;
}

class MainWindowController : NSWindowController {

	static let		midiSelectBounds : CountableClosedRange<Int> = 12...108;

	deinit {
		NotificationCenter.default.removeObserver(self);
		document?.removeObserver(self, forKeyPath: "everyInterval");
		splitView!.delegate = nil;
	}

	@IBOutlet weak var	splitView : NSSplitView?;
	@IBOutlet weak var	tableParentContainerView : NSView?
	@IBOutlet weak var	plottingParentContainerView : NSView?
	@IBOutlet weak var	documentTypeViewControllerPlaceHolderView: ViewControllerPlaceHolderView?
	@IBOutlet weak var	tableParentContainerSplitView : NSSplitView?;

	@IBOutlet var	arrayController : NSArrayController?
	@IBOutlet var	scaleViewController : ScaleViewController?
	@IBOutlet var	harmonicViewController : HarmonicViewController?
	@IBOutlet var	waveViewController : WaveViewController?
	@IBOutlet var	spectrumViewController : SpectrumViewController?;

	@IBOutlet var	findIntervalsViewController : FindIntervalsViewController?

	@IBOutlet weak var	tableView : NSTableView?;
	@IBOutlet weak var	baseFrequencyTextField : NSTextField?;
	@IBOutlet weak var	harmonicTitleTextField : NSTextField?;
	@IBOutlet weak var	factorsSumTitleTextField : NSTextField?;
	@IBOutlet weak var	baseFrequencyDeltaSlider : NSSlider?;
	@IBOutlet weak var	playSegmentedControl : NSSegmentedControl?;

	@IBOutlet weak var  octavesCountPopUpButton : NSPopUpButton?

	var		documentTypeViewController : GeneratorViewController?

	override func awakeFromNib() {
		super.awakeFromNib();
		document?.addObserver(self, forKeyPath: "enableInterval", options: NSKeyValueObservingOptions.new, context: nil);
		document?.addObserver(self, forKeyPath: "everyInterval", options: NSKeyValueObservingOptions.new, context: nil);
		document?.addObserver(self, forKeyPath: "selectedIndicies", options: NSKeyValueObservingOptions.new, context: nil);
	}

	override func observeValue( forKeyPath aKeyPath: String?, of anObject: Any?, change aChange: [NSKeyValueChangeKey : Any]?, context aContext: UnsafeMutableRawPointer?) {
		if let theDocument = document as? Document {
			if anObject as? Document == theDocument {
				if aKeyPath == "everyInterval" {
					scaleViewController!.setIntervals(intervals: theDocument.everyInterval, degree: 12, enabled: true);
				} else if aKeyPath == "selectedIndicies" {
					let		theSelectedIntervals = theDocument.selectedJustIntonationIntervals;
					arrayController!.setSelectedObjects(theDocument.selectedIntervalEntry);
					updateChordRatioTitle();
					assert(scaleViewController != nil, "Failed to get ScaleViewController")
					scaleViewController!.setSelectionIntervals(theSelectedIntervals);
					assert(harmonicViewController != nil, "Failed to get HarmonicViewController")
					harmonicViewController!.setSelectionIntervals(theSelectedIntervals);
					assert(waveViewController != nil, "Failed to get WaveViewController")
					waveViewController!.setSelectionIntervals(theSelectedIntervals);
					assert(spectrumViewController != nil, "Failed to get SpectrumViewController")
					spectrumViewController!.setSelectionIntervals(theSelectedIntervals);
				}
			}
		}
	}

	var		selectedJustIntonationIntervals : [Interval] {
		return (document as! Document).selectedIntervalEntry.map { return $0.interval; };
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
	dynamic var		errorExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "errorExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "errorExpanded"); }
	}
	dynamic var		midiExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "midiExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "midiExpanded"); }
	}
	dynamic var		audioExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "audioExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "audioExpanded"); }
	}
	dynamic var		savedExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "savedExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "savedExpanded"); }
	}

	private func updateChordRatioTitle( ) {
		if let theHarmonicTitleTextField = harmonicTitleTextField,
			let theFactorsSumTitleTextField = factorsSumTitleTextField {
			if selectedJustIntonationIntervals.count > 1 {
				var		theRatiosString : String = "";
				var		theFactorsString : String = "";
				var		theFactorsSum = UInt(0);
				var		theCommonFactor = 1;
				for theValue in selectedJustIntonationIntervals {
					if let theRationalInterval = theValue as? RationalInterval {
						theCommonFactor *= theRationalInterval.ratio.denominator/Int(greatestCommonDivisor(UInt(theCommonFactor), UInt(theRationalInterval.ratio.denominator)));
					}
				}
				for theRatio in selectedJustIntonationIntervals {
					if let theRationalInterval = theRatio as? RationalInterval,
						let theValue = theRationalInterval.ratio.numeratorForDenominator(theCommonFactor) {
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

	func playBackMethodChanged(notification aNotification: Notification) {
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

	override func windowWillLoad() {
		super.windowWillLoad();
		if let theDocument = document{
			NotificationCenter.default.addObserver(self, selector: #selector(playBackMethodChanged(notification:)), name: NSNotification.Name(rawValue: PlayBackMethodChangedNotification), object: theDocument );
		}

		if let theBaseFrequencyDeltaSlider = baseFrequencyDeltaSlider {
			theBaseFrequencyDeltaSlider.isContinuous = true;
			previousBaseFrequencyDelta = theBaseFrequencyDeltaSlider.doubleValue;
		}
	}

	@IBAction func copy( _ aSender: Any ) {
		if let theEntries = arrayController!.selectedObjects as? [IntervalEntry] {
			NSPasteboard.general().clearContents();
			NSPasteboard.general().writeObjects( theEntries );
		}
	}

	@IBAction func copyCentsAction( _ aSender: Any ) {
		NSPasteboard.general().clearContents();
		NSPasteboard.general().writeObjects( (arrayController!.selectedObjects as! [IntervalEntry]).map { return "\($0.toCents)" as NSString; } );
	}

	@IBAction func baseFrequencyDeltaChanged( _ aSender: NSSlider ) {
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
	
	@IBAction func playLastMethod( _ aSender: Any? ) {
		if let theDocument = document as? Document {
			theDocument.playUsingMethod( theDocument.currentlySelectedMethod ?? 0 );
		}
	}

	@IBAction func playAction( _ aSender: NSSegmentedControl ) {
		if let theDocument = document as? Document {
			theDocument.playUsingMethod( aSender.selectedSegment );
		}
	}

	@IBAction func showFindClosestIntervlAction( _ aSender: Any? ) {
		findIntervalsViewController!.showView()
	}

	@IBAction func selectMIDINoteForBaseFrequencyAction( _ aSender : NSPopUpButton? ) {
		if let theDocument = document as? Document,
			let theSelectedIndex = aSender?.indexOfSelectedItem {
			theDocument.baseFrequency = frequencyForMIDINote(theSelectedIndex-1+MainWindowController.midiSelectBounds.lowerBound);
		}
	}

	@IBAction func paste( _ aSender: Any ) {
		if let theViewController = self.documentTypeViewController as? AdHokGeneratorViewController,
			let theEntries = NSPasteboard.general().readObjects(forClasses: [IntervalEntry.self], options: nil) as? [IntervalEntry] {
			theViewController.addIntervals( theEntries.map { return $0.interval; } );
		}
	}
	@IBAction func delete( _ aSender: Any) {
		if let theViewController = self.documentTypeViewController as? AdHokGeneratorViewController,
			let theSelectedObjects = arrayController?.selectedObjects as? [IntervalEntry] {
			theViewController.removeIntervals( theSelectedObjects.map { return $0.interval; } );
		}
	}
	@IBAction func exportAction( _ aSender: Any? ) {
		let		theExportWindowController = ExportWindowController(document:self.document as! Document);
		theExportWindowController.completionBlock = {
		}
		theExportWindowController.showAsSheet(parentWindow: self.window! );
	}

	override var windowNibName: String { return "MainWindowController"; }

	override func windowDidLoad() {
		super.windowDidLoad();
		if let theDocument = document as? Document {
			if let theWindow = self.window {
				if theDocument.intervalsData == nil {
					let		theWindowController = SelectDocumentType();
					theWindowController.completionBlock = { (aType) in
						if let theType = aType {
							let		theIntervalData = IntervalsData.from(documentType: theType );
							theDocument.intervalsData = theIntervalData;
							if let theViewController = theDocument.intervalsData?.viewController(windowController: self) {
								self.documentTypeViewController = theViewController;
								self.documentTypeViewControllerPlaceHolderView!.loadViewController(theViewController);
								theDocument.calculateAllIntervals();
								self.octavesCountPopUpButton?.selectItem(withTag: Int(theIntervalData.octavesCount));
							}
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

	func hideIntervalRelatedColumn( _ aHide : Bool ) {
		for theTableColumn in tableView!.tableColumns {
			if ["interval","percent","error"].contains(theTableColumn.identifier) {
				theTableColumn.isHidden = aHide;
			}
		}
		scaleViewController!.hideIntervalRelatedColumn(!aHide);
	}

	func windowDidBecomeMain( _ aNotification: Notification) {
		if let theDocument = document as? Document {
			theDocument.playbackPaused = false;
		}
	}

	func windowDidResignMain( _ aNotification: Notification) {
		if let theDocument = document as? Document {
			theDocument.playbackPaused = true;
		}
	}
}

extension MainWindowController : NSTableViewDelegate {

	func tableViewSelectionDidChange(_ notification: Notification) {
		if let theSelectedEntries = arrayController!.selectedObjects as? [IntervalEntry],
			let theDocument = document as? Document {
			theDocument.selectedIntervalEntry = theSelectedEntries
		}
	}

	func tableViewColumnDidResize(_ aNotification: Notification) {
		if let theTableColumn = (aNotification as NSNotification).userInfo?["NSTableColumn"] as? NSTableColumn {
			if theTableColumn.identifier == "description" {
				theTableColumn.isHidden = theTableColumn.width <= 20.0;
			}
		}
	}
}

extension MainWindowController : NSTableViewDataSource {
	func tableView(_ aTableView: NSTableView, pasteboardWriterForRow aRow: Int) -> NSPasteboardWriting? {
		return (arrayController!.arrangedObjects as! [IntervalEntry])[aRow];
	}
}

extension MainWindowController : NSSplitViewDelegate {
	func splitView(_ aSplitView: NSSplitView, canCollapseSubview aSubview: NSView) -> Bool {
		var		theResult = false;
		if aSplitView == splitView {
			theResult = aSubview == plottingParentContainerView;
		}
		return theResult;
	}

	func splitView( _ aSplitView: NSSplitView, additionalEffectiveRectOfDividerAt aDividerIndex: Int ) -> NSRect {
		var		theResult = NSZeroRect;
		if aSplitView == splitView {
			let		theRect = tableParentContainerView!.frame;
			theResult = NSRect(x: theRect.maxX-12.0, y: theRect.minY, width: 12.0, height: theRect.height);
		} else if aSplitView == tableParentContainerSplitView {
			if documentTypeViewController is StackedIntervalsGeneratorViewController {
				theResult = documentTypeViewControllerPlaceHolderView!.frame;
				theResult.origin.y = theResult.maxY - 10.0;
				theResult.size.height = 10.0;
			}
		}
		return theResult;
	}

	func splitView( _ aSplitView: NSSplitView, shouldHideDividerAt aDividerIndex: Int) -> Bool {
		var			theResult = false;
		if aSplitView == tableParentContainerSplitView {
			theResult = !(documentTypeViewController is StackedIntervalsGeneratorViewController);
		}
		return theResult;
	}
}
