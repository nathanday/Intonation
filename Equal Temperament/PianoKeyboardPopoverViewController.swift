//
//  PianoKeyboardPopoverViewController.swift
//  Intonation
//
//  Created by Nathaniel Day on 26/08/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Cocoa

class PianoKeyboardPopoverViewController: NSViewController, NSPopoverDelegate {

	@IBOutlet var	pianoKeyboardControl: PianoKeyboardControl!;
	var			frequency: Double?;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

	func show(withFrequency aFrequency: Double?, relativeTo aView: NSView) {
		frequency = aFrequency;
		let		thePopover = NSPopover();
		thePopover.contentViewController = self;
		thePopover.delegate = self;
		thePopover.show(relativeTo: aView.bounds, of: aView, preferredEdge: .minX);
		if let theFreq = frequency {
			pianoKeyboardControl.selection = [PianoKeyboardControl.midiNoteNumber(forFrequency:theFreq)];
		}
	}

	@IBAction func keySelectedAction( _ aSender: PianoKeyboardControl ) {

	}

	public func popoverShouldClose(_ popover: NSPopover) -> Bool {
		return true;
	}


	public func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true;
	}


	public func popoverWillShow(_ notification: Notification) {
	}

	public func popoverDidShow(_ notification: Notification) {
	}

	public func popoverWillClose(_ notification: Notification) {
	}

	public func popoverDidClose(_ notification: Notification) {
	}

}
