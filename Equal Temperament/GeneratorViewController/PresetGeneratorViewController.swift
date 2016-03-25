//
//  PresetGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class PresetGeneratorViewController: GeneratorViewController {

	@IBOutlet weak var		presetMenu: NSMenu?
	override var nibName: String? { return "PresetGeneratorViewController"; }

	@IBAction func selectPresetAction(sender: NSPopUpButton) {
	}
}
