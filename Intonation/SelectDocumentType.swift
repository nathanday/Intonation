//
//  SelectDocumentType.swift
//  Intonation
//
//  Created by Nathan Day on 10/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class SelectRow : NSObject, Decodable {
	@objc dynamic let	title: String;
	@objc dynamic let	details: String;
	var					isGroupHeader: Bool { return false };

	private enum CodingKeys: String, CodingKey {
		case title
		case details
	}
	required init(from aDecoder: Decoder) throws {
		let		theValues = try aDecoder.container(keyedBy: CodingKeys.self);
		title = try theValues.decode(String.self, forKey: .title);
		details = (try? theValues.decode(String.self, forKey: .details)) ?? "";
	}

	init( title aTitle: String, details aDetails: String ) {
		title = aTitle;
		details = aDetails;
	}
}

class SelectDocumentTypeGroup : SelectRow {
	let					everyRow: [SelectDocumentTypeRow];
	override var		isGroupHeader: Bool { return true; };

	private enum CodingKeys: String, CodingKey {
		case everyRow
	}
	required init(from aDecoder: Decoder) throws {
		let		theValues = try aDecoder.container(keyedBy: CodingKeys.self);
		everyRow = try theValues.decode([SelectDocumentTypeRow].self, forKey: .everyRow);
		try super.init(from: aDecoder);
	}

	init( title aTitle: String, everyRow anEveryRow: [SelectDocumentTypeRow] ) {
		everyRow = anEveryRow;
		super.init(title:aTitle,details:"");
	}
}

class SelectDocumentTypeRow : SelectRow {
	let			documentType: DocumentType;

	private enum CodingKeys: String, CodingKey {
		case documentType
	}
	required init(from aDecoder: Decoder) throws {
		let		theValues = try aDecoder.container(keyedBy: CodingKeys.self);
		documentType = DocumentType.fromString(try theValues.decode(String.self, forKey: .documentType))!;
		try super.init(from: aDecoder);
	}

	init( title aTitle: String, details aDetails: String, documentType aDocumentType: DocumentType ) {
		documentType = aDocumentType;
		super.init(title:aTitle,details:aDetails);
	}
}

class SelectDocumentType : NSWindowController {
	var						sourceRows = [SelectDocumentTypeGroup]();
	var						colaspedGroups = IndexSet();
	@objc dynamic var		tableContents = [SelectRow]();

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
		if let theIndex = selectedDocumentTypeRow,
			theIndex < tableContents.count,
			let theSelectDocumentTypeRow = tableContents[theIndex] as? SelectDocumentTypeRow {
			theResult = theSelectDocumentTypeRow.documentType;
		}
		return theResult;
	}

	override var	windowNibName : NSNib.Name { return NSNib.Name("SelectDocumentType"); }

    override func windowDidLoad() {
		do {
			if let theURL = Bundle.main.url(forResource: "SelectDocumentType", withExtension: "plist") {
				let	theData = try Data(contentsOf: theURL);
				let theObject = try PropertyListDecoder().decode([SelectDocumentTypeGroup].self, from: theData);
				sourceRows = theObject;
				updateTableContents();
			}
		} catch let anError {
			print( anError );
		}
		super.windowDidLoad()
    }

	func updateTableContents() {
		var		theTableContents = [SelectRow]();
		for (theGroupIndex,theGroup) in sourceRows.enumerated() {
			theTableContents.append(theGroup);
			if !colaspedGroups.contains(theGroupIndex) {
				theTableContents.append(contentsOf: theGroup.everyRow);
			}
		}
		tableContents = theTableContents;
	}

	func groupIndex(forRow aRow: Int ) -> Int? {
		var		theRowCount = 0;
		for (theGroupIndex,theGroup) in sourceRows.enumerated() {
			if theRowCount > aRow {
				break;
			}
			else if aRow == theRowCount {
				return theGroupIndex;
			}
			theRowCount += 1+theGroup.everyRow.count;
		}
		return nil;
	}

	func showAsSheet(parentWindow aWindow: NSWindow ) {
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
		}
	}

	func toggle(group anIndex: Int) {
		if colaspedGroups.contains(anIndex) {
			colaspedGroups.remove(anIndex);
		} else {
			colaspedGroups.insert(anIndex);
		}
		updateTableContents();
	}

	@IBAction func selectAction( _ aSender: Any? ) {
		if let theWindow = window,
			self.selectedDocumentType != nil {
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
		if let theSelection = tableView?.selectedRow,
			theSelection >= 0 {
			if let thheGroupIndex = groupIndex(forRow:theSelection) {
				toggle(group:thheGroupIndex);
			} else {
				selectedDocumentTypeRow = theSelection;
			}
		} else {
			selectedDocumentTypeRow = nil;
		}
	}

	@objc func tableView(_ aTableView: NSTableView,  isGroupRow aRow: Int) -> Bool {
		return tableContents[aRow].isGroupHeader;
	}

	@objc func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row aRow: Int) -> NSView?
	{
		if tableContents[aRow].isGroupHeader {
			return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("groupHeader"), owner:self) as! NSTableCellView
		} else {
			return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("rowCell"), owner: self) as! NSTableCellView
		}
	}
}

