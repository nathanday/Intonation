//
//  ExportWindowController.swift
//  Intonation
//
//  Created by Nathan Day on 16/05/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class ExportWindowController: NSWindowController {

	var		completionBlock : (()  -> Void)?;
	var		referenceToSelf : NSWindowController? = nil;


	convenience init( document aDocument : Document ) {
		self.init(windowNibName: NSNib.Name(rawValue: "ExportWindowController"));
		document = aDocument;
	}

	//	override var	windowNibName : NSNib.Name { NSNib.Name(rawValue:"ExportWindowController"); }

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
	@objc dynamic var selectedExportMethodIdentifier : String {
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
	@objc dynamic var textExportMethod : Bool {
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
	@objc dynamic var binaryExportMethod : Bool {
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
	@objc dynamic var outputSelectedInterval : Bool = false;
	@objc dynamic var textOutputDelimiter : String = "\\t";

	func showAsSheet(parentWindow aWindow: NSWindow ) {
		referenceToSelf = self;
		aWindow.beginSheet( window!, completionHandler: {
			(aResponse: NSApplication.ModalResponse) -> Void in
			switch aResponse {
			case NSApplication.ModalResponse.stop:
				break;
			case NSApplication.ModalResponse.abort:
				break;
			case NSApplication.ModalResponse.continue:
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

	@IBAction func selectPresetDelimiter( _ aSender: NSMenuItem? ) {
		switch aSender!.tag {
		case 9:
			textOutputDelimiter = "\\t";
			break;
		case 10:
			textOutputDelimiter = "\\n";
			break;
		case 44:
			textOutputDelimiter = ",";
			break;
		default:
			assertionFailure("Unexpect tag \(aSender!.tag)");
			break;
		}
	}

	@IBAction func nextAction( _ aSender: Any? ) {
		window!.sheetParent?.endSheet(window!, returnCode:NSApplication.ModalResponse.continue);
	}

	@IBAction func cancelAction( _ aSender: Any? ) {
		window!.sheetParent!.endSheet(window!);
	}
}
