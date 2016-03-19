/*
	PreferencesWindowController.swift
	Intonation

	Created by Nathan Day on 8/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

class PreferencesWindowController: NSWindowController {

	override var windowNibName : String { get { return "PreferencesWindowController"; } }
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

	var		minmumFrequency : Float32 = 20.0;
	var		maximumFrequency : Float32 = 4_200.0;
}
