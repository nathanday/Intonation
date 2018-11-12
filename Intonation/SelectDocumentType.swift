//
//  SelectDocumentType.swift
//  Intonation
//
//  Created by Nathan Day on 10/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class SelectDocumentType : NSWindowController {
	static var		rowData = [
		(title:DocumentType.limits.title,
		 	details:NSLocalizedString("Create musical intervals using prime and odd limits.",comment:"document type details"),
			documentType:DocumentType.limits),
		(title:DocumentType.stackedIntervals.title,
		 	details:NSLocalizedString("Create musical intervals by stacking a simpler musical interval.",comment:"document type details"),
			 documentType:DocumentType.stackedIntervals),
		(title:DocumentType.equalTemperament.title,
		 	details:NSLocalizedString("Create musical intervals by dividing the octave, or other large interval, into equal size ratios.",comment:"document type details"),
			 documentType:DocumentType.equalTemperament),
		(title:DocumentType.harmonicSeries.title,
		 	details:NSLocalizedString("Create musical intervals from the natural harmonic series.",comment:"document type details"),
			 documentType:DocumentType.harmonicSeries),
		(title:DocumentType.adHoc.title,
		 	details:NSLocalizedString("Create musical intervals by manual entry.",comment:"document type details"),
			 documentType:DocumentType.adHoc),
		(title:DocumentType.preset.title,
		 	details:NSLocalizedString("Use a predfined set of musical intervals.",comment:"document type details"),
			 documentType:DocumentType.preset),
	];

	var		referenceToSelf : NSWindowController? = nil;
	@IBOutlet var	tableView : NSTableView?;
	@IBOutlet var	arrayController : NSArrayController?
	@objc dynamic var		hasSelection : Bool { return selectedDocumentTypeRow != nil; }
	var				selectedDocumentTypeRow : Int? {
		willSet { willChangeValue(forKey: "hasSelection"); }
		didSet { didChangeValue(forKey: "hasSelection"); }
	}
	var				completionBlock : ((_:DocumentType?)  -> Void)?;

	var				selectedDocumentType : DocumentType? {
		var		theResult : DocumentType? = nil;
		if let theIdex = selectedDocumentTypeRow {
			theResult = theIdex < SelectDocumentType.rowData.count ? SelectDocumentType.rowData[theIdex].documentType : nil;
		}
		return theResult;
	}
	@objc dynamic var		tableContents = [[String:String]]();

	override var	windowNibName : NSNib.Name { return NSNib.Name("SelectDocumentType"); }

    override func windowDidLoad() {
        super.windowDidLoad()
		for theValue in SelectDocumentType.rowData {
			tableContents.append(["title":theValue.title,"details":theValue.details]);
		}
    }

	func showAsSheet(parentWindow aWindow: NSWindow ) {
		referenceToSelf = self;
		aWindow.beginSheet( window! )  {
			(aResponse: NSApplication.ModalResponse) -> Void in
			switch aResponse {
			case NSApplication.ModalResponse.stop:
				self.completionBlock?( nil );
			case NSApplication.ModalResponse.abort:
				self.completionBlock?( nil );
			case NSApplication.ModalResponse.`continue`:
				self.completionBlock?( self.selectedDocumentType );
			default:
				self.completionBlock?( nil );
			}
			self.referenceToSelf = nil;
		}
	}

	@IBAction func selectAction( _ aSender: Any? ) {
		if let theWindow = window {
			theWindow.sheetParent?.endSheet(theWindow, returnCode:.`continue`);
		}
	}

	@IBAction func cancelAction( _ aSender: Any? ) {
		if let theWindow = window {
			theWindow.sheetParent?.endSheet(theWindow);
		}
	}
}

extension SelectDocumentType : NSTableViewDelegate {
	@objc func tableViewSelectionDidChange(_ notification: Notification) {
		let theSelection = tableView?.selectedRow;
		selectedDocumentTypeRow = theSelection != -1 ? theSelection : nil;
	}
}

