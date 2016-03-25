//
//  GeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 24/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class GeneratorViewController : NSViewController {

	@IBOutlet var	windowController : MainWindowController?;

	var document : Document? {
		return windowController!.document as? Document;
	}

}
