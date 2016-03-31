//
//  PresetGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class PresetGeneratorViewController: GeneratorViewController {

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "PresetGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@IBOutlet weak var		presetMenu: NSMenu?

	@IBAction func selectPresetAction(sender: NSPopUpButton) {
	}
}
