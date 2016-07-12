/*
	ApplicationDelegate.swift
	Intonation

	Created by Nathan Day on 16/04/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Cocoa

class ApplicationDelegate: NSObject {

	lazy var		preferencesWindowController : PreferencesWindowController = PreferencesWindowController();
	lazy var		chordSelectorWindowController : ChordSelectorWindowController = ChordSelectorWindowController();
	
	static var		initialUserDefaultsLoaded = false;
	override class func initialize() {
		if initialUserDefaultsLoaded == false {
			if let theURL = Bundle.main.urlForResource("InitialUserDefaults", withExtension: "plist"),
				theInitialUserDefaults = NSDictionary(contentsOf:theURL) as? [String:AnyObject] {
					UserDefaults.standard.register(theInitialUserDefaults);
					initialUserDefaultsLoaded = true;
			}
		}
	}

	@IBAction func showPreferencesAction( _ aSender: AnyObject? ) { preferencesWindowController.showWindow(aSender); }
	@IBAction func showChordSelectorAction( _ aSender: AnyObject? ) {
		chordSelectorWindowController.toggleWindow(aSender);
	}
}
