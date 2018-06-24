//
//  IntervalTextView.swift
//  Intonation
//
//  Created by Nathaniel Day on 16/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Cocoa
import os

class IntervalTextView: NSTextView {
	@IBAction override func paste( _ aSender: Any? ) {
		guard let theTypes = NSPasteboard.general.types else {
			return;
		}
		if theTypes.contains(IntervalEntry.nativePasteboardType) {
			let theEntries = NSPasteboard.general.readObjects(forClasses: [IntervalEntry.self], options: nil) as? [IntervalEntry];
			os_log( "Here" );
		} else {
			super.paste(aSender);
		}
	}
}
