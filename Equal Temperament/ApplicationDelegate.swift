//
//  ApplicationDelegate.swift
//  Equal Temperament
//
//  Created by Nathan Day on 16/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ApplicationDelegate: NSObject {

	lazy var		preferencesWindowController = PreferencesWindowController();
	lazy var		chordSelectorWindowController = ChordSelectorWindowController();

	@IBAction func showPreferencesAction( aSender: AnyObject? ) { preferencesWindowController.showWindow(aSender); }
	@IBAction func showChordSelectorAction( aSender: AnyObject? ) {
		chordSelectorWindowController.toggleWindow(aSender);
	}

}
