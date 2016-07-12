//
//  ExportWindowController.swift
//  Intonation
//
//  Created by Nathan Day on 16/05/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class ExportWindowController: NSWindowController {

	var		completionBlock : ((Void)  -> Void)?;
	var		referenceToSelf : NSWindowController? = nil;


	convenience init( document aDocument : Document ) {
		self.init(windowNibName: "ExportWindowController");
		document = aDocument;
	}

//	override var	windowNibName : String { get { return "ExportWindowController"; } }

	var	selectedExportMethod : ExportMethod = .text {
		willSet {
			self.willChangeValue(forKey: "textExportMethod");
			self.willChangeValue(forKey: "binaryExportMethod");
			self.willChangeValue(forKey: "selectedExportMethodIdentifier");
		}
		didSet {
			self.didChangeValue(forKey: "textExportMethod");
			self.didChangeValue(forKey: "binaryExportMethod");
			self.didChangeValue(forKey: "selectedExportMethodIdentifier");
		}
	}
	dynamic var selectedExportMethodIdentifier : String {
		set {
			if newValue == "text" {
				selectedExportMethod = .text;
			} else if newValue == "binary" {
				selectedExportMethod = .binary;
			}
		}
		get {
			switch selectedExportMethod {
			case .text:
				return "text"
			case .binary:
				return "binary"
			}
		}
	}
	dynamic var textExportMethod : Bool {
		set {
			if newValue {
				selectedExportMethod = .text;
			} else {
				selectedExportMethod = .binary;
			}
		}
		get {
			return selectedExportMethod == .text;
		}
	}
	dynamic var binaryExportMethod : Bool {
		set {
			if newValue {
				selectedExportMethod = .binary;
			} else {
				selectedExportMethod = .text;
			}
		}
		get {
			return selectedExportMethod == .binary;
		}
	}

	func showAsSheet(parentWindow aWindow: NSWindow ) {
		referenceToSelf = self;
		window!.parent = aWindow;
		aWindow.beginSheet( window!, completionHandler: {
			(aResponse: NSModalResponse) -> Void in
			switch aResponse {
			case NSModalResponseStop:
				break;
			case NSModalResponseAbort:
				break;
			case NSModalResponseContinue:
				break;
			default:
				break;
			}
			self.referenceToSelf = nil;
		});
	}
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
	@IBAction func nextAction( _ aSender: AnyObject? ) {
		window!.parent?.endSheet(window!, returnCode:NSModalResponseContinue);
	}

	@IBAction func cancelAction( _ aSender: AnyObject? ) {
		window!.parent!.endSheet(window!);
	}
}
