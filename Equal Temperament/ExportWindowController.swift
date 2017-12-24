//
//  ExportWindowController.swift
//  Intonation
//
//  Created by Nathan Day on 16/05/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class ExportWindowController: NSWindowController {

	var		completionBlock : ((Bool,ExportMethod,Bool)  -> Void)?;
	var		referenceToSelf : NSWindowController? = nil;

	convenience init( completionBlock aCompletionBlock : @escaping ((Bool,ExportMethod,Bool) -> Void) ) {
		self.init(windowNibName: NSNib.Name(rawValue: "ExportWindowController") );
		completionBlock = aCompletionBlock;
	}

	var previousSelectedExportMethod : ExportMethod = .binary;
	var	selectedExportMethod : ExportMethod = .text {
		willSet {
			willChangeValue(forKey: "textExportMethod");
			willChangeValue(forKey: "binaryExportMethod");
			willChangeValue(forKey: "JSONExportMethod");
			willChangeValue(forKey: "selectedExportMethodIdentifier");
			previousSelectedExportMethod = selectedExportMethod;
		}
		didSet {
			didChangeValue(forKey: "textExportMethod");
			didChangeValue(forKey: "binaryExportMethod");
			didChangeValue(forKey: "JSONExportMethod");
			didChangeValue(forKey: "selectedExportMethodIdentifier");
		}
	}
	@objc dynamic var selectedExportMethodIdentifier : String {
		set {
			switch newValue {
			case "text": selectedExportMethod = .text;
			case "binary": selectedExportMethod = .binary;
			case "JSON": selectedExportMethod = .JSON;
			default: assertionFailure("Unexpect value \(newValue)");
			}
		}
		get {
			switch selectedExportMethod {
			case .text: return "text"
			case .binary: return "binary"
			case .JSON: return "JSON"
			}
		}
	}
	@objc dynamic var textExportMethod : Bool {
		set { selectedExportMethod = newValue ? .text : previousSelectedExportMethod; }
		get { return selectedExportMethod == .text; }
	}
	@objc dynamic var binaryExportMethod : Bool {
		set { selectedExportMethod = newValue ? .binary : previousSelectedExportMethod; }
		get { return selectedExportMethod == .binary; }
	}
	@objc dynamic var JSONExportMethod : Bool {
		set { selectedExportMethod = newValue ? .JSON : previousSelectedExportMethod; }
		get { return selectedExportMethod == .JSON; }
	}
	@objc dynamic var outputSelectedInterval : Bool = false;
	@objc dynamic var textOutputDelimiter : String = "\\t";

	func showAsSheet(parentWindow aWindow: NSWindow ) {
		referenceToSelf = self;
			aWindow.beginSheet( window!, completionHandler: {
				(aResponse: NSApplication.ModalResponse) -> Void in
				self.completionBlock!(aResponse == NSApplication.ModalResponse.continue,self.selectedExportMethod,self.outputSelectedInterval);
				self.referenceToSelf = nil;
			});
	}

	@IBAction func selectPresetDelimiter( _ aSender: NSMenuItem? ) {
		switch aSender!.tag {
		case 9: textOutputDelimiter = "\\t";
		case 10: textOutputDelimiter = "\\n";
		case 44: textOutputDelimiter = ",";
		default: assertionFailure("Unexpect tag \(aSender!.tag)");
		}
	}

	@IBAction func nextAction( _ aSender: Any? ) {
		window!.sheetParent?.endSheet(window!, returnCode:NSApplication.ModalResponse.continue);
	}

	@IBAction func cancelAction( _ aSender: Any? ) {
		window!.sheetParent!.endSheet(window!);
	}
}
