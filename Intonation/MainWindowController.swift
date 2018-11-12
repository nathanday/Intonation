/*
    MainWindowController.swift
    Intonation

    Created by Nathan Day on 8/06/14.
    Copyright © 2014 Nathan Day. All rights reserved.
 */

import Cocoa
import os

func frequencyForMIDINote( _ aMIDINote : Int ) -> Double {
	let		theBase = 440.0/pow(2.0,(69.0/12.0));
	return pow(2.0,(Double(aMIDINote)/12.0))*theBase;
}

class MainWindowController : NSWindowController, NSMenuItemValidation {

	static let		midiSelectBounds : CountableClosedRange<Int> = 12...108;

	convenience init() {
		self.init(windowNibName:NSNib.Name("MainWindowController"));
	}

	deinit {
		NotificationCenter.default.removeObserver(self);
		document?.removeObserver(self, forKeyPath: "everyInterval");
		splitView?.delegate = nil;
	}

	@IBOutlet var	splitView : NSSplitView?;
	@IBOutlet var	tableParentContainerView : NSView!
	@IBOutlet var	plottingParentContainerView : NSView?
	@IBOutlet var	documentTypeViewControllerPlaceHolderView: ViewControllerPlaceHolderView!
	@IBOutlet var	tableParentContainerSplitView : NSSplitView?;
	@IBOutlet var	viewsTabView : NSTabView?;

	@IBOutlet var	arrayController : NSArrayController!
	@IBOutlet var	scaleViewController : ScaleViewController?
	@IBOutlet var	harmonicViewController : HarmonicViewController?
	@IBOutlet var	waveViewController : WaveViewController?
	@IBOutlet var	spectrumViewController : SpectrumViewController?;

	@IBOutlet var	findIntervalsViewController : FindIntervalsViewController?

	@IBOutlet var	tableView : NSTableView?;
	@IBOutlet var	baseFrequencyTextField : NSTextField?;
	@IBOutlet var	harmonicTitleTextField : NSTextField?;
	@IBOutlet var	factorsSumTitleTextField : NSTextField?;
	@IBOutlet var	baseFrequencyDeltaSlider : NSSlider?;
	@IBOutlet var	playSegmentedControl : NSSegmentedControl?;

	@IBOutlet var	searchField : NSTextField?;

	@IBOutlet var  octavesCountPopUpButton : NSPopUpButton?
	@IBOutlet var  selectionBaseNoteButton : NSButton?

