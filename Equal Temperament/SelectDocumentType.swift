//
//  SelectDocumentType.swift
//  Equal Temperament
//
//  Created by Nathan Day on 10/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class SelectDocumentType : NSWindowController {
	@IBOutlet var	tableView : NSTableView?;
	@IBOutlet var	arrayController : NSArrayController?
	var				selectedDocumentTypeRow : Int?;
	var				completionBlock : ((_:DocumentType?)  -> Void)?;
	static var		rowData = [
		(title:"Limits", details:"Create musical intervals using prime and odd limits.", documentType:DocumentType.Limits),
		(title:"Stacked Intervals", details:"Create musical intervals by stacking a simpler musical interval.", documentType:DocumentType.StackedIntervals),
		(title:"AdHoc", details:"Create musical intervals by manual entry.", documentType:DocumentType.AdHoc),
		(title:"Preset", details:"Use a predfined set of musical intervals.", documentType:DocumentType.Preset),
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
		if let theWindow = self.window {
			theWindow.parentWindow = aWindow;
			aWindow.beginSheet( theWindow, completionHandler: {
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
			});
		}
	}

	@IBAction func selectAction( aSender: AnyObject? ) {
		if let theWindow = window {
			theWindow.parentWindow?.endSheet(theWindow, returnCode:NSModalResponseContinue);
		}
	}

	@IBAction func cancelAction( aSender: AnyObject? ) {
		if let theWindow = window {
			theWindow.parentWindow?.endSheet(theWindow);
		}
	}
}

extension SelectDocumentType : NSTableViewDelegate {
	func tableViewSelectionDidChange(notification: NSNotification) {
		if let theSelectedRow = tableView?.selectedRow {
			selectedDocumentTypeRow = theSelectedRow;
		}
	}
}

