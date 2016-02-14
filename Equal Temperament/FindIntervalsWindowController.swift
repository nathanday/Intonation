//
//  FindIntervalsViewController.swift
//  Equal Temperament
//
//  Created by Nathan Day on 28/01/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class FindIntervalsViewController: NSViewController {

	dynamic var		hidden : Bool = true {
		didSet {
			NSUserDefaults.standardUserDefaults().setBool( hidden, forKey:"findIntervalesHidded");
		}
	}

	dynamic var		findMethod : Int = 0;

	override func viewDidLoad() {
        super.viewDidLoad()
		hidden = NSUserDefaults.standardUserDefaults().boolForKey("findIntervalesHidded");
    }

	@IBAction override func dismissController( aSender: AnyObject? ) { hidden = true; }

}
