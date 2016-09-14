//
//  PresetGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class PresetGeneratorViewController: GeneratorViewController {

	@IBOutlet var	choosePresetWindow : NSPanel?
	@IBOutlet var	browser : NSBrowser?;
	@IBOutlet var	chordOrScaleSelectorViewController : ChordOrScaleSelectorViewController?

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "PresetGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@IBAction func showPresetsSheetAction( _ aSender: Any) {
		if let theSheet = choosePresetWindow {
			view.window?.beginSheet(theSheet, completionHandler: {
					(aResponse:NSModalResponse) -> Void in
					switch aResponse {
					case NSModalResponseContinue:
						if let theIntervalData = self.document?.intervalsData as? PresetIntervalsData {
							theIntervalData.intervals = self.chordOrScaleSelectorViewController!.selectedIntervalSet;
							self.document?.calculateAllIntervals();
						}
						break;
					default:
						break;
					}
				}
			);
		}
	}
}

extension PresetGeneratorViewController : NSWindowDelegate {
	@IBAction func selectPresetAction( _ aSender: Any) {
		view.window?.endSheet( choosePresetWindow!, returnCode: NSModalResponseContinue );
	}
	@IBAction func cancelPresetSheetAction( _ aSender: Any) {
		view.window?.endSheet( choosePresetWindow!, returnCode: NSModalResponseAbort );
	}
}
