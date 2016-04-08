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
	@IBOutlet var	chordSelectorWindowController : ChordSelectorWindowController?

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "PresetGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@IBAction func showPresetsSheetAction(aSender: AnyObject) {
		if let theSheet = choosePresetWindow {
			view.window?.beginSheet(theSheet, completionHandler: {
					(aResponse:NSModalResponse) -> Void in
					switch aResponse {
					case NSModalResponseContinue:
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
	@IBAction func selectPresetAction(aSender: AnyObject) {
		view.window?.endSheet( choosePresetWindow!, returnCode: NSModalResponseContinue );
	}
	@IBAction func cancelPresetSheetAction(aSender: AnyObject) {
		view.window?.endSheet( choosePresetWindow!, returnCode: NSModalResponseAbort );
	}
}
