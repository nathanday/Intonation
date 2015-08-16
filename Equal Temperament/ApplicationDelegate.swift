/*
	ApplicationDelegate.swift
	Equal Temperament

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
			if let theURL = NSBundle.mainBundle().URLForResource("InitialUserDefaults", withExtension: "plist") {
				if let theInitialUserDefaults = NSDictionary(contentsOfURL:theURL) as? [String:AnyObject] {
					NSUserDefaults.standardUserDefaults().registerDefaults(theInitialUserDefaults);
				}
			}
			
			initialUserDefaultsLoaded = true;
		}
	}

	@IBAction func showPreferencesAction( aSender: AnyObject? ) { preferencesWindowController.showWindow(aSender); }
	@IBAction func showChordSelectorAction( aSender: AnyObject? ) {
		chordSelectorWindowController.toggleWindow(aSender);
	}

}
