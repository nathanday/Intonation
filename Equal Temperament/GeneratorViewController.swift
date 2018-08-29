//
//  GeneratorViewController.swift
//  Intonation
//
//  Created by Nathan Day on 24/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class GeneratorViewController : NSViewController {

	var	windowController : MainWindowController?;

	required init?( windowController aWindowController: MainWindowController ) {
		fatalError("init(windowController:) has not been implemented")
	}

	init?( nibName aNibName: NSNib.Name, windowController aWindowController: MainWindowController ) {
		windowController = aWindowController;
		super.init(nibName: aNibName, bundle: nil);
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc dynamic var document : Document? {
		return windowController!.document as? Document;
	}

}