	var		documentTypeViewController : GeneratorViewController?

//	lazy var	intervalTextView = IntervalTextView();

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
					scaleViewController?.setIntervals(intervals: theDocument.everyInterval, degree: 12, enabled: true);
				} else if aKeyPath == "selectedIndicies" {
					arrayController.setSelectedObjects(theDocument.selectedIntervalEntry);
					updateChordRatioTitle();
				}
			}
		}
	}

	var		selectedJustIntonationIntervals : [Interval] {
		return (document as! Document).selectedIntervalEntry.map { return $0.interval; };
	}
	@objc dynamic var		midiNoteNotes : [String] = {
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
	@objc dynamic var		errorExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "errorExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "errorExpanded"); }
	}
	@objc dynamic var		midiExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "midiExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "midiExpanded"); }
	}
	@objc dynamic var		audioExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "audioExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "audioExpanded"); }
	}
	@objc dynamic var		savedExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "savedExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "savedExpanded"); }
	}

	private func updateChordRatioTitle( ) {
		if let theHarmonicTitleTextField = harmonicTitleTextField,
			let theFactorsSumTitleTextField = factorsSumTitleTextField {
			if selectedJustIntonationIntervals.count > 1 {
				var		theRatiosString : String = "";
				var		theFactorsString : String = "";
				var		theFactorsSum = 0;
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
							theFactorsSum += theValue;
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

	@objc func playBackMethodChanged(notification aNotification: Notification) {
		guard let theDocument = document as? Document else {
			assertionFailure("No document");
			return;
		}

		if let thePlaySegmentedControl = playSegmentedControl {
			if let theSelectedMethod = theDocument.currentlySelectedMethod {
				thePlaySegmentedControl.setSelected( true, forSegment: theSelectedMethod);
			} else {
				thePlaySegmentedControl.setSelected( false, forSegment: thePlaySegmentedControl.selectedSegment);
			}
		}
	}

	var		previousBaseFrequencyDelta : Double = 0.0;

	override func windowWillLoad() {
		super.windowWillLoad();
		if let theDocument = document{
			NotificationCenter.default.addObserver(self, selector: #selector(playBackMethodChanged(notification:)), name: Document.playBackMethodChangedNotification, object: theDocument );
		}

		if let theBaseFrequencyDeltaSlider = baseFrequencyDeltaSlider {
			theBaseFrequencyDeltaSlider.isContinuous = true;
			previousBaseFrequencyDelta = theBaseFrequencyDeltaSlider.doubleValue;
		}
	}

	@IBAction func copy( _ aSender: Any ) {
		if let theEntries = arrayController.selectedObjects as? [IntervalEntry] {
			NSPasteboard.general.clearContents();
			NSPasteboard.general.writeObjects( theEntries );
		}
	}

	@IBAction func copyCentsAction( _ aSender: Any ) {
		if let theIntervals = arrayController.selectedObjects as? [IntervalEntry] {
			NSPasteboard.general.clearContents();
			NSPasteboard.general.writeObjects( theIntervals.map { return "\($0.toCents)" as NSString; } );
		}
	}

	@IBAction func selectTabAction( _ aSender: NSMenuItem ) {
		viewsTabView?.selectTabViewItem(at: aSender.tag&0xF);
	}

	@IBAction func selectNumberOfListedOctaves( _ aSender: NSMenuItem ) {
		if let theDocument = document as? Document,
			let theIntervalsData = theDocument.intervalsData {
			theIntervalsData.octavesCount = aSender.tag&0xF;
		}
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
		findIntervalsViewController?.showView()
	}

	@IBAction func showSelectMIDINoteForBaseFrequencyAction( _ aSender : Any? ) {
		if let theDocument = document as? Document,
			let theSelectionBaseNoteButton = selectionBaseNoteButton {
			let		thePianoKeyboardPopoverViewController = PianoKeyboardPopoverViewController();
			thePianoKeyboardPopoverViewController.show(withFrequency: theDocument.baseFrequency, relativeTo: theSelectionBaseNoteButton) {
				(aFrequency:Double?) in
				if let theFrequency = aFrequency {
					theDocument.baseFrequency = theFrequency;
				}
			}
		}
	}

	@IBAction func selectMultiplyBaseFrequencyAction( _ aSender : NSPopUpButton? ) {
		if let theDocument = document as? Document,
			let theSelectedTag = aSender?.selectedItem?.tag {
			let	theMultipliers = [ 1.0/2.0, 2.0,
									  3.0/4.0, 4.0/3.0,
									  2.0/3.0, 3.0/2.0];
			theDocument.baseFrequency *= theMultipliers[theSelectedTag%theMultipliers.count];
		}
	}

	@IBAction func paste( _ aSender: Any ) {
		if let theViewController = documentTypeViewController as? AdHokGeneratorViewController,
			let theEntries = NSPasteboard.general.readObjects(forClasses: [IntervalEntry.self], options: nil) as? [IntervalEntry] {
			theViewController.addIntervals( theEntries.map { return $0.interval; } );
		}
	}
	@IBAction func delete( _ aSender: Any) {
		if let theViewController = documentTypeViewController as? AdHokGeneratorViewController,
			let theSelectedObjects = arrayController.selectedObjects as? [IntervalEntry] {
			theViewController.removeIntervals( theSelectedObjects.map { return $0.interval; } );
		}
	}
	@IBAction func exportAction( _ aSender: Any? ) {
		guard let theDocument = document as? Document else {
			assertionFailure("No document");
			return;
		}
		guard let theParentWindow = window else {
			assertionFailure("No window");
			return;
		}
		let		theExportWindowController = ExportWindowController { ( aSucces: Bool, anExportMethod : ExportMethod, aSelectedIntervals : Bool) in
			if aSucces {
				let		theSavePanel = NSSavePanel();
				theSavePanel.title = "Export as \(anExportMethod.title) to…";
				theSavePanel.prompt = "Export";
				if let theFileType = anExportMethod.fileType {
					theSavePanel.allowedFileTypes = [theFileType];
				}
				theSavePanel.beginSheetModal(for: theParentWindow, completionHandler: { (aResponse: NSApplication.ModalResponse) in
					if aResponse == .OK {
						var theIntervalEntries : [IntervalEntry]?
						if aSelectedIntervals {
							theIntervalEntries = self.arrayController.selectedObjects as? [IntervalEntry];
						} else {
							theIntervalEntries = theDocument.intervalsData?.intervalsDataGenerator().everyEntry;
						}
						if let theIntervals = theIntervalEntries?.map( { $0.interval; } ) {
							if let theURL = theSavePanel.url {
								try? anExportMethod.exportGenerator(everyInterval: theIntervals ).saveTo(url: theURL);
							}
						}
					}
				});
			}
		};
		theExportWindowController.showAsSheet(parentWindow: theParentWindow );
	}

	dynamic func validateMenuItem(_ aMenuItem: NSMenuItem) -> Bool {
		if aMenuItem.action == #selector(selectTabAction(_:)) {
			if let theTabView = viewsTabView,
				let theSelectedTabItem = theTabView.selectedTabViewItem{
				aMenuItem.state = (aMenuItem.tag&0xF) == theTabView.indexOfTabViewItem(theSelectedTabItem) ? .on : .off;
			}
		} else if aMenuItem.action == #selector(selectNumberOfListedOctaves(_:)) {
			if let theDocument = document as? Document,
				let theIntervalsData = theDocument.intervalsData {
				aMenuItem.state = (aMenuItem.tag&0xF) == theIntervalsData.octavesCount ? .on : .off;
			}
		}
		return true;
	}
	override func windowDidLoad() {
		super.windowDidLoad();
		self.window?.acceptsMouseMovedEvents = true;

		guard let theDocument = document as? Document else {
			assertionFailure("No document");
			return;
		}
		guard let theWindow = window else {
			theDocument.calculateAllIntervals();
			return;
		}

		if theDocument.intervalsData == nil {
			let		theWindowController = SelectDocumentType();
			theWindowController.completionBlock = { (aType) in
				if let theType = aType {
					let		theIntervalData = theType.instance();
					theDocument.intervalsData = theIntervalData;
					if let theViewController = theDocument.intervalsData?.viewController(windowController: self) {
						self.documentTypeViewController = theViewController;
						self.documentTypeViewControllerPlaceHolderView.loadViewController(theViewController);
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

	@objc func hideIntervalRelatedColumn( _ aHide : Bool ) {
		tableView?.tableColumns.forEach { theTableColumn -> Void in
			if ["interval-number","percent","error"].contains(theTableColumn.identifier.rawValue) {
				theTableColumn.isHidden = aHide;
			}
		}
		scaleViewController?.hideIntervalRelatedColumn(!aHide);
	}

	@objc func windowDidBecomeMain( _ aNotification: Notification) {
		if let theDocument = document as? Document {
			theDocument.playbackPaused = false;
		}
	}

	@objc func windowDidResignMain( _ aNotification: Notification) {
		if let theDocument = document as? Document {
			theDocument.playbackPaused = true;
		}
	}
}

extension MainWindowController : NSWindowDelegate {
//	func windowWillReturnFieldEditor(_ aSender: NSWindow, to aController: Any?) -> Any? {
//		guard let theSearchField = aController as? NSSearchField else {
//			return nil;
//		}
//
//		if theSearchField == searchField {
//			intervalTextView.isFieldEditor = true;
//			return intervalTextView;
//		}
//		return nil;
//	}
}

extension MainWindowController : NSTableViewDelegate {

	@objc func tableView(_ aTableView: NSTableView, toolTipFor aCell: NSCell, rect aRect: NSRectPointer, tableColumn: NSTableColumn?, row aRow: Int, mouseLocation aMousePoint: NSPoint) -> String {
		return (arrayController.arrangedObjects as? [IntervalEntry])?[aRow].everyIntervalName.joined(separator: ",\n") ?? "";
	}

	@objc func tableViewSelectionDidChange(_ notification: Notification) {
		if let theSelectedEntries = arrayController.selectedObjects as? [IntervalEntry],
			let theDocument = document as? Document {
			theDocument.selectedIntervalEntry = theSelectedEntries
		}
	}

	@objc func tableViewColumnDidResize(_ aNotification: Notification) {
		if let theTableColumn = (aNotification as NSNotification).userInfo?["NSTableColumn"] as? NSTableColumn {
			if theTableColumn.identifier == NSUserInterfaceItemIdentifier("description") {
				theTableColumn.isHidden = theTableColumn.width <= 20.0;
			}
		}
	}
}

extension MainWindowController : NSTableViewDataSource {
	func tableView(_ aTableView: NSTableView, pasteboardWriterForRow aRow: Int) -> NSPasteboardWriting? {
		guard let theArrangedObjects = arrayController.arrangedObjects as? [IntervalEntry] else {
			return nil;
		}
		return theArrangedObjects[aRow];
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
			let		theRect = tableParentContainerView.frame;
			theResult = NSRect(x: theRect.maxX-12.0, y: theRect.minY, width: 12.0, height: theRect.height);
		} else if aSplitView == tableParentContainerSplitView {
			if documentTypeViewController is StackedIntervalsGeneratorViewController {
				theResult = documentTypeViewControllerPlaceHolderView.frame;
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
