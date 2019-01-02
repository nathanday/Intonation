//
//  PresetGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class PresetGeneratorViewController: GeneratorViewController {
    static let       defaultIntervalString = "<Select a Present>";

	@IBOutlet var	choosePresetWindow : NSPanel!
	@IBOutlet var	chordOrScaleSelectorViewController : ChordOrScaleSelectorViewController!
    @IBOutlet var   intervalNameTextView : NSTextField?

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "PresetGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    override func awakeFromNib() {
        intervalNameTextView?.stringValue = PresetGeneratorViewController.defaultIntervalString;
    }

	@IBAction func showPresetsSheetAction( _ aSender: Any) {
		view.window?.beginSheet(choosePresetWindow, completionHandler: {
				(aResponse:NSApplication.ModalResponse) -> Void in
				switch aResponse {
				case NSApplication.ModalResponse.continue:
					if let theIntervalData = self.document?.intervalsData as? PresetIntervalsData {
						theIntervalData.intervals = self.chordOrScaleSelectorViewController.selectedIntervalSet;
						theIntervalData.presetName = self.chordOrScaleSelectorViewController.selectedIntervalSet?.name;
						self.document?.calculateAllIntervals();
						if let theName = theIntervalData.intervals?.name {
							self.intervalNameTextView?.stringValue = theName;
						} else {
							self.intervalNameTextView?.stringValue = PresetGeneratorViewController.defaultIntervalString;
						}
					}
					break;
				default:
					break;
				}
			}
		);
	}
}

extension PresetGeneratorViewController : NSWindowDelegate {
	@IBAction func selectPresetAction( _ aSender: Any) {
		choosePresetWindow.sheetParent?.endSheet( choosePresetWindow, returnCode: NSApplication.ModalResponse.continue );
	}
	@IBAction func cancelPresetSheetAction( _ aSender: Any) {
		choosePresetWindow.sheetParent?.endSheet( choosePresetWindow, returnCode: NSApplication.ModalResponse.abort );
	}
}

extension PresetIntervalsData {
	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return PresetGeneratorViewController(windowController:aWindowController);
	}
}
