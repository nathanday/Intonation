//
//  AboutPanelWindowController.swift
//  Intonation
//
//  Created by Nathaniel Day on 18/10/17.
//  Copyright © 2017 Nathan Day. All rights reserved.
//

import Cocoa

class AboutPanelWindowController: NSWindowController {

	convenience init() {
		self.init(windowNibName: NSNib.Name("AboutPanelWindowController"));
	}

	@objc dynamic var	versionString : String {
		get {
			let		theVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "";
			let		theBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "" ;
			return "\(theVersion) (\(theBuild))";
		}
	}

    override func windowDidLoad() {
        super.windowDidLoad()
		window?.isMovableByWindowBackground = true;
    }
    
}
