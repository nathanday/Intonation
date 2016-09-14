//
//  SelectDocumentType.swift
//  Intonation
//
//  Created by Nathan Day on 10/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class SelectDocumentType : NSWindowController {
	var		referenceToSelf : NSWindowController? = nil;
	@IBOutlet var	tableView : NSTableView?;
	@IBOutlet var	arrayController : NSArrayController?
	dynamic var		hasSelection : Bool { return selectedDocumentTypeRow != nil; }
	var				selectedDocumentTypeRow : Int? {
		willSet { willChangeValue(forKey: "hasSelection"); }
		didSet { didChangeValue(forKey: "hasSelection"); }
	}
	var				completionBlock : ((_:DocumentType?)  -> Void)?;
	static var		rowData = [
		(title:"Limits", details:"Create musical intervals using prime and odd limits.", documentType:DocumentType.limits),
		(title:"Stacked Intervals", details:"Create musical intervals by stacking a simpler musical interval.", documentType:DocumentType.stackedIntervals),
		(title:"Equal Temperament", details:"Create musical intervals by dividing the octave, or other large interval, into equal size ratios.", documentType:DocumentType.equalTemperament),
		(title:"AdHoc", details:"Create musical intervals by manual entry.", documentType:DocumentType.adHoc),
		(title:"Preset", details:"Use a predfined set of musical intervals.", documentType:DocumentType.preset),
		];

	var				selectedDocumentType : DocumentType? {
		var		theResult : DocumentType? = nil;
		if let theIdex = selectedDocumentTypeRow {
			theResult = theIdex < SelectDocumentType.rowData.count ? SelectDocumentType.rowData[theIdex].documentType : nil;
		}
		return theResult;
	}
	dynamic var		tableContents = [[String:String]]();

	override var	windowNibName : String { get { return "SelectDocumentType"; } }

    override func windowDidLoad() {
        super.windowDidLoad()
		for theValue in SelectDocumentType.rowData {
			tableContents.append(["title":theValue.title,"details":theValue.details]);
		}
    }

	func showAsSheet(parentWindow aWindow: NSWindow ) {
		self.referenceToSelf = self;
		window!.parent = aWindow;
		aWindow.beginSheet( window!, completionHandler: {
			(aResponse: NSModalResponse) -> Void in
			switch aResponse {
			case NSModalResponseStop:
				self.completionBlock?( nil );
			case NSModalResponseAbort:
				self.completionBlock?( nil );
			case NSModalResponseContinue:
				self.completionBlock?( self.selectedDocumentType );
			default:
				self.completionBlock?( nil );
			}
			self.referenceToSelf = nil;
		});
	}

	@IBAction func selectAction( _ aSender: Any? ) {
		window!.parent?.endSheet(window!, returnCode:NSModalResponseContinue);
	}

	@IBAction func cancelAction( _ aSender: Any? ) {
		window!.parent?.endSheet(window!);
	}
}

extension SelectDocumentType : NSTableViewDelegate {
	func tableViewSelectionDidChange(_ notification: Notification) {
		let theSelection = tableView?.selectedRow;
		selectedDocumentTypeRow = theSelection != -1 ? theSelection : nil;
	}
}

