//
//  LimitsGeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 26/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class LimitsGeneratorViewController: GeneratorViewController {

	required init?( windowController aWindowController: MainWindowController ) {
		super.init( nibName : "LimitsGeneratorViewController", windowController: aWindowController);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	dynamic var		limitExpanded : Bool {
		set( aValue ) { UserDefaults.standard.set(aValue, forKey: "limitExpanded"); }
		get { return UserDefaults.standard.bool(forKey: "limitExpanded"); }
	}
}
